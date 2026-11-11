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
            padding: const EdgeInsets.symmetric(horizontal: Insets.lg, vertical: Insets.md),
            child: Row(
              children: [
                if (leading != null) ...[
                  IconTheme.merge(
                    data: IconThemeData(color: c.textSecondary),
                    child: leading,
                  ),
                  const SizedBox(width: Insets.md),
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
                  const SizedBox(width: Insets.md),
                  Flexible(
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
                if (trailing != null) ...[const SizedBox(width: Insets.sm), trailing!],
                if (arrow ?? onTap != null) ...[
                  const SizedBox(width: Insets.xs),
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
