import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xjj_app_base/core/storage/local_storage.dart';

/// 消息通知开关：需要持久化的简单设置项的写法。
/// 初值同步从本地读（存储在启动时已加载到内存），改的时候先更新状态再写盘。
final notifyEnabledProvider = NotifierProvider<NotifyEnabledNotifier, bool>(
  NotifyEnabledNotifier.new,
);

class NotifyEnabledNotifier extends Notifier<bool> {
  LocalStorage get _storage => ref.read(localStorageProvider);

  @override
  bool build() => _storage.getBool(StorageKeys.notifyEnabled) ?? true;

  Future<void> set(bool enabled) async {
    state = enabled;
    await _storage.setBool(StorageKeys.notifyEnabled, enabled);
  }
}
