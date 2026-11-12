import 'dart:async';

import 'package:flutter/material.dart';
import 'package:xjj_app_base/core/network/api_exception.dart';
import 'package:xjj_app_base/core/theme/x_theme.dart';
import 'package:xjj_app_base/core/utils/context_ext.dart';
import 'package:xjj_app_base/core/utils/logger.dart';

/// 根 Navigator 的 key，让 toast、弹窗、底部弹层在任何地方都能调用（包括 Notifier 里）。
final rootNavigatorKey = GlobalKey<NavigatorState>();

OverlayState? get _overlay => rootNavigatorKey.currentState?.overlay;

/// 居中的黑底轻提示。新的会顶掉旧的。
///
/// ```dart
/// XToast.show('已复制');
/// XToast.success('保存成功');
/// XToast.error(e); // 直接传异常
/// XToast.show('长一点的提示', duration: const Duration(seconds: 4), position: XToastPosition.bottom);
/// ```
///
/// 全局默认值改 [duration] / [position]。
abstract final class XToast {
  static OverlayEntry? _current;

  /// 默认显示时长
  static Duration duration = const Duration(seconds: 2);

  /// 默认位置
  static XToastPosition position = XToastPosition.center;

  static void show(String message, {IconData? icon, Duration? duration, XToastPosition? position}) {
    final overlay = _overlay;
    if (overlay == null) return;
    final previous = _current;
    if (previous != null && previous.mounted) previous.remove();
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _ToastView(
        message: message,
        icon: icon,
        duration: duration ?? XToast.duration,
        position: position ?? XToast.position,
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

  static void warning(String message) => show(message, icon: Icons.info_outline);

  /// 立即关闭当前 toast
  static void dismiss() {
    final current = _current;
    _current = null;
    if (current != null && current.mounted) current.remove();
  }

  /// 直接传异常，自动转成可读文案。主动取消的请求不提示。
  static void error(Object error) {
    final e = ApiException.from(error);
    if (e.type == ApiErrorType.cancel) return;
    // 接口异常有明确文案；其他异常多是代码 bug，提示之外还要留日志，否则问题被吞掉
    if (error is! ApiException) {
      Log.e('未预期的异常', error: error, tag: 'UI');
    }
    show(e.message, icon: Icons.error_outline);
  }
}

enum XToastPosition {
  top(Alignment(0, -0.7)),
  center(Alignment.center),
  bottom(Alignment(0, 0.7));

  const XToastPosition(this.alignment);

  final Alignment alignment;
}

class _ToastView extends StatefulWidget {
  const _ToastView({
    required this.message,
    required this.onDismiss,
    required this.duration,
    required this.position,
    this.icon,
  });

  final String message;
  final IconData? icon;
  final Duration duration;
  final XToastPosition position;
  final VoidCallback onDismiss;

  @override
  State<_ToastView> createState() => _ToastViewState();
}

class _ToastViewState extends State<_ToastView> {
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.duration, widget.onDismiss);
  }

  @override
  void dispose() {
    _timer.cancel(); // 定时器跟随组件生命周期，页面销毁时不会残留
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SafeArea(
        child: Align(
          alignment: widget.position.alignment,
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
                    XGap.v8,
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
      borderRadius: BorderRadius.circular(8),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 260, minWidth: 100),
        child: Padding(padding: const XPad.hv(16, 12), child: child),
      ),
    );
  }
}

/// 全屏 loading 遮罩，拦截点击。
///
/// ```dart
/// // 推荐：跟随任务自动关闭，异常也会关闭并继续抛出
/// await XLoading.run(() => repo.save(form), message: '提交中');
///
/// // 手动控制（跨多个步骤时）：show 和 hide 必须成对
/// XLoading.show('上传中 1/3');
/// XLoading.show('上传中 2/3'); // 再次 show 只更新文案
/// XLoading.hide();
/// ```
abstract final class XLoading {
  static OverlayEntry? _entry;
  static final _message = ValueNotifier<String?>(null);

  static bool get isShowing => _entry != null;

  static void show([String? message]) {
    _message.value = message;
    if (_entry != null) return;
    final overlay = _overlay;
    if (overlay == null) return;
    final entry = OverlayEntry(
      builder: (_) => ColoredBox(
        color: Colors.transparent,
        child: Center(
          child: _DarkBox(
            child: ValueListenableBuilder(
              valueListenable: _message,
              builder: (_, message, _) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: XPad.all8,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                  ),
                  if (message != null) ...[
                    XGap.v8,
                    Text(message, style: const TextStyle(color: Colors.white)),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
    _entry = entry;
    overlay.insert(entry);
  }

  static void hide() {
    final entry = _entry;
    _entry = null;
    if (entry == null) return;
    if (entry.mounted) entry.remove();
    entry.dispose();
  }

  /// 执行 [task] 期间显示 loading
  static Future<T> run<T>(Future<T> Function() task, {String? message}) async {
    show(message);
    try {
      return await task();
    } finally {
      hide();
    }
  }
}

/// 居中弹窗。全部返回 Future，不需要传 context。
///
/// ```dart
/// if (await XDialog.confirm(content: '确定退出登录吗？')) { ... }
/// await XDialog.alert(title: '提示', content: '您的账号将于 7 天后过期');
/// final name = await XDialog.input(title: '修改昵称', initialValue: user.name, maxLength: 12);
/// ```
abstract final class XDialog {
  /// 确认框，点“确定”返回 true
  static Future<bool> confirm({
    required String content,
    String? title,
    String confirmText = '确定',
    String cancelText = '取消',
    bool danger = false,

    /// 点击空白处 / 返回键能否关闭
    bool dismissible = true,
  }) async {
    final result = await _show<bool>(
      title: title,
      content: Text(content, textAlign: title == null ? TextAlign.center : TextAlign.start),
      dismissible: dismissible,
      actions: (context) => [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(cancelText)),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: danger ? TextButton.styleFrom(foregroundColor: context.xColors.danger) : null,
          child: Text(confirmText),
        ),
      ],
    );
    return result ?? false;
  }

  /// 提示框，只有一个按钮
  static Future<void> alert({
    required String content,
    String? title,
    String buttonText = '知道了',
    bool dismissible = true,
  }) {
    return _show<void>(
      title: title,
      content: Text(content, textAlign: title == null ? TextAlign.center : TextAlign.start),
      dismissible: dismissible,
      actions: (context) => [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(buttonText)),
      ],
    );
  }

  /// 输入框，点“确定”返回输入内容（已 trim），取消返回 null。
  /// [validator] 返回错误文案时不关闭，文案显示在输入框下方。
  static Future<String?> input({
    required String title,
    String? initialValue,
    String hint = '请输入',
    int? maxLength,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String value)? validator,
    String confirmText = '确定',
    String cancelText = '取消',
  }) {
    final controller = TextEditingController(text: initialValue);
    final error = ValueNotifier<String?>(null);
    return _show<String>(
      title: title,
      content: ValueListenableBuilder(
        valueListenable: error,
        builder: (_, errorText, _) => TextField(
          controller: controller,
          autofocus: true,
          maxLength: maxLength,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(hintText: hint, errorText: errorText, isDense: true),
        ),
      ),
      actions: (context) => [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(cancelText)),
        TextButton(
          onPressed: () {
            final value = controller.text.trim();
            error.value = validator?.call(value);
            if (error.value == null) Navigator.pop(context, value);
          },
          child: Text(confirmText),
        ),
      ],
    ).whenComplete(() {
      // 等关闭动画结束再释放
      Future<void>.delayed(const Duration(milliseconds: 400), () {
        controller.dispose();
        error.dispose();
      });
    });
  }

  /// 自定义内容的弹窗，用 `Navigator.pop(context, result)` 返回结果
  static Future<T?> custom<T>(WidgetBuilder builder, {bool dismissible = true}) async {
    final context = rootNavigatorKey.currentContext;
    if (context == null) return null;
    return showDialog<T>(context: context, barrierDismissible: dismissible, builder: builder);
  }

  static Future<T?> _show<T>({
    required Widget content,
    required List<Widget> Function(BuildContext context) actions,
    String? title,
    bool dismissible = true,
  }) {
    return custom<T>(
      dismissible: dismissible,
      (context) => PopScope(
        canPop: dismissible,
        child: AlertDialog(
          title: title == null ? null : Text(title, textAlign: TextAlign.center),
          content: content,
          actionsAlignment: MainAxisAlignment.spaceAround,
          actions: actions(context),
        ),
      ),
    );
  }
}
