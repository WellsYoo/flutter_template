import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

extension RefCacheX on Ref {
  /// 让 autoDispose 的 provider 在没人监听后再保留 [duration]，期间重新进入页面直接用缓存，
  /// 不重新请求。超时后才释放。（Riverpod 官方文档里的写法）
  ///
  /// ```dart
  /// final dictProvider = FutureProvider.autoDispose<List<Dict>>((ref) {
  ///   ref.cacheFor(const Duration(minutes: 5));
  ///   return ref.watch(dictRepositoryProvider).fetchAll();
  /// });
  /// ```
  void cacheFor(Duration duration) {
    final link = keepAlive();
    Timer? timer;
    onCancel(() => timer = Timer(duration, link.close)); // 最后一个监听者离开
    onResume(() => timer?.cancel()); // 又有人监听
    onDispose(() => timer?.cancel());
  }
}
