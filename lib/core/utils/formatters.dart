import 'package:intl/intl.dart';

/// 日期 / 数字格式化。用到新格式时在这里加，不要在页面里 new DateFormat。
abstract final class Fmt {
  static final _date = DateFormat('yyyy-MM-dd');
  static final _dateTime = DateFormat('yyyy-MM-dd HH:mm');
  static final _money = NumberFormat('#,##0.00');

  static String date(DateTime? d) => d == null ? '' : _date.format(d);
  static String dateTime(DateTime? d) => d == null ? '' : _dateTime.format(d);

  /// 1234.5 -> 1,234.50
  static String money(num? n) => n == null ? '' : _money.format(n);
}
