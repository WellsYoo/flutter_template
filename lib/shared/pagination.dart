import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 一页数据
class PageResult<T> {
  const PageResult({required this.items, required this.hasMore});

  final List<T> items;
  final bool hasMore;
}

/// 分页列表状态。外层包在 AsyncValue 里：首屏加载/首屏失败由 AsyncValue 表示，
/// 加载更多的过程和失败由这里的字段表示（不会把已有列表冲掉）。
class PagedState<T> {
  const PagedState({
    this.items = const [],
    this.page = 0,
    this.hasMore = true,
    this.loadingMore = false,
    this.loadMoreError,
  });

  final List<T> items;
  final int page;
  final bool hasMore;
  final bool loadingMore;
  final Object? loadMoreError;

  bool get isEmpty => items.isEmpty;
}

/// 分页列表的通用 Notifier。子类只需实现 [fetchPage]：
///
/// ```dart
/// final articleListProvider =
///     AsyncNotifierProvider.autoDispose<ArticleListNotifier, PagedState<Article>>(ArticleListNotifier.new);
///
/// class ArticleListNotifier extends PagedNotifier<Article> {
///   @override
///   Future<PageResult<Article>> fetchPage(int page) =>
///       ref.read(articleRepositoryProvider).fetchPage(page: page, size: pageSize);
/// }
/// ```
///
/// 页码从 1 开始。带筛选条件时用 family，把条件作为参数（参数需实现 ==，record 即可），
/// 条件变化就是另一个 provider，自动从第一页加载，见 features/article/article_providers.dart。
abstract class PagedNotifier<T> extends AsyncNotifier<PagedState<T>> {
  int get pageSize => 20;

  Future<PageResult<T>> fetchPage(int page);

  @override
  Future<PagedState<T>> build() => _loadFirstPage();

  Future<PagedState<T>> _loadFirstPage() async {
    final result = await fetchPage(1);
    return PagedState(items: result.items, page: 1, hasMore: result.hasMore);
  }

  /// 下拉刷新。已有数据时刷新失败会保留旧数据并抛出异常（由调用方 toast）。
  Future<void> refresh() async {
    final previous = state.value;
    // provider 重建（invalidate / 依赖变化）后 ref 会换成新的；
    // 先记下当前 ref，await 之后用它判断结果是否已过期。
    final ref = this.ref;
    try {
      final next = await _loadFirstPage();
      if (ref.mounted) state = AsyncData(next);
    } catch (e, st) {
      if (!ref.mounted) return;
      if (previous == null || previous.isEmpty) {
        state = AsyncError(e, st);
      } else {
        rethrow;
      }
    }
  }

  /// 加载下一页。重复调用、没有更多、首屏未完成时自动忽略。
  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || state.isLoading || current.loadingMore || !current.hasMore) return;

    final ref = this.ref; // 同 refresh
    state = AsyncData(_copy(current, loadingMore: true));
    try {
      final result = await fetchPage(current.page + 1);
      if (!ref.mounted) return;
      state = AsyncData(
        PagedState(
          items: [...current.items, ...result.items],
          page: current.page + 1,
          hasMore: result.hasMore,
        ),
      );
    } catch (e) {
      if (!ref.mounted) return;
      state = AsyncData(_copy(current, loadMoreError: e));
    }
  }

  /// 本地增删改后直接更新列表，不用重新请求。
  void updateItems(List<T> Function(List<T> items) update) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(_copy(current, items: update(current.items)));
  }

  PagedState<T> _copy(
    PagedState<T> s, {
    List<T>? items,
    bool loadingMore = false,
    Object? loadMoreError,
  }) => PagedState(
    items: items ?? s.items,
    page: s.page,
    hasMore: s.hasMore,
    loadingMore: loadingMore,
    loadMoreError: loadMoreError,
  );
}
