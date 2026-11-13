import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xjj_app_base/features/home/data/dashboard.dart';
import 'package:xjj_app_base/features/home/data/dashboard_repository.dart';

/// 工作台数据。不 autoDispose：切到别的 tab 再回来直接用缓存，下拉刷新才重新请求。
final dashboardProvider = AsyncNotifierProvider<DashboardNotifier, Dashboard>(
  DashboardNotifier.new,
);

class DashboardNotifier extends AsyncNotifier<Dashboard> {
  DashboardRepository get _repo => ref.read(dashboardRepositoryProvider);

  @override
  Future<Dashboard> build() => _repo.fetch();

  /// 下拉刷新：失败时保留旧数据并把异常抛给调用方（页面 toast）
  Future<void> refresh() async {
    final next = await _repo.fetch();
    if (!ref.mounted) return;
    state = AsyncData(next);
  }

  /// 审批。成功后直接从列表移除并更新统计，不重新请求整个工作台。
  Future<void> decide(Approval approval, {required bool approved}) async {
    await _repo.decide(approval.id, approved: approved);
    if (!ref.mounted) return;
    final current = state.value;
    if (current == null) return;
    final left = current.approvals.where((a) => a.id != approval.id).toList();
    state = AsyncData(current.copyWith(approvals: left, pending: left.length));
  }
}
