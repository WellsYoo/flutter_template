import 'package:xjj_app_base/core/utils/json.dart';

enum ContractStatus {
  pending('待审批'),
  active('执行中'),
  done('已完成'),
  rejected('已驳回');

  const ContractStatus(this.label);

  final String label;

  /// 后端给的值不认识时按待审批处理，不要抛异常
  static ContractStatus parse(String? value) => values.asNameMap()[value] ?? pending;
}

class Contract {
  const Contract({
    required this.id,
    required this.title,
    required this.customer,
    required this.amount,
    required this.status,
    required this.owner,
    required this.signDate,
    this.remark = '',
    this.flow = const [],
  });

  final String id;
  final String title;
  final String customer;
  final double amount;
  final ContractStatus status;

  /// 经办人
  final String owner;
  final DateTime signDate;
  final String remark;

  /// 审批流程，只有详情接口返回
  final List<FlowStep> flow;

  factory Contract.fromJson(Map<String, dynamic> json) => Contract(
    id: json.str('id'),
    title: json.str('title'),
    customer: json.str('customer'),
    amount: json.number('amount'),
    status: ContractStatus.parse(json.strOrNull('status')),
    owner: json.str('owner'),
    signDate: json.date('signDate') ?? DateTime(1970),
    remark: json.str('remark'),
    flow: json.list('flow', FlowStep.fromJson),
  );
}

enum FlowState { done, current, waiting, rejected }

/// 审批流程里的一步
class FlowStep {
  const FlowStep({required this.title, required this.operator, required this.state, this.time});

  final String title;
  final String operator;
  final FlowState state;

  /// 处理时间；还没轮到时为 null
  final DateTime? time;

  factory FlowStep.fromJson(Map<String, dynamic> json) => FlowStep(
    title: json.str('title'),
    operator: json.str('operator'),
    state: FlowState.values.asNameMap()[json.strOrNull('state')] ?? FlowState.waiting,
    time: json.date('time'),
  );
}
