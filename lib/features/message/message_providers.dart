import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xjj_app_base/core/network/api_client.dart';
import 'package:xjj_app_base/features/message/data/message.dart';
import 'package:xjj_app_base/features/message/data/message_repository.dart';
import 'package:xjj_app_base/shared/pagination.dart';

final messageListProvider =
    AsyncNotifierProvider.autoDispose<MessageListNotifier, PagedState<Message>>(
      MessageListNotifier.new,
    );

/// 列表里的增删改：请求成功后用 `updateItems` 直接改本地列表，不重新拉整页，
/// 滚动位置和已加载的页数都保持不变。
class MessageListNotifier extends PagedNotifier<Message> {
  MessageRepository get _repo => ref.read(messageRepositoryProvider);

  @override
  Future<PageResult<Message>> fetchPage(int page) =>
      _repo.fetchPage(page: page, size: pageSize, cancelToken: ref.cancelToken());

  /// 标记已读。先改界面再发请求（乐观更新）：已读失败不影响使用，不用回滚。
  void markRead(Message message) {
    if (message.read) return;
    updateItems(
      (items) => [
        for (final m in items)
          if (m.id == message.id) m.copyWith(read: true) else m,
      ],
    );
    unawaited(_repo.markRead(message.id).catchError((_) {}));
  }

  /// 全部已读。等接口成功后再改界面，失败时异常抛给调用方提示。
  Future<void> markAllRead() async {
    await _repo.markAllRead();
    if (!ref.mounted) return;
    updateItems((items) => [for (final m in items) m.copyWith(read: true)]);
  }

  /// 删除。乐观更新，失败时把这一条放回原位置并抛出异常。
  Future<void> delete(Message message) async {
    final index = state.value?.items.indexWhere((m) => m.id == message.id) ?? -1;
    if (index < 0) return;
    updateItems((items) => [...items]..removeAt(index));
    try {
      await _repo.delete(message.id);
    } catch (_) {
      if (ref.mounted) {
        updateItems((items) => [...items]..insert(index.clamp(0, items.length), message));
      }
      rethrow;
    }
  }
}
