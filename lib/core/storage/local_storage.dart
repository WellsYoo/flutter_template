import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 本地 KV 存储。读同步（启动时已全部加载到内存），写异步。
///
/// 业务代码只依赖这个接口；测试用 [MemoryStorage] 替换。
abstract interface class LocalStorage {
  String? getString(String key);
  Future<void> setString(String key, String value);
  Future<void> remove(String key);
}

/// 全局存储实例。在 main 里通过 overrideWithValue 注入，见 main.dart。
final localStorageProvider = Provider<LocalStorage>(
  (ref) => throw UnimplementedError('localStorageProvider 需要在 ProviderScope 中 override'),
);

/// 所有存储 key 集中在这里，避免散落的魔法字符串。
abstract final class StorageKeys {
  static const token = 'auth.token';
  static const themeMode = 'settings.themeMode';
}

class PrefsStorage implements LocalStorage {
  PrefsStorage._(this._prefs);

  final SharedPreferencesWithCache _prefs;

  static Future<PrefsStorage> create() async {
    final prefs = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(),
    );
    return PrefsStorage._(prefs);
  }

  @override
  String? getString(String key) => _prefs.getString(key);

  @override
  Future<void> setString(String key, String value) => _prefs.setString(key, value);

  @override
  Future<void> remove(String key) => _prefs.remove(key);
}

/// 内存实现，用于测试或预览。
class MemoryStorage implements LocalStorage {
  MemoryStorage([Map<String, String>? initial]) : _data = {...?initial};

  final Map<String, String> _data;

  @override
  String? getString(String key) => _data[key];

  @override
  Future<void> setString(String key, String value) async => _data[key] = value;

  @override
  Future<void> remove(String key) async => _data.remove(key);
}
