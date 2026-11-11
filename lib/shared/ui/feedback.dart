import 'dart:async';

import 'package:flutter/material.dart';
import 'package:xjj_app_base/core/network/api_exception.dart';
import 'package:xjj_app_base/core/theme/app_theme.dart';

/// 根 Navigator 的 key，让 toast、弹窗、底部弹层在任何地方都能调用（包括 Notifier 里）。
final rootNavigatorKey = GlobalKey<NavigatorState>();

OverlayState? get _overlay => rootNavigatorKey.currentState?.overlay;

/// 居中的黑底轻提示。新的会顶掉旧的。
///
/// ```dart
/// Toast.show('已复制');
/// Toast.success('保存成功');
/// Toast.error(e); // 直接传异常
/// ```
abstract final class Toast {
  static OverlayEntry? _current;

  static void show(String message, {IconData? icon}) {
    final overlay = _overlay;
    if (overlay == null) return;
    final previous = _current;
    if (previous != null && previous.mounted) previous.remove();
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _ToastView(
        message: message,
        icon: icon,
        onDismiss: () {
          if (_current == entry) _current = null;
          if (entry.mounted) entry.remove();
        },
      ),
    );
    _current = entry;
    overlay.insert(entry);
  }

  static void success(String message) => show(message, icon: Icons.check_circle_outline);

  /// 直接传异常，自动转成可读文案。主动取消的请求不提示。
  static void error(Object error) {
    final e = ApiException.from(error);
    if (e.type == ApiErrorType.cancel) return;
    show(e.message, icon: Icons.error_outline);
  }
}

class _ToastView extends StatefulWidget {
  const _ToastView({required this.message, required this.onDismiss, this.icon});

  final String message;
  final IconData? icon;
  final VoidCallback onDismiss;

  @override
  State<_ToastView> createState() => _ToastViewState();
}

class _ToastViewState extends State<_ToastView> {
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 2), widget.onDismiss);
  }

  @override
  void dispose() {
    _timer.cancel(); // 定时器跟随组件生命周期，页面销毁时不会残留
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 150),
          builder: (_, v, child) => Opacity(opacity: v, child: child),
          child: _DarkBox(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, color: Colors.white, size: 32),
                  const SizedBox(height: Insets.sm),
                ],
                Text(
                  widget.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: FontSizes.body),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DarkBox extends StatelessWidget {
  const _DarkBox({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.8),
      borderRadius: BorderRadius.circular(Radii.md),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 260, minWidth: 100),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Insets.lg, vertical: Insets.md),
          child: child,
        ),
      ),
    );
  }
}

/// 全屏 loading 遮罩（拦截点击），跟随 [task] 自动关闭；异常也会关闭，并继续抛出。
///
/// ```dart
/// await withLoading(() => repo.save(form), message: '提交中');
/// ```
Future<T> withLoading<T>(Future<T> Function() task, {String? message}) async {
  final entry = OverlayEntry(
    builder: (_) => ColoredBox(
      color: Colors.transparent,
      child: Center(
        child: _DarkBox(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(Insets.sm),
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
              ),
              if (message != null) ...[
                const SizedBox(height: Insets.sm),
                Text(message, style: const TextStyle(color: Colors.white)),
              ],
            ],
          ),
        ),
      ),
    ),
  );
  final overlay = _overlay;
  if (overlay == null) return task();
  overlay.insert(entry);
  try {
    return await task();
  } finally {
    entry
      ..remove()
      ..dispose();
  }
}

abstract final class AppDialog {
  /// 确认框，点“确定”返回 true
  static Future<bool> confirm({
    required String content,
    String? title,
    String confirmText = '确定',
    String cancelText = '取消',
    bool danger = false,
  }) async {
    final result = await _show<bool>(
      title: title,
      content: content,
      actions: (context) => [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(cancelText)),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: danger
              ? TextButton.styleFrom(
                  foregroundColor: Theme.of(context).extension<AppColors>()!.danger,
                )
              : null,
          child: Text(confirmText),
        ),
      ],
    );
    return result ?? false;
  }

  /// 提示框，只有一个按钮
  static Future<void> alert({required String content, String? title, String buttonText = '知道了'}) {
    return _show<void>(
      title: title,
      content: content,
      actions: (context) => [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(buttonText)),
      ],
    );
  }

  static Future<T?> _show<T>({
    required String content,
    required List<Widget> Function(BuildContext context) actions,
    String? title,
  }) async {
    final context = rootNavigatorKey.currentContext;
    if (context == null) return null;
    return showDialog<T>(
      context: context,
      builder: (context) => AlertDialog(
        title: title == null ? null : Text(title, textAlign: TextAlign.center),
        content: Text(content, textAlign: title == null ? TextAlign.center : TextAlign.start),
        actionsAlignment: MainAxisAlignment.spaceAround,
        actions: actions(context),
      ),
    );
  }
}
