import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xjj_app_base/core/network/api_client.dart';
import 'package:xjj_app_base/features/message/data/message.dart';
import 'package:xjj_app_base/shared/pagination.dart';

abstract interface class MessageRepository {
  Future<PageResult<Message>> fetchPage({
    required int page,
    required int size,
    CancelToken? cancelToken,
  });
  Future<void> markRead(String id);
  Future<void> markAllRead();
  Future<void> delete(String id);
}

/// 接入真实后端：`ApiMessageRepository(ref.watch(apiClientProvider))`
final messageRepositoryProvider = Provider<MessageRepository>((ref) => FakeMessageRepository());

class ApiMessageRepository implements MessageRepository {
  ApiMessageRepository(this._api);

  final ApiClient _api;

  @override
  Future<PageResult<Message>> fetchPage({
    required int page,
    required int size,
    CancelToken? cancelToken,
  }) {
    return _api.get(
      '/messages',
      cancelToken: cancelToken,
      query: {'page': page, 'size': size},
      decode: (data) {
        final map = data! as Map<String, dynamic>;
        final list = (map['list'] as List<dynamic>).cast<Map<String, dynamic>>();
        return PageResult(
          items: list.map(Message.fromJson).toList(),
          hasMore: page * size < (map['total'] as int),
        );
      },
    );
  }

  @override
  Future<void> markRead(String id) => _api.post('/messages/$id/read');

  @override
  Future<void> markAllRead() => _api.post('/messages/read-all');

  @override
  Future<void> delete(String id) => _api.delete('/messages/$id');
}

/// 演示用假数据，共 [total] 条，前 4 条未读。已读和删除会记下来，下拉刷新后保持。
class FakeMessageRepository implements MessageRepository {
  FakeMessageRepository({this.total = 26, this.delay = const Duration(milliseconds: 500)});

  final int total;
  final Duration delay;
  final _readIds = <String>{};
  final _deletedIds = <String>{};

  static const _samples = [
    (MessageType.approval, '你有一份合同待审批', '张伟提交了《华东智慧照明采购合同》，金额 ¥128,000.00，请在 3 个工作日内处理。'),
    (MessageType.system, '账号安全提醒', '你的账号于今天 09:12 在新设备上登录。如果不是本人操作，请立即修改密码。'),
    (MessageType.activity, '季度评优开始报名', '2025 年第二季度优秀团队评选已开始，报名截止到本月 20 日，欢迎各部门踊跃参与。'),
    (MessageType.approval, '合同审批已通过', '你提交的《年度法律顾问服务合同》已由法务部审核通过，进入签署环节。'),
    (MessageType.system, '系统维护通知', '本周六 02:00 - 04:00 进行系统升级，期间无法提交审批，请提前安排工作。'),
  ];

  @override
  Future<PageResult<Message>> fetchPage({
    required int page,
    required int size,
    CancelToken? cancelToken,
  }) async {
    await Future<void>.delayed(delay);
    final now = DateTime.now();
    final start = ((page - 1) * size).clamp(0, total);
    final end = (start + size).clamp(0, total);
    return PageResult(
      items: [
        for (var i = start; i < end; i++)
          // 删掉的直接从这一页里去掉，每页的起止位置不变：
          // 删除后再上拉加载，不会因为后面的数据往前挪而漏掉一条
          if (!_deletedIds.contains('$i'))
            Message(
              id: '$i',
              type: _samples[i % _samples.length].$1,
              title: _samples[i % _samples.length].$2,
              content: _samples[i % _samples.length].$3,
              time: now.subtract(Duration(minutes: 8 + i * i * 37)),
              read: i >= 4 || _readIds.contains('$i'),
            ),
      ],
      hasMore: end < total,
    );
  }

  @override
  Future<void> markRead(String id) async => _readIds.add(id);

  @override
  Future<void> markAllRead() async {
    await Future<void>.delayed(delay);
    _readIds.addAll([for (var i = 0; i < total; i++) '$i']);
  }

  @override
  Future<void> delete(String id) async => _deletedIds.add(id);
}
