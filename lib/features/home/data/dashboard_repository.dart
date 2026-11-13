import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xjj_app_base/core/network/api_client.dart';
import 'package:xjj_app_base/features/home/data/dashboard.dart';

abstract interface class DashboardRepository {
  Future<Dashboard> fetch();
  Future<void> decide(String id, {required bool approved});
}

/// 接入真实后端：`ApiDashboardRepository(ref.watch(apiClientProvider))`
final dashboardRepositoryProvider = Provider<DashboardRepository>(
  (ref) => FakeDashboardRepository(),
);

class ApiDashboardRepository implements DashboardRepository {
  ApiDashboardRepository(this._api);

  final ApiClient _api;

  @override
  Future<Dashboard> fetch() =>
      _api.get('/dashboard', decode: (d) => _parse(d! as Map<String, dynamic>));

  @override
  Future<void> decide(String id, {required bool approved}) =>
      _api.post('/approvals/$id/decide', data: {'approved': approved});

  Dashboard _parse(Map<String, dynamic> json) {
    final approvals = (json['approvals'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(
          (e) => Approval(
            id: e['id'].toString(),
            title: e['title'] as String? ?? '',
            applicant: e['applicant'] as String? ?? '',
            amount: (e['amount'] as num?)?.toDouble() ?? 0,
            createdAt: DateTime.tryParse(e['createdAt'] as String? ?? '') ?? DateTime.now(),
          ),
        )
        .toList();
    return Dashboard(
      monthAmount: (json['monthAmount'] as num?)?.toDouble() ?? 0,
      pending: json['pending'] as int? ?? 0,
      ongoing: json['ongoing'] as int? ?? 0,
      expiring: json['expiring'] as int? ?? 0,
      trend: (json['trend'] as List<dynamic>? ?? const [])
          .cast<num>()
          .map((e) => e.toDouble())
          .toList(),
      approvals: approvals,
    );
  }
}

/// 演示用假数据。审批过的合同会记下来，下拉刷新后不再出现。
class FakeDashboardRepository implements DashboardRepository {
  FakeDashboardRepository({this.delay = const Duration(milliseconds: 700)});

  final Duration delay;
  int _calls = 0;
  final _decided = <String>{};

  static const _titles = [
    '某某园区智慧照明采购合同',
    '办公楼消防改造施工合同',
    '年度法律顾问服务合同',
    '数据中心机柜租赁合同',
    '员工补充医疗保险采购合同',
  ];
  static const _applicants = ['张伟', '李静', '王强', '赵敏', '陈晓'];

  @override
  Future<Dashboard> fetch() async {
    await Future<void>.delayed(delay);
    _calls++;
    final now = DateTime.now();
    final approvals = [
      for (var i = 0; i < _titles.length; i++)
        Approval(
          id: 'HT-2025-000${100 + i}',
          title: _titles[i],
          applicant: _applicants[i],
          amount: [128000, 356000, 68000, 240000, 96000][i].toDouble(),
          createdAt: now.subtract(Duration(hours: 3 + i * 7)),
        ),
    ].where((a) => !_decided.contains(a.id)).toList();
    return Dashboard(
      // 每次请求数字都不一样，方便看出下拉刷新确实生效了
      monthAmount: 1286400 + _calls * 1000,
      pending: approvals.length,
      ongoing: 12,
      expiring: 3,
      trend: const [42, 68, 55, 91, 74, 120, 96],
      approvals: approvals,
    );
  }

  @override
  Future<void> decide(String id, {required bool approved}) async {
    await Future<void>.delayed(delay);
    _decided.add(id);
  }
}
