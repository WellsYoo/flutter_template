/// 常用扩展方法。只放“到处都会用到、标准库又没有”的，避免和 Dart 自带的重复
/// （`firstOrNull`、`lastOrNull`、`indexed` 等 Dart 3 已内置）。
library;

extension StringX on String {
  /// 空串或全是空白
  bool get isBlank => trim().isEmpty;

  /// 空白时返回 null，方便配合 `??`：`name.nullIfBlank ?? '未命名'`
  String? get nullIfBlank => isBlank ? null : this;

  int? toIntOrNull() => int.tryParse(trim());

  double? toDoubleOrNull() => double.tryParse(trim());

  /// 脱敏：保留前 [start] 位和后 [end] 位，中间替换成 [char]。长度不够时原样返回。
  ///
  /// ```dart
  /// '13812345678'.mask()                    // 138****5678
  /// '110105194912310021'.mask(start: 6)     // 110105********0021
  /// ```
  String mask({int start = 3, int end = 4, String char = '*'}) {
    if (length <= start + end) return this;
    return substring(0, start) + char * (length - start - end) + substring(length - end);
  }

  /// 超过 [max] 个字符时截断并加省略号
  String ellipsis(int max) {
    final chars = runes.toList();
    return chars.length <= max ? this : '${String.fromCharCodes(chars.take(max))}…';
  }
}

extension NullableStringX on String? {
  bool get isNullOrBlank => this == null || this!.trim().isEmpty;

  /// 为空时显示占位：`user.nickname.orDefault()` → `--`
  String orDefault([String placeholder = '--']) => isNullOrBlank ? placeholder : this!;
}

extension IterableX<T> on Iterable<T> {
  /// 找不到返回 null（`firstWhere` 找不到会抛异常）
  T? firstWhereOrNull(bool Function(T item) test) {
    for (final item in this) {
      if (test(item)) return item;
    }
    return null;
  }

  /// 按 key 分组，保持原顺序
  Map<K, List<T>> groupBy<K>(K Function(T item) keyOf) {
    final result = <K, List<T>>{};
    for (final item in this) {
      (result[keyOf(item)] ??= []).add(item);
    }
    return result;
  }

  /// 按 key 去重，保留第一次出现的
  List<T> distinctBy<K>(K Function(T item) keyOf) {
    final seen = <K>{};
    return [
      for (final item in this)
        if (seen.add(keyOf(item))) item,
    ];
  }

  /// 求和：`orders.sumBy((o) => o.amount)`
  num sumBy(num Function(T item) valueOf) {
    num total = 0;
    for (final item in this) {
      total += valueOf(item);
    }
    return total;
  }

  /// 每 [size] 个切成一组，最后一组可能不足
  List<List<T>> chunked(int size) {
    assert(size > 0, 'size 必须大于 0');
    final result = <List<T>>[];
    var chunk = <T>[];
    for (final item in this) {
      chunk.add(item);
      if (chunk.length == size) {
        result.add(chunk);
        chunk = <T>[];
      }
    }
    if (chunk.isNotEmpty) result.add(chunk);
    return result;
  }

  /// 在元素之间插入分隔项：`widgets.separatedBy(const Divider())`
  List<T> separatedBy(T separator) {
    final result = <T>[];
    for (final item in this) {
      if (result.isNotEmpty) result.add(separator);
      result.add(item);
    }
    return result;
  }
}

extension DateTimeX on DateTime {
  DateTime _at(int y, int m, int d, [int h = 0, int min = 0, int s = 0, int ms = 0]) =>
      isUtc ? DateTime.utc(y, m, d, h, min, s, ms) : DateTime(y, m, d, h, min, s, ms);

  /// 当天 00:00:00
  DateTime get startOfDay => _at(year, month, day);

  /// 当天 23:59:59.999
  DateTime get endOfDay => _at(year, month, day, 23, 59, 59, 999);

  /// 当月 1 号 00:00:00
  DateTime get startOfMonth => _at(year, month, 1);

  /// 当月最后一天 23:59:59.999
  DateTime get endOfMonth => _at(year, month + 1, 0, 23, 59, 59, 999);

  bool isSameDay(DateTime other) => year == other.year && month == other.month && day == other.day;

  bool get isToday => isSameDay(DateTime.now());

  /// 加减月份，日期超出目标月天数时取月末：1 月 31 日 + 1 个月 = 2 月 28/29 日
  DateTime addMonths(int months) {
    final total = year * 12 + (month - 1) + months;
    final y = total ~/ 12;
    final m = total % 12 + 1;
    final lastDay = DateTime(y, m + 1, 0).day;
    final d = day > lastDay ? lastDay : day;
    return _at(y, m, d, hour, minute, second, millisecond);
  }
}
