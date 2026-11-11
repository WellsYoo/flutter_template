/// 宽松地读取 JSON 字段，手写 `fromJson` 时用。
///
/// 后端字段类型经常不稳定（数字给成字符串、缺字段、给 null）。直接 `json['id'] as int`
/// 一遇到就抛异常，整个页面报错。这里的方法类型不对时返回默认值，不抛异常。
///
/// ```dart
/// factory Order.fromJson(Map<String, dynamic> json) => Order(
///   id: json.str('id'),                       // 123 和 "123" 都能读
///   amount: json.number('amount'),            // "12.5" -> 12.5
///   paid: json.boolean('paid'),               // true / 1 / "1" / "true"
///   createdAt: json.date('createdAt'),        // ISO 字符串、秒或毫秒时间戳
///   buyer: json.obj('buyer', User.fromJson),  // 缺失返回 null
///   items: json.list('items', Item.fromJson), // 缺失返回空列表
///   tags: json.listOf<String>('tags'),
/// );
/// ```
extension JsonX on Map<String, dynamic> {
  String str(String key, [String fallback = '']) => strOrNull(key) ?? fallback;

  String? strOrNull(String key) {
    final v = this[key];
    if (v == null) return null;
    if (v is String) return v;
    if (v is num || v is bool) return '$v';
    return null;
  }

  int integer(String key, [int fallback = 0]) => intOrNull(key) ?? fallback;

  int? intOrNull(String key) {
    final v = this[key];
    if (v is int) return v;
    if (v is double) return v.isFinite ? v.toInt() : null;
    if (v is String) return int.tryParse(v.trim()) ?? double.tryParse(v.trim())?.toInt();
    return null;
  }

  double number(String key, [double fallback = 0]) => doubleOrNull(key) ?? fallback;

  double? doubleOrNull(String key) {
    final v = this[key];
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v.trim());
    return null;
  }

  /// true / 1 / "1" / "true"（不分大小写）为 true
  bool boolean(String key, [bool fallback = false]) {
    final v = this[key];
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) {
      final s = v.trim().toLowerCase();
      if (s == 'true' || s == '1') return true;
      if (s == 'false' || s == '0') return false;
    }
    return fallback;
  }

  /// 支持 ISO 8601 / `yyyy-MM-dd HH:mm:ss` 字符串，以及秒或毫秒时间戳。解析不了返回 null。
  DateTime? date(String key) {
    final v = this[key];
    if (v is num) return _fromTimestamp(v.toInt());
    if (v is String) {
      final s = v.trim();
      if (s.isEmpty) return null;
      final timestamp = int.tryParse(s);
      if (timestamp != null) return _fromTimestamp(timestamp);
      return DateTime.tryParse(s);
    }
    return null;
  }

  // 11 位以内按秒处理（秒级时间戳到 5138 年才到 12 位）
  static DateTime? _fromTimestamp(int value) {
    if (value <= 0) return null;
    return DateTime.fromMillisecondsSinceEpoch(value < 100000000000 ? value * 1000 : value);
  }

  Map<String, dynamic>? map(String key) {
    final v = this[key];
    return v is Map ? Map<String, dynamic>.from(v) : null;
  }

  /// 嵌套对象，不是对象时返回 null
  T? obj<T>(String key, T Function(Map<String, dynamic> json) fromJson) {
    final m = map(key);
    return m == null ? null : fromJson(m);
  }

  /// 对象数组，不是数组时返回空列表，数组里不是对象的元素会跳过
  List<T> list<T>(String key, T Function(Map<String, dynamic> json) fromJson) {
    final v = this[key];
    if (v is! List) return [];
    return [
      for (final item in v)
        if (item is Map) fromJson(Map<String, dynamic>.from(item)),
    ];
  }

  /// 基础类型数组：`json.listOf<String>('tags')`，类型不符的元素会跳过
  List<T> listOf<T>(String key) {
    final v = this[key];
    return v is List ? v.whereType<T>().toList() : [];
  }
}
