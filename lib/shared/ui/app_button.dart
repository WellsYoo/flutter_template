import 'dart:async';

import 'package:flutter/material.dart';
import 'package:xjj_app_base/core/theme/app_theme.dart';
import 'package:xjj_app_base/core/utils/context_ext.dart';
import 'package:xjj_app_base/shared/ui/feedback.dart';

enum ButtonSize {
  small(32, FontSizes.secondary, Insets.md),
  medium(40, FontSizes.body, Insets.lg),
  large(48, FontSizes.title, Insets.xl);

  const ButtonSize(this.height, this.fontSize, this.padding);

  final double height;
  final double fontSize;
  final double padding;
}

enum _ButtonKind { primary, outline, text, danger }

/// 按钮。[onPressed] 返回 Future 时自动显示 loading、防重复点击，异常自动 toast。
///
/// ```dart
/// AppButton.primary('提交', block: true, onPressed: () => repo.submit(form))
/// AppButton.outline('取消', size: ButtonSize.small, onPressed: () => context.pop())
/// AppButton.danger('删除', onPressed: _delete)
/// ```
///
/// [onPressed] 为 null 时禁用。
///
/// 注意：只有“等接口返回”才应该返回 Future。弹确认框、跳转页面等等待用户操作的场景，
/// 返回 Future 会让按钮在弹窗期间一直转圈，写成 `() => unawaited(_confirm())`。
class AppButton extends StatefulWidget {
  const AppButton.primary(
    this.label, {
    super.key,
    required this.onPressed,
    this.size = ButtonSize.large,
    this.block = false,
    this.icon,
  }) : _kind = _ButtonKind.primary;

  const AppButton.outline(
    this.label, {
    super.key,
    required this.onPressed,
    this.size = ButtonSize.large,
    this.block = false,
    this.icon,
  }) : _kind = _ButtonKind.outline;

  const AppButton.text(
    this.label, {
    super.key,
    required this.onPressed,
    this.size = ButtonSize.medium,
    this.block = false,
    this.icon,
  }) : _kind = _ButtonKind.text;

  const AppButton.danger(
    this.label, {
    super.key,
    required this.onPressed,
    this.size = ButtonSize.large,
    this.block = false,
    this.icon,
  }) : _kind = _ButtonKind.danger;

  final String label;
  final FutureOr<void> Function()? onPressed;
  final ButtonSize size;

  /// 撑满父容器宽度
  final bool block;
  final IconData? icon;
  final _ButtonKind _kind;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _loading = false;

  Future<void> _handlePressed() async {
    if (_loading) return;
    final result = widget.onPressed!();
    if (result is! Future) return;

    setState(() => _loading = true);
    try {
      await result;
    } catch (e) {
      Toast.error(e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final style = ButtonStyle(
      minimumSize: WidgetStatePropertyAll(Size(widget.block ? double.infinity : 0, size.height)),
      padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: size.padding)),
      textStyle: WidgetStatePropertyAll(
        TextStyle(fontSize: size.fontSize, fontWeight: FontWeight.w500),
      ),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.standard,
    );
    final onPressed = widget.onPressed == null ? null : _handlePressed;
    final child = _content(context);

    return switch (widget._kind) {
      _ButtonKind.primary => FilledButton(onPressed: onPressed, style: style, child: child),
      _ButtonKind.danger => FilledButton(
        onPressed: onPressed,
        style: style.merge(FilledButton.styleFrom(backgroundColor: context.appColors.danger)),
        child: child,
      ),
      _ButtonKind.outline => OutlinedButton(onPressed: onPressed, style: style, child: child),
      _ButtonKind.text => TextButton(onPressed: onPressed, style: style, child: child),
    };
  }

  Widget _content(BuildContext context) {
    if (_loading) {
      final color = switch (widget._kind) {
        _ButtonKind.primary || _ButtonKind.danger => Colors.white,
        _ => context.colors.primary,
      };
      final d = widget.size.fontSize + 4;
      return SizedBox.square(
        dimension: d,
        child: CircularProgressIndicator(strokeWidth: 2, color: color),
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
