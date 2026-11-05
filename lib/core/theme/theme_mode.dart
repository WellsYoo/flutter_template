import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xjj_app_base/core/storage/local_storage.dart';

/// 主题模式（跟随系统 / 亮 / 暗），持久化到本地。
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  LocalStorage get _storage => ref.read(localStorageProvider);

  @override
  ThemeMode build() {
    final saved = _storage.getString(StorageKeys.themeMode);
    return ThemeMode.values.asNameMap()[saved] ?? ThemeMode.system;
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    await _storage.setString(StorageKeys.themeMode, mode.name);
  }
}
