import 'dart:async';

/// 防抖：连续调用只执行最后一次（停顿 [delay] 后执行）。搜索联想、输入校验用。
///
/// ```dart
/// final _debouncer = Debouncer();
/// onChanged: (v) => _debouncer(() => _search(v)),
/// // dispose 里：_debouncer.cancel();
/// ```
class Debouncer {
  Debouncer([this.delay = const Duration(milliseconds: 400)]);

  final Duration delay;
  Timer? _timer;

  bool get isPending => _timer?.isActive ?? false;

  void call(void Function() action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  /// 取消还没执行的调用。页面销毁时必须调用，否则回调可能在销毁后执行。
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }
}

/// 节流：[interval] 内只执行第一次，其余忽略。防止按钮连点、滚动事件过密用。
///
/// ```dart
/// final _throttler = Throttler();
/// onTap: () => _throttler(_openDetail),
/// ```
///
/// 等接口返回的按钮不需要它，XButton 的 onPressed 返回 Future 时已经防重复点击。
class Throttler {
  Throttler([this.interval = const Duration(seconds: 1)]);

  final Duration interval;
  Timer? _timer;

  /// 执行了返回 true，被忽略返回 false
  bool call(void Function() action) {
    if (_timer?.isActive ?? false) return false;
    _timer = Timer(interval, () {});
    action();
    return true;
  }

  /// 立即解除限制
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }
}
