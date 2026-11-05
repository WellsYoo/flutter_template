import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// 极简日志：只在 debug/profile 输出，release 静默。
/// 需要上报（Sentry/Bugly 等）时，在 [Log.e] 里接入即可。
class Log {
  const Log._();

  static void d(Object? message, {String tag = 'APP'}) {
    if (kReleaseMode) return;
    developer.log('$message', name: tag);
  }

  static void e(Object? message, {Object? error, StackTrace? stackTrace, String tag = 'APP'}) {
    if (kReleaseMode) return;
    developer.log('$message', name: tag, error: error, stackTrace: stackTrace, level: 1000);
  }
}
