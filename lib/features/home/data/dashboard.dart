/// 工作台数据。真实项目里通常是后端的一个聚合接口：一次返回统计 + 待办 + 趋势，
/// 省掉首屏好几个请求。字段按需增减。
class Dashboard {
  const Dashboard({
    required this.monthAmount,
    required this.pending,
    required this.ongoing,
    required this.expiring,
    required this.trend,
    required this.approvals,
  });

  /// 本月签约额
  final double monthAmount;

  /// 待我审批
  final int pending;

  /// 执行中合同
  final int ongoing;

  /// 30 天内到期
  final int expiring;

  /// 近 7 天签约额，用于趋势图
  final List<double> trend;

  final List<Approval> approvals;

  Dashboard copyWith({List<Approval>? approvals, int? pending}) => Dashboard(
    monthAmount: monthAmount,
    pending: pending ?? this.pending,
    ongoing: ongoing,
    expiring: expiring,
    trend: trend,
    approvals: approvals ?? this.approvals,
  );
}

/// 待审批的合同
class Approval {
  const Approval({
    required this.id,
    required this.title,
    required this.applicant,
    required this.amount,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String applicant;
  final double amount;
  final DateTime createdAt;
}
