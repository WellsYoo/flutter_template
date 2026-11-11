import 'package:flutter/services.dart';

/// 常用输入限制。
///
/// ```dart
/// XFormItem.input(label: '金额', inputFormatters: [InputFormats.decimal(2)])
/// ```
abstract final class InputFormats {
  /// 只能输入数字
  static final digits = FilteringTextInputFormatter.digitsOnly;

  /// 小数，最多 [digits] 位（金额用 2）。不合法的输入直接不生效。
  static TextInputFormatter decimal([int digits = 2]) {
    final pattern = RegExp('^\\d*(\\.\\d{0,$digits})?\$');
    return TextInputFormatter.withFunction(
      (oldValue, newValue) => pattern.hasMatch(newValue.text) ? newValue : oldValue,
    );
  }

  /// 手机号：11 位数字
  static final phone = <TextInputFormatter>[
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(11),
  ];

  /// 禁止输入空格
  static final noSpace = FilteringTextInputFormatter.deny(RegExp(r'\s'));

  /// 身份证号：18 位，数字和 X
  static final idCard = <TextInputFormatter>[
    FilteringTextInputFormatter.allow(RegExp('[0-9Xx]')),
    LengthLimitingTextInputFormatter(18),
  ];

  /// 只能输入字母和数字（账号、邀请码）
  static final alphanumeric = FilteringTextInputFormatter.allow(RegExp('[0-9a-zA-Z]'));
}

/// 常用校验，返回 null 表示通过。
abstract final class Validators {
  static final _phone = RegExp(r'^1\d{10}$');
  static final _email = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');
  static final _idCard = RegExp(r'^\d{17}[\dXx]$');

  static String? required(String? v, String label) =>
      (v == null || v.trim().isEmpty) ? '请填写$label' : null;

  static String? phone(String? v) => (v == null || !_phone.hasMatch(v)) ? '手机号格式不正确' : null;

  static String? email(String? v) => (v == null || !_email.hasMatch(v.trim())) ? '邮箱格式不正确' : null;

  /// http / https 链接
  static String? url(String? v) {
    final uri = v == null ? null : Uri.tryParse(v.trim());
    final ok =
        uri != null && (uri.scheme == 'http' || uri.scheme == 'https') && uri.host.isNotEmpty;
    return ok ? null : '链接格式不正确';
  }

  /// 长度范围：`Validators.length(pwd, '密码', min: 6, max: 20)`
  static String? length(String? v, String label, {int min = 0, int? max}) {
    final n = v?.length ?? 0;
    if (n < min) return '$label至少 $min 位';
    if (max != null && n > max) return '$label最多 $max 位';
    return null;
  }

  /// 18 位身份证号，校验出生日期和最后一位校验码
  static String? idCard(String? v) {
    const error = '身份证号格式不正确';
    if (v == null || !_idCard.hasMatch(v)) return error;

    final year = int.parse(v.substring(6, 10));
    final month = int.parse(v.substring(10, 12));
    final day = int.parse(v.substring(12, 14));
    final birthday = DateTime(year, month, day);
    final validDate = birthday.year == year && birthday.month == month && birthday.day == day;
    if (!validDate || birthday.isAfter(DateTime.now())) return error;

    const weights = [7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2];
    var sum = 0;
    for (var i = 0; i < 17; i++) {
      sum += int.parse(v[i]) * weights[i];
    }
    return '10X98765432'[sum % 11] == v[17].toUpperCase() ? null : error;
  }
}
