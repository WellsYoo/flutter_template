import 'package:flutter/material.dart';
import 'package:xjj_app_base/core/theme/x_theme.dart';
import 'package:xjj_app_base/core/utils/context_ext.dart';

/// 列表行：设置页、个人中心的“图标 + 标题 + 右侧值 + 箭头”。放在 XFormSection 里自动加分割线。
///
/// ```dart
/// XFormSection(children: [
///   XCell('消息通知', icon: Icons.notifications_outlined, onTap: _openNotice),
///   XCell('缓存', value: '12.3 MB', onTap: _clearCache),
///   XCell('版本', value: '1.0.0'),
///   XCell('自动更新', trailing: Switch(value: auto, onChanged: _setAuto)),
/// ])
/// ```
class XCell extends StatelessWidget {
  const XCell(
    this.title, {
    super.key,
    this.subtitle,
    this.value,
    this.icon,
    this.iconColor,
    this.leading,
    this.trailing,
    this.valueColor,
    this.onTap,
    this.arrow,
  });

  final String title;

  /// 标题下方的说明文字
  final String? subtitle;

  /// 右侧文字
  final String? value;
  final Color? valueColor;

  /// 左侧图标；需要图片等自定义内容时用 [leading]
  final IconData? icon;
  final Color? iconColor;
  final Widget? leading;

  /// 右侧自定义内容（开关、标签、红点等），显示在 [value] 之后
  final Widget? trailing;
  final VoidCallback? onTap;

  /// 是否显示右箭头，默认可点击时显示
  final bool? arrow;

  @override
  Widget build(BuildContext context) {
    final c = context.xColors;
    final leading = this.leading ?? (icon == null ? null : Icon(icon, size: 22, color: iconColor));
    return Material(
      color: c.card,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 52),
          child: Padding(
            padding: const XPad.hv(16, 12),
            child: Row(
              children: [
                if (leading != null) ...[
                  IconTheme.merge(
                    data: IconThemeData(color: c.textSecondary),
                    child: leading,
                  ),
                  XGap.h12,
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: TextStyle(fontSize: FontSizes.body, color: c.text),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: TextStyle(fontSize: FontSizes.caption, color: c.textHint),
                        ),
                      ],
                    ],
                  ),
                ),
                if (value != null) ...[
                  XGap.h12,
                  // 不参与弹性分配：按内容宽度贴右边，最宽占一半多一点，标题拿剩下的
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: context.screenSize.width * 0.55),
                    child: Text(
                      value!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: FontSizes.body,
                        color: valueColor ?? c.textSecondary,
                      ),
                    ),
                  ),
                ],
                if (trailing != null) ...[XGap.h8, trailing!],
                if (arrow ?? onTap != null) ...[
                  XGap.h4,
                  Icon(Icons.chevron_right, size: 20, color: c.textHint),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
