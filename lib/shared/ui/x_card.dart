import 'package:flutter/material.dart';
import 'package:xjj_app_base/core/theme/x_theme.dart';
import 'package:xjj_app_base/core/utils/context_ext.dart';

/// 白底圆角卡片，可点击。
///
/// ```dart
/// XCard(
///   onTap: () => context.push(Routes.orderDetail(id)),
///   child: Column(children: [...]),
/// )
/// XCard(radius: 4, border: true, padding: EdgeInsets.zero, child: ...)
/// ```
class XCard extends StatelessWidget {
  const XCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.padding = const EdgeInsets.all(Insets.lg),
    this.margin = EdgeInsets.zero,
    this.color,
    this.radius,
    this.border = false,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  /// 背景色，默认卡片白
  final Color? color;

  /// 圆角，默认跟主题
  final double? radius;

  /// 显示 0.5 的描边
  final bool border;

  static BorderRadiusGeometry _themeRadius(BuildContext context) {
    final shape = context.theme.cardTheme.shape;
    return shape is RoundedRectangleBorder ? shape.borderRadius : BorderRadius.circular(Radii.md);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: Card(
        color: color,
        clipBehavior: Clip.antiAlias,
        shape: radius == null && !border
            ? null
            : RoundedRectangleBorder(
                borderRadius: radius == null
                    ? _themeRadius(context)
                    : BorderRadius.circular(radius!),
                side: border
                    ? BorderSide(color: context.xColors.border, width: 0.5)
                    : BorderSide.none,
              ),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// “标签：值”一行，常用于列表卡片和详情页。
///
/// ```dart
/// XInfoRow('合同编号', contract.no)
/// XInfoRow('金额', Fmt.money(amount), valueColor: context.xColors.danger)
/// ```
class XInfoRow extends StatelessWidget {
  const XInfoRow(
    this.label,
    this.value, {
    super.key,
    this.labelWidth = 80,
    this.valueColor,
    this.maxLines,
  });

  final String label;
  final String? value;
  final double labelWidth;
  final Color? valueColor;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final c = context.xColors;
    final v = value == null || value!.isEmpty ? '--' : value!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Insets.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: labelWidth,
            child: Text(
              label,
              style: TextStyle(fontSize: FontSizes.secondary, color: c.textHint),
            ),
          ),
          Expanded(
            child: Text(
              v,
              maxLines: maxLines,
              overflow: maxLines == null ? null : TextOverflow.ellipsis,
              style: TextStyle(fontSize: FontSizes.secondary, color: valueColor ?? c.text),
            ),
          ),
        ],
      ),
    );
  }
}

enum XTagType { primary, success, warning, danger, gray }

/// 状态标签：浅色底 + 同色字。
///
/// ```dart
/// XTag('待审核', type: XTagType.warning)
/// XTag('VIP', color: Colors.purple, outlined: true)
/// ```
class XTag extends StatelessWidget {
  const XTag(
    this.text, {
    super.key,
    this.type = XTagType.primary,
    this.color,
    this.outlined = false,
    this.icon,
  });

  final String text;
  final XTagType type;

  /// 自定义颜色，传了就不看 [type]
  final Color? color;

  /// 描边样式（透明底 + 边框）
  final bool outlined;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = context.xColors;
    final color =
        this.color ??
        switch (type) {
          XTagType.primary => context.colors.primary,
          XTagType.success => c.success,
          XTagType.warning => c.warning,
          XTagType.danger => c.danger,
          XTagType.gray => c.textSecondary,
        };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: outlined ? null : color.withValues(alpha: 0.1),
        border: outlined ? Border.all(color: color, width: 0.5) : null,
        borderRadius: BorderRadius.circular(Radii.sm),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: FontSizes.caption, color: color),
              const SizedBox(width: 2),
            ],
            Text(
              text,
              style: TextStyle(fontSize: FontSizes.caption, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

/// 页面底部操作栏：自动处理安全区，多个按钮等分宽度。
/// 放在 `Scaffold.bottomNavigationBar`。
///
/// ```dart
/// bottomNavigationBar: XBottomBar(children: [
///   XButton.outline('保存草稿', onPressed: _saveDraft),
///   XButton.primary('提交', onPressed: _submit),
/// ]),
/// ```
class XBottomBar extends StatelessWidget {
  const XBottomBar({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final c = context.xColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.card,
        border: Border(top: BorderSide(color: c.divider, width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: Insets.sm),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Insets.lg, Insets.sm, Insets.lg, 0),
          child: Row(
            spacing: Insets.md,
            children: [for (final child in children) Expanded(child: child)],
          ),
        ),
      ),
    );
  }
}
