import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xjj_app_base/core/network/api_client.dart';
import 'package:xjj_app_base/core/network/api_exception.dart';
import 'package:xjj_app_base/features/contract/data/contract.dart';
import 'package:xjj_app_base/shared/pagination.dart';

abstract interface class ContractRepository {
  /// [status] 为 null 时返回全部
  Future<PageResult<Contract>> fetchPage({
    required int page,
    required int size,
    ContractStatus? status,
    CancelToken? cancelToken,
  });
  Future<Contract> fetchDetail(String id, {CancelToken? cancelToken});
}

/// 接入真实后端：`ApiContractRepository(ref.watch(apiClientProvider))`
final contractRepositoryProvider = Provider<ContractRepository>((ref) => FakeContractRepository());

class ApiContractRepository implements ContractRepository {
  ApiContractRepository(this._api);

  final ApiClient _api;

  @override
  Future<PageResult<Contract>> fetchPage({
    required int page,
    required int size,
    ContractStatus? status,
    CancelToken? cancelToken,
  }) {
    return _api.get(
      '/contracts',
      cancelToken: cancelToken,
      query: {'page': page, 'size': size, 'status': ?status?.name},
      decode: (data) {
        final map = data! as Map<String, dynamic>;
        final list = (map['list'] as List<dynamic>).cast<Map<String, dynamic>>();
        return PageResult(
          items: list.map(Contract.fromJson).toList(),
          hasMore: page * size < (map['total'] as int),
        );
      },
    );
  }

  @override
  Future<Contract> fetchDetail(String id, {CancelToken? cancelToken}) => _api.get(
    '/contracts/$id',
    cancelToken: cancelToken,
    decode: (d) => Contract.fromJson(d! as Map<String, dynamic>),
  );
}

/// 演示用假数据，共 [total] 条
class FakeContractRepository implements ContractRepository {
  FakeContractRepository({this.total = 48, this.delay = const Duration(milliseconds: 500)});

  final int total;
  final Duration delay;

  static const _subjects = [
    '智慧照明采购',
    '消防改造施工',
    '法律顾问服务',
    '机柜租赁',
    '补充医疗保险',
    '办公家具采购',
    '园区保洁服务',
    '软件定制开发',
  ];
  static const _customers = ['华东建设集团', '云启科技有限公司', '恒信律师事务所', '星河数据服务', '安康保险经纪', '木本家居'];
  static const _owners = ['张伟', '李静', '王强', '赵敏', '陈晓'];

  @override
  Future<PageResult<Contract>> fetchPage({
    required int page,
    required int size,
    ContractStatus? status,
    CancelToken? cancelToken,
  }) async {
    await Future<void>.delayed(delay);
    final matched = [
      for (var i = 0; i < total; i++) _contract(i),
    ].where((c) => status == null || c.status == status).toList();
    final start = ((page - 1) * size).clamp(0, matched.length);
    final end = (start + size).clamp(0, matched.length);
    return PageResult(items: matched.sublist(start, end), hasMore: end < matched.length);
  }

  @override
  Future<Contract> fetchDetail(String id, {CancelToken? cancelToken}) async {
    await Future<void>.delayed(delay);
    // id 来自路由参数，可能是任意内容：像真实后端一样返回“不存在”，而不是让解析抛异常
    final i = int.tryParse(id);
    if (i == null || i < 0 || i >= total) {
      throw const ApiException(ApiErrorType.business, '合同不存在');
    }
    return _contract(i, detail: true);
  }

  Contract _contract(int i, {bool detail = false}) {
    final status = ContractStatus.values[i % ContractStatus.values.length];
    final signDate = DateTime(2025, 6, 28).subtract(Duration(days: i * 3));
    return Contract(
      id: '$i',
      title:
          '${_customers[i % _customers.length].substring(0, 2)}${_subjects[i % _subjects.length]}合同',
      customer: _customers[i % _customers.length],
      amount: 36000.0 + (i * 7919 % 97) * 12500,
      status: status,
      owner: _owners[i % _owners.length],
      signDate: signDate,
      remark: detail
          ? '合同约定分三期付款：签订后 7 个工作日内支付 30%，验收合格后支付 60%，'
                '质保期满无质量问题支付剩余 10%。如遇不可抗力导致延期，双方应在 5 个工作日内书面确认新的交付计划。'
          : '',
      flow: detail ? _flow(status, signDate) : const [],
    );
  }

  List<FlowStep> _flow(ContractStatus status, DateTime start) {
    final rejected = status == ContractStatus.rejected;
    final pending = status == ContractStatus.pending;
    return [
      FlowStep(title: '提交申请', operator: '经办人', state: FlowState.done, time: start),
      FlowStep(
        title: '部门审批',
        operator: '部门负责人',
        state: FlowState.done,
        time: start.add(const Duration(hours: 5)),
      ),
      FlowStep(
        title: '法务审核',
        operator: '法务部',
        state: rejected ? FlowState.rejected : (pending ? FlowState.current : FlowState.done),
        time: pending ? null : start.add(const Duration(days: 1, hours: 2)),
      ),
      FlowStep(
        title: '签署生效',
        operator: '总经理',
        state: pending || rejected ? FlowState.waiting : FlowState.done,
        time: pending || rejected ? null : start.add(const Duration(days: 2)),
      ),
    ];
  }
}
