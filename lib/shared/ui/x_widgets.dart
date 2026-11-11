import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:xjj_app_base/core/theme/x_theme.dart';
import 'package:xjj_app_base/core/utils/context_ext.dart';
import 'package:xjj_app_base/shared/ui/x_button.dart';

/// 角标：在 [child] 右上角显示红点或数字。
///
/// ```dart
/// XBadge(count: unread, child: const Icon(Icons.notifications_outlined))
/// XBadge(dot: hasNew, child: const Text('消息'))
/// ```
///
/// [count] 为 0 且 [dot] 为 false 时不显示；超过 [max] 显示 `99+`。
class XBadge extends StatelessWidget {
  const XBadge({
    super.key,
    required this.child,
    this.count = 0,
    this.dot = false,
    this.max = 99,
    this.color,
    this.offset = Offset.zero,
  });

  final Widget child;
  final int count;

  /// 只显示红点，不显示数字
  final bool dot;
  final int max;

  /// 背景色，默认红色
  final Color? color;

  /// 位置微调，x 向右为正，y 向下为正
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    if (!dot && count <= 0) return child;
    final color = this.color ?? context.xColors.danger;
    final Widget badge = dot
        ? Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          )
        : Container(
            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            alignment: Alignment.center,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
            child: Text(
              count > max ? '$max+' : '$count',
              style: const TextStyle(color: Colors.white, fontSize: 10, height: 1.2),
            ),
          );
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: (dot ? -2 : -6) + offset.dy,
          right: (dot ? -2 : -8) - offset.dx,
          child: IgnorePointer(child: badge),
        ),
      ],
    );
  }
}

/// 验证码倒计时按钮。[onSend] 成功（不抛异常）后开始倒计时，失败自动 toast、不倒计时。
///
/// ```dart
/// XFormItem.input(
///   label: '验证码',
///   trailing: XCountdownButton(onSend: () => repo.sendCode(phone)),
/// )
/// ```
///
/// 手机号没填等不该发送的情况，在 [onSend] 里抛异常或把 [onSend] 传 null（禁用）。
class XCountdownButton extends StatefulWidget {
  const XCountdownButton({
    super.key,
    required this.onSend,
    this.seconds = 60,
    this.text = '获取验证码',
    this.resendText = '重新获取',
    this.countingText,
  });

  /// 发送验证码的请求；为 null 时按钮禁用
  final Future<void> Function()? onSend;
  final int seconds;
  final String text;

  /// 倒计时结束后的文字
  final String resendText;

  /// 倒计时中的文字，默认 `59s`
  final String Function(int seconds)? countingText;

  @override
  State<XCountdownButton> createState() => _XCountdownButtonState();
}

class _XCountdownButtonState extends State<XCountdownButton> {
  Timer? _timer;

  // 记结束时刻而不是剩余秒数：App 切到后台再回来，倒计时仍然准确
  DateTime? _endAt;
  bool _sent = false;

  int get _remaining {
    final end = _endAt;
    if (end == null) return 0;
    final ms = end.difference(clock.now()).inMilliseconds;
    return ms <= 0 ? 0 : (ms / 1000).ceil();
  }

  Future<void> _send() async {
    await widget.onSend!();
    if (!mounted) return;
    _sent = true;
    _endAt = clock.now().add(Duration(seconds: widget.seconds));
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remaining == 0) {
        timer.cancel();
        _endAt = null;
      }
      setState(() {});
    });
    setState(() {});
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remaining = _remaining;
    final counting = remaining > 0;
    final label = counting
        ? (widget.countingText?.call(remaining) ?? '${remaining}s')
        : (_sent ? widget.resendText : widget.text);
    return XButton.text(
      label,
      size: XButtonSize.small,
      onPressed: counting || widget.onSend == null ? null : _send,
    );
  }
}

/// 数量步进器：− 数字 ＋。
///
/// ```dart
/// XStepper(value: count, min: 1, max: stock, onChanged: (v) => setState(() => count = v))
/// ```
class XStepper extends StatelessWidget {
  const XStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 999,
    this.step = 1,
  });

  final int value;

  /// 为 null 时禁用
  final ValueChanged<int>? onChanged;
  final int min;
  final int max;
  final int step;

  @override
  Widget build(BuildContext context) {
    final c = context.xColors;
    final enabled = onChanged != null;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepButton(
          icon: Icons.remove,
          onTap: enabled && value - step >= min ? () => onChanged!(value - step) : null,
        ),
        Container(
          constraints: const BoxConstraints(minWidth: 40),
          height: 28,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(horizontal: Insets.xs),
          alignment: Alignment.center,
          color: c.background,
          child: Text(
            '$value',
            style: TextStyle(fontSize: FontSizes.body, color: enabled ? c.text : c.textHint),
          ),
        ),
        _StepButton(
          icon: Icons.add,
          onTap: enabled && value + step <= max ? () => onChanged!(value + step) : null,
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.xColors;
    return Material(
      color: c.background,
      child: InkWell(
        onTap: onTap,
        child: SizedBox.square(
          dimension: 28,
          child: Icon(icon, size: 16, color: onTap == null ? c.border : c.text),
        ),
      ),
    );
  }
}

/// 可展开的长文本：超过 [maxLines] 行时折叠，末尾显示“展开 / 收起”。
///
/// ```dart
/// XExpandableText(article.content, maxLines: 3)
/// ```
class XExpandableText extends StatefulWidget {
  const XExpandableText(
    this.text, {
    super.key,
    this.maxLines = 3,
    this.style,
    this.expandText = '展开',
    this.collapseText = '收起',
  });

  final String text;
  final int maxLines;

  /// 默认 14 号正文色
  final TextStyle? style;
  final String expandText;
  final String collapseText;

  @override
  State<XExpandableText> createState() => _XExpandableTextState();
}

class _XExpandableTextState extends State<XExpandableText> {
  bool _expanded = false;
  late final _tap = TapGestureRecognizer()..onTap = _toggle;

  void _toggle() => setState(() => _expanded = !_expanded);

  @override
  void dispose() {
    _tap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style =
        widget.style ??
        TextStyle(fontSize: FontSizes.body, color: context.xColors.text, height: 1.5);
    final linkStyle = style.copyWith(color: context.colors.primary);
    final direction = Directionality.of(context);
    final scaler = MediaQuery.textScalerOf(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        TextPainter measure(InlineSpan span) => TextPainter(
          text: span,
          textDirection: direction,
          textScaler: scaler,
          maxLines: widget.maxLines,
        )..layout(maxWidth: constraints.maxWidth);

        final full = measure(TextSpan(text: widget.text, style: style));
        final overflow = full.didExceedMaxLines;
        full.dispose();
        if (!overflow) return Text(widget.text, style: style);

        if (_expanded) {
          return Text.rich(
            TextSpan(
              style: style,
              children: [
                TextSpan(text: widget.text),
                TextSpan(text: ' ${widget.collapseText}', style: linkStyle, recognizer: _tap),
              ],
            ),
          );
        }

        // 二分找出最多能放多少个字，给“… 展开”留出位置
        final chars = widget.text.characters;
        var low = 0;
        var high = chars.length;
        while (low < high) {
          final mid = (low + high + 1) ~/ 2;
          final painter = measure(
            TextSpan(
              style: style,
              children: [
                TextSpan(text: '${chars.take(mid)}…'),
                TextSpan(text: ' ${widget.expandText}', style: linkStyle),
              ],
            ),
          );
          final fits = !painter.didExceedMaxLines;
          painter.dispose();
          if (fits) {
            low = mid;
          } else {
            high = mid - 1;
          }
        }
        return Text.rich(
          TextSpan(
            style: style,
            children: [
              TextSpan(text: '${chars.take(low)}…'),
              TextSpan(text: ' ${widget.expandText}', style: linkStyle, recognizer: _tap),
            ],
          ),
        );
      },
    );
  }
}

/// 骨架屏占位块，带呼吸动画。用几个拼出内容的大致形状，代替整页转圈。
///
/// ```dart
/// Row(children: [
///   const XSkeleton.circle(size: 40),
///   const SizedBox(width: 12),
///   Expanded(child: Column(children: const [XSkeleton(), SizedBox(height: 8), XSkeleton(width: 120)])),
/// ])
/// ```
class XSkeleton extends StatefulWidget {
  const XSkeleton({super.key, this.width, this.height = 16, this.radius = Radii.sm})
    : _circle = false;

  const XSkeleton.circle({super.key, double size = 40})
    : width = size,
      height = size,
      radius = 0,
      _circle = true;

  /// 不传时撑满父容器宽度
  final double? width;
  final double height;
  final double radius;
  final bool _circle;

  @override
  State<XSkeleton> createState() => _XSkeletonState();
}

class _XSkeletonState extends State<XSkeleton> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 1, end: 0.4).animate(_controller),
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: context.xColors.divider,
          shape: widget._circle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: widget._circle ? null : BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}
