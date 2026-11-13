import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xjj_app_base/features/message/data/message.dart';
import 'package:xjj_app_base/features/message/message_providers.dart';
import 'package:xjj_app_base/shared/ui/ui.dart';

/// 消息列表：左滑删除、点击标记已读、全部已读。演示列表项的本地增删改。
class MessagePage extends ConsumerWidget {
  const MessagePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(messageListProvider.notifier);
    final unread = ref.watch(
      messageListProvider.select((s) => s.value?.items.where((m) => !m.read).length ?? 0),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(unread > 0 ? '消息 ($unread)' : '消息'),
        actions: [
          XButton.text(
            '全部已读',
            color: context.xColors.textSecondary,
            // 没有未读时禁用
            onPressed: unread > 0 ? notifier.markAllRead : null,
          ),
        ],
      ),
      body: XPagedListView(
        provider: messageListProvider,
        padding: XPad.v8,
        separator: const SizedBox.shrink(),
        empty: const XEmptyView(icon: Icons.notifications_none_rounded, message: '暂时没有消息'),
        itemBuilder: (context, message, _) => _MessageTile(
          // 左滑删除的行必须有稳定的 key
          key: ValueKey(message.id),
          message: message,
          onTap: () {
            notifier.markRead(message);
            unawaited(XDialog.alert(title: message.title, content: message.content));
          },
          onDelete: () async {
            try {
              await notifier.delete(message);
              XToast.show('已删除');
            } catch (e) {
              XToast.error(e);
            }
          },
        ),
      ),
    );
  }
}

class _MessageTile extends StatelessWidget {
  const _MessageTile({
    super.key,
    required this.message,
    required this.onTap,
    required this.onDelete,
  });

  final Message message;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final c = context.xColors;
    final (icon, color) = switch (message.type) {
      MessageType.approval => (Icons.assignment_turned_in_rounded, context.primary),
      MessageType.system => (Icons.shield_rounded, c.warning),
      MessageType.activity => (Icons.celebration_rounded, c.success),
    };

    return Dismissible(
      key: ValueKey(message.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        color: c.danger,
        alignment: Alignment.centerRight,
        padding: XPad.h24,
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      child: Material(
        color: c.card,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const XPad.hv(16, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                XBadge(
                  dot: !message.read,
                  child: XContainer(
                    size: 42,
                    radius: 14,
                    color: color.withValues(alpha: 0.12),
                    alignment: Alignment.center,
                    child: Icon(icon, size: 21, color: color),
                  ),
                ),
                XGap.h12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: XText.body(
                              message.title,
                              maxLines: 1,
                              // 未读加粗，已读变淡
                              weight: message.read ? FontWeights.regular : FontWeights.semibold,
                              color: message.read ? c.textSecondary : c.text,
                            ),
                          ),
                          XGap.h8,
                          XText.caption(Fmt.timeAgo(message.time)),
                        ],
                      ),
                      XGap.v4,
                      XText.secondary(message.content, maxLines: 2, color: c.textHint),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
