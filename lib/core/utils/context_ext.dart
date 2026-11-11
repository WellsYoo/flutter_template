import 'package:flutter/material.dart';
import 'package:xjj_app_base/core/theme/x_theme.dart';

/// 常用的 context 简写：`context.primary`、`context.xColors.textHint`、`context.textStyles.title`。
extension ContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;
  XColors get xColors => Theme.of(this).extension<XColors>()!;

  /// 品牌色
  Color get primary => Theme.of(this).colorScheme.primary;

  /// 文字样式：headline / title / body / secondary / caption
  XTextStyles get textStyles => XTextStyles(xColors);

  Size get screenSize => MediaQuery.sizeOf(this);

  /// 底部安全区高度（全面屏的横条）
  double get safeBottom => MediaQuery.paddingOf(this).bottom;

  /// 状态栏高度
  double get safeTop => MediaQuery.paddingOf(this).top;

  void hideKeyboard() => FocusScope.of(this).unfocus();
}
