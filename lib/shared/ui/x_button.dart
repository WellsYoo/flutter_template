import 'dart:async';

import 'package:flutter/material.dart';
import 'package:xjj_app_base/core/theme/x_theme.dart';
import 'package:xjj_app_base/core/utils/context_ext.dart';
import 'package:xjj_app_base/shared/ui/x_feedback.dart';

enum XButtonSize {
  small(32, FontSizes.secondary, Insets.md),
  medium(40, FontSizes.body, Insets.lg),
  large(48, FontSizes.title, Insets.xl);

  const XButtonSize(this.height, this.fontSize, this.padding);

  final double height;
  final double fontSize;
  final double padding;
}

enum XButtonType {
  /// 实心主按钮
  primary,

  /// 描边按钮
  outline,

  /// 文字按钮
  text,

  /// 实心危险按钮（红色）
  danger,
}

/// 按钮。[onPressed] 返回 Future 时自动显示 loading、防重复点击，异常自动 toast。
///
/// ```dart
/// XButton.primary('提交', block: true, onPressed: () => repo.submit(form))
/// XButton.outline('取消', size: XButtonSize.small, onPressed: () => context.pop())
/// XButton.danger('删除', confirm: '删除后不可恢复，确定删除吗？', onPressed: _delete)
/// XButton.primary('领取', round: true, color: Colors.orange, width: 120, onPressed: _claim)
/// ```
///
/// [onPressed] 为 null 时禁用。
///
/// 注意：只有“等接口返回”才应该返回 Future。跳转页面等等待用户操作的场景，
/// 返回 Future 会让按钮一直转圈，写成 `() => unawaited(_open())`。
/// 二次确认用 [confirm]，确认框显示期间不会转圈。
class XButton extends StatefulWidget {
  const XButton(
    this.label, {
    super.key,
    required this.onPressed,
    this.type = XButtonType.primary,
    this.size = XButtonSize.large,
    this.block = false,
    this.icon,
    this.color,
    this.round = false,
    this.width,
    this.loading = false,
    this.confirm,
  });

  const XButton.primary(
    this.label, {
    super.key,
    required this.onPressed,
    this.size = XButtonSize.large,
    this.block = false,
    this.icon,
    this.color,
    this.round = false,
    this.width,
    this.loading = false,
    this.confirm,
  }) : type = XButtonType.primary;

  const XButton.outline(
    this.label, {
    super.key,
    required this.onPressed,
    this.size = XButtonSize.large,
    this.block = false,
    this.icon,
    this.color,
    this.round = false,
    this.width,
    this.loading = false,
    this.confirm,
  }) : type = XButtonType.outline;

  const XButton.text(
    this.label, {
    super.key,
    required this.onPressed,
    this.size = XButtonSize.medium,
    this.block = false,
    this.icon,
    this.color,
    this.round = false,
    this.width,
    this.loading = false,
    this.confirm,
  }) : type = XButtonType.text;

  const XButton.danger(
    this.label, {
    super.key,
    required this.onPressed,
    this.size = XButtonSize.large,
    this.block = false,
    this.icon,
    this.color,
    this.round = false,
    this.width,
    this.loading = false,
    this.confirm,
  }) : type = XButtonType.danger;

  final String label;
  final FutureOr<void> Function()? onPressed;
  final XButtonType type;
  final XButtonSize size;

  /// 撑满父容器宽度
  final bool block;

  /// 文字左侧的图标
  final IconData? icon;

  /// 主色：实心按钮是背景色，描边 / 文字按钮是文字和边框色。默认品牌色（danger 为红色）。
  final Color? color;

  /// 两端半圆（胶囊形）
  final bool round;

  /// 固定宽度；不传时按内容自适应
  final double? width;

  /// 由外部控制的 loading，例如 `loading: ref.watch(submitProvider).isLoading`。
  /// [onPressed] 返回 Future 时不需要传，会自动处理。
  final bool loading;

  /// 点击后先弹确认框，内容为这段文字，用户确认后才执行 [onPressed]
  final String? confirm;

  @override
  State<XButton> createState() => _XButtonState();
}

class _XButtonState extends State<XButton> {
  bool _running = false;

  bool get _loading => _running || widget.loading;
  bool get _filled => widget.type == XButtonType.primary || widget.type == XButtonType.danger;

  Future<void> _handlePressed() async {
    if (_loading) return;
    final confirm = widget.confirm;
    if (confirm != null) {
      final ok = await XDialog.confirm(content: confirm, danger: widget.type == XButtonType.danger);
      if (!ok || !mounted || _loading) return;
    }
    final result = widget.onPressed?.call();
    if (result is! Future) return;

    setState(() => _running = true);
    try {
      await result;
    } catch (e) {
      XToast.error(e);
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final color =
        widget.color ??
        (widget.type == XButtonType.danger ? context.xColors.danger : context.colors.primary);
    final base = ButtonStyle(
      minimumSize: WidgetStatePropertyAll(
        Size(widget.block ? double.infinity : widget.width ?? 0, size.height),
      ),
      padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: size.padding)),
      textStyle: WidgetStatePropertyAll(
        TextStyle(fontSize: size.fontSize, fontWeight: FontWeight.w500),
      ),
      // 不是胶囊形时用主题里的圆角（XTheme.create 的 radius）
      shape: widget.round ? const WidgetStatePropertyAll(StadiumBorder()) : null,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.standard,
    );
    final onPressed = widget.onPressed == null ? null : _handlePressed;
    final child = _content(_filled ? Colors.white : color);

    return switch (widget.type) {
      XButtonType.primary || XButtonType.danger => FilledButton(
        onPressed: onPressed,
        style: base.merge(
          FilledButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white),
        ),
        child: child,
      ),
      XButtonType.outline => OutlinedButton(
        onPressed: onPressed,
        style: base.merge(
          OutlinedButton.styleFrom(foregroundColor: color).copyWith(
            // 禁用时边框跟着变灰
            side: WidgetStateProperty.resolveWith(
              (states) => BorderSide(
                color: states.contains(WidgetState.disabled) ? context.xColors.border : color,
              ),
            ),
          ),
        ),
        child: child,
      ),
      XButtonType.text => TextButton(
        onPressed: onPressed,
        style: base.merge(TextButton.styleFrom(foregroundColor: color)),
        child: child,
      ),
    };
  }

  Widget _content(Color foreground) {
    if (_loading) {
      return SizedBox.square(
        dimension: widget.size.fontSize + 4,
        child: CircularProgressIndicator(strokeWidth: 2, color: foreground),
      );
    }
    if (widget.icon == null) return Text(widget.label);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(widget.icon, size: widget.size.fontSize + 2),
        const SizedBox(width: Insets.xs),
        Text(widget.label),
      ],
    );
  }
}
