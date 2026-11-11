import 'package:intl/intl.dart';

/// 日期 / 数字格式化。用到新格式时在这里加，不要在页面里 new DateFormat。
abstract final class Fmt {
  static final _date = DateFormat('yyyy-MM-dd');
  static final _dateTime = DateFormat('yyyy-MM-dd HH:mm');
  static final _time = DateFormat('HH:mm');
  static final _monthDay = DateFormat('MM-dd');
  static final _money = NumberFormat('#,##0.00');

  static String date(DateTime? d) => d == null ? '' : _date.format(d);
  static String dateTime(DateTime? d) => d == null ? '' : _dateTime.format(d);

  /// 14:05
  static String time(DateTime? d) => d == null ? '' : _time.format(d);

  /// 1234.5 -> 1,234.50
  static String money(num? n) => n == null ? '' : _money.format(n);

  /// 最多保留 [digits] 位小数，去掉末尾的 0：1.50 -> 1.5，2.00 -> 2
  static String number(num? n, {int digits = 2}) {
    if (n == null) return '';
    final s = n.toStringAsFixed(digits);
    if (!s.contains('.')) return s;
    return s.replaceFirst(RegExp(r'\.?0+$'), '');
  }

  /// 比例转百分比：0.256 -> 26%，`digits: 1` -> 25.6%
  static String percent(num? ratio, {int digits = 0}) =>
      ratio == null ? '' : '${number(ratio * 100, digits: digits)}%';

  /// 大数字缩写：9999 -> 9999，12345 -> 1.2万，123456789 -> 1.2亿
  static String count(num? n) {
    if (n == null) return '';
    final abs = n.abs();
    if (abs < 10000) return number(n);
    if (abs < 100000000) return '${number(n / 10000, digits: 1)}万';
    return '${number(n / 100000000, digits: 1)}亿';
  }

  /// 文件大小：1536 -> 1.5 KB
  static String fileSize(int? bytes) {
    if (bytes == null) return '';
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    var value = bytes.toDouble();
    var i = 0;
    while (value >= 1024 && i < units.length - 1) {
      value /= 1024;
      i++;
    }
    return '${number(value, digits: i == 0 ? 0 : 1)} ${units[i]}';
  }

  /// 时长：65 秒 -> 01:05，超过 1 小时 -> 1:01:05
  static String duration(Duration? d) {
    if (d == null) return '';
    final total = d.inSeconds < 0 ? 0 : d.inSeconds;
    String two(int n) => n.toString().padLeft(2, '0');
    final h = total ~/ 3600;
    final m = total % 3600 ~/ 60;
    final s = total % 60;
    return h > 0 ? '$h:${two(m)}:${two(s)}' : '${two(m)}:${two(s)}';
  }

  /// 相对时间：刚刚 / 5分钟前 / 3小时前 / 昨天 14:05 / 03-08 / 2024-03-08。
  /// 未来的时间按完整日期时间显示。[now] 仅用于测试。
  static String timeAgo(DateTime? t, {DateTime? now}) {
    if (t == null) return '';
    final current = now ?? DateTime.now();
    final diff = current.difference(t);
    if (diff.isNegative) return dateTime(t);
    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inHours < 1) return '${diff.inMinutes}分钟前';
    if (diff.inHours < 24 && t.day == current.day) return '${diff.inHours}小时前';

    final yesterday = DateTime(current.year, current.month, current.day - 1);
    if (t.year == yesterday.year && t.month == yesterday.month && t.day == yesterday.day) {
      return '昨天 ${time(t)}';
    }
    return t.year == current.year ? _monthDay.format(t) : date(t);
  }
}
