import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xjj_app_base/core/theme/app_theme.dart';
import 'package:xjj_app_base/core/utils/context_ext.dart';
import 'package:xjj_app_base/shared/pagination.dart';
import 'package:xjj_app_base/shared/ui/app_refresh.dart';
import 'package:xjj_app_base/shared/ui/feedback.dart';
import 'package:xjj_app_base/shared/ui/status_views.dart';

/// 分页列表：下拉刷新 + 上拉加载（EasyRefresh）+ 空 / 错 / 加载中状态，配合 [PagedNotifier]。
///
/// ```dart
/// PagedListView(
///   provider: articleListProvider(keyword),
///   itemBuilder: (context, article, index) => ArticleTile(article),
/// )
/// ```
class PagedListView<N extends PagedNotifier<T>, T> extends ConsumerWidget {
  const PagedListView({
    super.key,
    required this.provider,
    required this.itemBuilder,
    this.separator = const SizedBox(height: Insets.md),
    this.padding = const EdgeInsets.all(Insets.lg),
    this.empty = const EmptyView(),
    this.header,
  });

  final AsyncNotifierProvider<N, PagedState<T>> provider;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget separator;
  final EdgeInsetsGeometry padding;
  final Widget empty;

  /// 列表顶部、跟随滚动的内容（如统计卡片）
  final Widget? header;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(provider.notifier);

    return ref
        .watch(provider)
        .when(
          loading: () => const LoadingView(),
          error: (e, _) => ErrorView(error: e, onRetry: () => ref.invalidate(provider)),
          data: (state) => AppRefresh(
            onRefresh: () async {
              try {
                await notifier.refresh();
                return IndicatorResult.success;
              } catch (e) {
                Toast.error(e);
                return IndicatorResult.fail;
              }
            },
            // 没有更多 / 空列表时关闭上拉，底部显示静态文案
            onLoad: state.hasMore && !state.isEmpty
                ? () async {
                    await notifier.loadMore();
                    final error = ref.read(provider).value?.loadMoreError;
                    if (error == null) return IndicatorResult.success;
                    Toast.error(error);
                    return IndicatorResult.fail;
                  }
                : null,
            child: state.isEmpty ? _emptyScrollable() : _list(state),
          ),
        );
  }

  Widget _list(PagedState<T> state) {
    final hasHeader = header != null;
    final count = state.items.length;
    return ListView.separated(
      padding: padding,
      // 头部 + 数据 + 底部“没有更多了”
      itemCount: count + (hasHeader ? 1 : 0) + (state.hasMore ? 0 : 1),
      separatorBuilder: (_, _) => separator,
      itemBuilder: (context, index) {
        if (hasHeader) {
          if (index == 0) return header!;
          index -= 1;
        }
        if (index == count) return const _NoMore();
        return itemBuilder(context, state.items[index], index);
      },
    );
  }

  /// 空列表也要能下拉刷新
  Widget _emptyScrollable() => CustomScrollView(
    slivers: [
      if (header != null)
        SliverPadding(
          padding: padding,
          sliver: SliverToBoxAdapter(child: header),
        ),
      SliverFillRemaining(hasScrollBody: false, child: empty),
    ],
  );
}

class _NoMore extends StatelessWidget {
  const _NoMore();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Insets.sm),
      child: Center(
        child: Text(
          '没有更多了',
          style: TextStyle(fontSize: FontSizes.caption, color: context.appColors.textHint),
        ),
      ),
    );
  }
}
