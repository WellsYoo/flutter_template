import 'package:flutter/material.dart';
import 'package:xjj_app_base/core/theme/app_theme.dart';
import 'package:xjj_app_base/core/utils/context_ext.dart';

/// 白底圆角卡片，可点击。
///
/// ```dart
/// AppCard(
///   onTap: () => context.push(Routes.orderDetail(id)),
///   child: Column(children: [...]),
/// )
/// ```
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(Insets.lg),
    this.margin = EdgeInsets.zero,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// “标签：值”一行，常用于列表卡片和详情页。
///
/// ```dart
/// InfoRow('合同编号', contract.no)
/// InfoRow('金额', Fmt.money(amount), valueColor: context.appColors.danger)
/// ```
class InfoRow extends StatelessWidget {
  const InfoRow(
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
    final c = context.appColors;
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

enum TagType { primary, success, warning, danger, gray }

/// 状态标签：浅色底 + 同色字。
///
/// ```dart
/// AppTag('待审核', type: TagType.warning)
/// ```
class AppTag extends StatelessWidget {
  const AppTag(this.text, {super.key, this.type = TagType.primary});

  final String text;
  final TagType type;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final color = switch (type) {
      TagType.primary => context.colors.primary,
      TagType.success => c.success,
      TagType.warning => c.warning,
      TagType.danger => c.danger,
      TagType.gray => c.textSecondary,
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(Radii.sm),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Text(
          text,
          style: TextStyle(fontSize: FontSizes.caption, color: color),
        ),
      ),
    );
  }
}

/// 页面底部操作栏：自动处理安全区，多个按钮等分宽度。
/// 放在 `Scaffold.bottomNavigationBar`。
///
/// ```dart
/// bottomNavigationBar: BottomBar(children: [
///   AppButton.outline('保存草稿', onPressed: _saveDraft),
///   AppButton.primary('提交', onPressed: _submit),
/// ]),
/// ```
class BottomBar extends StatelessWidget {
  const BottomBar({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
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
