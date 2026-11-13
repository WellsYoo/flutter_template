import 'package:flutter/material.dart';
import 'package:xjj_app_base/shared/ui/ui.dart';

class QuickAction {
  const QuickAction(this.label, this.icon, this.color, this.onTap);

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
}

/// 快捷入口宫格：一行 4 个，浅色底图标 + 文字。
class QuickActions extends StatelessWidget {
  const QuickActions({super.key, required this.actions, this.columns = 4});

  final List<QuickAction> actions;
  final int columns;

  @override
  Widget build(BuildContext context) {
    return XCard(
      padding: const XPad.hv(8, 16),
      child: Column(
        spacing: 16,
        children: [
          for (final row in actions.chunked(columns))
            Row(
              children: [
                for (final action in row) Expanded(child: _Item(action)),
                // 最后一行不满时补空位，保持对齐
                for (var i = row.length; i < columns; i++) const Spacer(),
              ],
            ),
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item(this.action);

  final QuickAction action;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: action.onTap,
      child: Column(
        children: [
          XContainer(
            size: 46,
            radius: 15,
            color: action.color.withValues(alpha: 0.12),
            alignment: Alignment.center,
            child: Icon(action.icon, size: 23, color: action.color),
          ),
          XGap.v8,
          XText.caption(action.label, color: context.xColors.textSecondary, maxLines: 1),
        ],
      ),
    );
  }
}
