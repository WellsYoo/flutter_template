import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xjj_app_base/core/network/api_exception.dart';
import 'package:xjj_app_base/shared/pagination.dart';
import 'package:xjj_app_base/shared/ui/x_paged_list_view.dart';

/// 列表的各种状态场景，用来演示和手动验证 XPagedListView 的表现。
enum ListScenario {
  normal('正常分页', '共 35 条，下拉刷新，上拉加载更多'),
  empty('空数据', '首屏返回 0 条，下拉刷新后有数据'),
  firstPageError('首屏失败', '首次加载失败，点“重试”后成功'),
  loadMoreError('加载更多失败', '第 2 页第一次失败，再次上拉成功'),
  refreshError('刷新失败', '下拉刷新失败：保留旧数据并提示');

  const ListScenario(this.title, this.description);

  final String title;
  final String description;
}

final demoListProvider = AsyncNotifierProvider.autoDispose
    .family<DemoListNotifier, PagedState<String>, ListScenario>(DemoListNotifier.new);

/// 模拟后端：根据场景决定返回数据还是抛错。
/// 失败计数放在 notifier 字段里：invalidate 重建时 notifier 实例不变，计数会保留。
class DemoListNotifier extends PagedNotifier<String> {
  DemoListNotifier(this.scenario);

  final ListScenario scenario;
  static const _total = 35;

  int _firstPageCalls = 0;
  final _failedPages = <int>{};

  @override
  int get pageSize => 15;

  @override
  Future<PageResult<String>> fetchPage(int page) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (page == 1) _firstPageCalls++;

    switch (scenario) {
      case ListScenario.empty when _firstPageCalls == 1:
        return const PageResult(items: [], hasMore: false);
      case ListScenario.firstPageError when _firstPageCalls == 1:
      case ListScenario.refreshError when page == 1 && _firstPageCalls > 1:
        throw const ApiException(ApiErrorType.network, '网络连接失败，请检查网络');
      case ListScenario.loadMoreError when page == 2 && _failedPages.add(page):
        throw const ApiException(ApiErrorType.timeout, '网络超时');
      default:
        final start = (page - 1) * pageSize;
        final end = (start + pageSize).clamp(0, _total);
        return PageResult(
          items: [for (var i = start; i < end; i++) '第 ${i + 1} 条（刷新第 $_firstPageCalls 次）'],
          hasMore: end < _total,
        );
    }
  }
}

class DemoListPage extends StatelessWidget {
  const DemoListPage({super.key, required this.scenario});

  final ListScenario scenario;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(scenario.title)),
      body: XPagedListView(
        provider: demoListProvider(scenario),
        padding: EdgeInsets.zero,
        separator: const Divider(indent: 16),
        itemBuilder: (context, item, index) => ListTile(title: Text(item)),
      ),
    );
  }
}
