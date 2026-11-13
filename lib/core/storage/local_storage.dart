import 'dart:convert';

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

/// 其他类型的读写，都基于字符串存储。读到的内容类型不对时返回 null，不抛异常。
///
/// ```dart
/// await storage.setBool(StorageKeys.agreed, true);
/// final agreed = storage.getBool(StorageKeys.agreed) ?? false;
///
/// await storage.setJson(StorageKeys.user, user.toJson());
/// final user = storage.getObject(StorageKeys.user, User.fromJson);
/// ```
extension LocalStorageX on LocalStorage {
  bool? getBool(String key) => switch (getString(key)) {
    'true' => true,
    'false' => false,
    _ => null,
  };

  Future<void> setBool(String key, bool value) => setString(key, '$value');

  int? getInt(String key) => int.tryParse(getString(key) ?? '');

  Future<void> setInt(String key, int value) => setString(key, '$value');

  double? getDouble(String key) => double.tryParse(getString(key) ?? '');

  Future<void> setDouble(String key, double value) => setString(key, '$value');

  /// 读取 JSON 对象；没有或内容损坏时返回 null
  Map<String, dynamic>? getJson(String key) {
    final raw = getString(key);
    if (raw == null) return null;
    try {
      final value = jsonDecode(raw);
      return value is Map<String, dynamic> ? value : null;
    } on FormatException {
      return null;
    }
  }

  /// [value] 必须能被 jsonEncode（Map / List / 基础类型）
  Future<void> setJson(String key, Object value) => setString(key, jsonEncode(value));

  /// 读取并转成模型；没有、内容损坏或 [fromJson] 抛异常时返回 null
  T? getObject<T>(String key, T Function(Map<String, dynamic> json) fromJson) {
    final json = getJson(key);
    if (json == null) return null;
    try {
      return fromJson(json);
    } catch (_) {
      return null;
    }
  }
}

/// 全局存储实例。在 main 里通过 overrideWithValue 注入，见 main.dart。
final localStorageProvider = Provider<LocalStorage>(
  (ref) => throw UnimplementedError('localStorageProvider 需要在 ProviderScope 中 override'),
);

/// 所有存储 key 集中在这里，避免散落的魔法字符串。
abstract final class StorageKeys {
  static const token = 'auth.token';
  static const themeMode = 'settings.themeMode';
  static const notifyEnabled = 'settings.notifyEnabled';
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
