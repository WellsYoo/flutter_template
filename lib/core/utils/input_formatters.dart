import 'package:flutter/services.dart';

/// 常用输入限制。
///
/// ```dart
/// FormItem.input(label: '金额', inputFormatters: [InputFormats.decimal(2)])
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
}

/// 常用校验，返回 null 表示通过。
abstract final class Validators {
  static final _phone = RegExp(r'^1\d{10}$');

  static String? required(String? v, String label) =>
      (v == null || v.trim().isEmpty) ? '请填写$label' : null;

  static String? phone(String? v) => (v == null || !_phone.hasMatch(v)) ? '手机号格式不正确' : null;
}
