import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xjj_app_base/app/app.dart';
import 'package:xjj_app_base/core/storage/local_storage.dart';
import 'package:xjj_app_base/core/utils/logger.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 全局异常兜底。接入崩溃上报时改这两处。
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    Log.e('FlutterError', error: details.exception, stackTrace: details.stack);
  };
  WidgetsBinding.instance.platformDispatcher.onError = (error, stack) {
    Log.e('Uncaught', error: error, stackTrace: stack);
    return true;
  };

  // 启动前需要异步准备的东西放这里，然后通过 override 注入
  final storage = await PrefsStorage.create();

  runApp(
    ProviderScope(
      overrides: [localStorageProvider.overrideWithValue(storage)],
      // Riverpod 3 默认会自动重试失败的 provider；接口错误交给用户手动重试，所以关掉
      retry: (_, _) => null,
      observers: [_ProviderLogger()],
      child: const App(),
    ),
  );
}

final class _ProviderLogger extends ProviderObserver {
  @override
  void providerDidFail(ProviderObserverContext context, Object error, StackTrace stackTrace) {
    Log.d('${context.provider} 失败: $error', tag: 'Riverpod');
  }
}
