import 'package:flutter/material.dart';
import 'package:xjj_app_base/core/theme/x_theme.dart';

/// 常用的 context 简写：`context.colors.primary`、`context.text.titleMedium`。
extension ContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;
  XColors get xColors => Theme.of(this).extension<XColors>()!;

  void hideKeyboard() => FocusScope.of(this).unfocus();
}
