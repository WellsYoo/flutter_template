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

  /// 最近一次加载更多的错误；再次加载更多或刷新成功后清空。
  final Object? loadMoreError;

  bool get isEmpty => items.isEmpty;
}

/// [PagedNotifier.loadMore] 的结果，列表组件据此决定底部提示。
enum LoadMoreResult {
  /// 加载了一页，后面还有。
  loaded,

  /// 已经没有更多（包括这次刚好加载到最后一页）。
  noMore,

  /// 请求失败，错误记在 [PagedState.loadMoreError]，已有列表不变。
  failed,

  /// 没有生效：首屏未完成、正在刷新或加载更多时被忽略，
  /// 或请求期间列表已被刷新 / 重建，结果作废。
  skipped,
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

  /// 每次列表被整体替换（刷新成功）加一，用来丢弃替换之前发出的加载更多结果。
  int _generation = 0;
  Future<void>? _refreshing;

  /// 下拉刷新。已有数据时刷新失败会保留旧数据并抛出异常（由调用方 toast）。
  /// 刷新进行中重复调用会复用同一次请求。
  Future<void> refresh() => _refreshing ??= _refresh().whenComplete(() => _refreshing = null);

  Future<void> _refresh() async {
    // provider 重建（invalidate / 依赖变化）后 ref 会换成新的；
    // 先记下当前 ref，await 之后用它判断结果是否已过期。
    final ref = this.ref;
    try {
      final next = await _loadFirstPage();
      if (!ref.mounted) return;
      _generation++; // 进行中的加载更多属于旧列表，回来后丢弃
      state = AsyncData(next);
    } catch (e, st) {
      if (!ref.mounted) return;
      final current = state.value;
      if (current == null || current.isEmpty) {
        state = AsyncError(e, st);
      } else {
        rethrow;
      }
    }
  }

  /// 加载下一页。首屏未完成、正在刷新、重复调用时忽略（返回 [LoadMoreResult.skipped]）。
  Future<LoadMoreResult> loadMore() async {
    final current = state.value;
    if (current == null ||
        state.isLoading ||
        state.hasError ||
        _refreshing != null ||
        current.loadingMore) {
      return LoadMoreResult.skipped;
    }
    if (!current.hasMore) return LoadMoreResult.noMore;

    final ref = this.ref; // 同 refresh
    final generation = _generation;
    bool stale() => !ref.mounted || generation != _generation;

    state = AsyncData(_copy(current, loadingMore: true));
    try {
      final result = await fetchPage(current.page + 1);
      if (stale()) return LoadMoreResult.skipped;
      // 以最新的列表为准追加：请求期间可能调用过 updateItems
      state = AsyncData(
        PagedState(
          items: [...state.requireValue.items, ...result.items],
          page: current.page + 1,
          hasMore: result.hasMore,
        ),
      );
      return result.hasMore ? LoadMoreResult.loaded : LoadMoreResult.noMore;
    } catch (e) {
      if (stale()) return LoadMoreResult.skipped;
      state = AsyncData(_copy(state.requireValue, loadMoreError: e));
      return LoadMoreResult.failed;
    }
  }

  /// 本地增删改后直接更新列表，不用重新请求。加载更多进行中也可以调用。
  void updateItems(List<T> Function(List<T> items) update) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      PagedState(
        items: update(current.items),
        page: current.page,
        hasMore: current.hasMore,
        loadingMore: current.loadingMore,
        loadMoreError: current.loadMoreError,
      ),
    );
  }

  PagedState<T> _copy(PagedState<T> s, {bool loadingMore = false, Object? loadMoreError}) =>
      PagedState(
        items: s.items,
        page: s.page,
        hasMore: s.hasMore,
        loadingMore: loadingMore,
        loadMoreError: loadMoreError,
      );
}
