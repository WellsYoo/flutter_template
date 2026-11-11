import 'package:flutter/material.dart';

/// 默认品牌色。换主题色改这一行，或在 `XTheme.create(primary:)` 里传。
const brandColor = Color(0xFF1677FF);

/// 间距规范。页面里统一用这些常量，不要写裸数字。
abstract final class Insets {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;

  /// 页面左右边距
  static const page = EdgeInsets.symmetric(horizontal: lg);
}

/// 圆角规范
abstract final class Radii {
  static const double sm = 4;
  static const double md = 8;
  static const double lg = 12;
}

/// 业务语义色。用法：`context.xColors.textHint`
///
/// 文本、背景、分割线等日常用色都在这里，按名字取，不用记 Material 的色板角色。
@immutable
class XColors extends ThemeExtension<XColors> {
  const XColors({
    required this.text,
    required this.textSecondary,
    required this.textHint,
    required this.divider,
    required this.border,
    required this.background,
    required this.card,
    required this.success,
    required this.warning,
    required this.danger,
  });

  /// 主要文字 #333
  final Color text;

  /// 次要文字 #666
  final Color textSecondary;

  /// 提示 / 占位文字 #999
  final Color textHint;

  /// 分割线
  final Color divider;

  /// 边框
  final Color border;

  /// 页面背景
  final Color background;

  /// 卡片 / 表单 / 导航栏背景
  final Color card;

  final Color success;
  final Color warning;
  final Color danger;

  static const light = XColors(
    text: Color(0xFF333333),
    textSecondary: Color(0xFF666666),
    textHint: Color(0xFF999999),
    divider: Color(0xFFEEEEEE),
    border: Color(0xFFDDDDDD),
    background: Color(0xFFF5F5F5),
    card: Color(0xFFFFFFFF),
    success: Color(0xFF00B578),
    warning: Color(0xFFFF8F1F),
    danger: Color(0xFFF93A4A),
  );

  static const dark = XColors(
    text: Color(0xFFE5E5E5),
    textSecondary: Color(0xFFA3A3A3),
    textHint: Color(0xFF737373),
    divider: Color(0xFF2A2A2A),
    border: Color(0xFF3A3A3A),
    background: Color(0xFF111111),
    card: Color(0xFF1E1E1E),
    success: Color(0xFF1FC98E),
    warning: Color(0xFFFFA040),
    danger: Color(0xFFFF5C69),
  );

  @override
  XColors copyWith({
    Color? text,
    Color? textSecondary,
    Color? textHint,
    Color? divider,
    Color? border,
    Color? background,
    Color? card,
    Color? success,
    Color? warning,
    Color? danger,
  }) => XColors(
    text: text ?? this.text,
    textSecondary: textSecondary ?? this.textSecondary,
    textHint: textHint ?? this.textHint,
    divider: divider ?? this.divider,
    border: border ?? this.border,
    background: background ?? this.background,
    card: card ?? this.card,
    success: success ?? this.success,
    warning: warning ?? this.warning,
    danger: danger ?? this.danger,
  );

  @override
  XColors lerp(XColors? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return XColors(
      text: l(text, other.text),
      textSecondary: l(textSecondary, other.textSecondary),
      textHint: l(textHint, other.textHint),
      divider: l(divider, other.divider),
      border: l(border, other.border),
      background: l(background, other.background),
      card: l(card, other.card),
      success: l(success, other.success),
      warning: l(warning, other.warning),
      danger: l(danger, other.danger),
    );
  }
}

/// 字号规范（逻辑像素 = 750 设计稿 px ÷ 2）。XText 和 Material 组件共用这一套。
abstract final class FontSizes {
  /// 页面标题、AppBar 36px
  static const double headline = 18;

  /// 卡片 / 列表标题 32px
  static const double title = 16;

  /// 正文 28px
  static const double body = 14;

  /// 次要内容 26px
  static const double secondary = 13;

  /// 辅助说明 24px
  static const double caption = 12;

  /// 金额 44px
  static const double amount = 22;
}

/// 主题。默认用 [light] / [dark]；要改品牌色、圆角、字体或个别颜色时用 [create]：
///
/// ```dart
/// theme: XTheme.create(primary: const Color(0xFF07C160), radius: 4),
/// darkTheme: XTheme.create(
///   brightness: Brightness.dark,
///   colors: XColors.dark.copyWith(background: Colors.black),
/// ),
/// ```
abstract final class XTheme {
  static ThemeData get light => create();
  static ThemeData get dark => create(brightness: Brightness.dark);

  static ThemeData create({
    Brightness brightness = Brightness.light,

    /// 品牌色：按钮、选中态、链接
    Color primary = brandColor,

    /// 语义色，默认按 [brightness] 取 [XColors.light] / [XColors.dark]
    XColors? colors,

    /// 按钮、输入框、卡片的圆角
    double radius = Radii.md,
    String? fontFamily,
  }) {
    final c = colors ?? (brightness == Brightness.dark ? XColors.dark : XColors.light);
    final brandColor = primary;
    final scheme = ColorScheme.fromSeed(seedColor: brandColor, brightness: brightness).copyWith(
      primary: brandColor,
      onPrimary: Colors.white,
      surface: c.card,
      onSurface: c.text,
      onSurfaceVariant: c.textSecondary,
      outline: c.border,
      outlineVariant: c.divider,
      error: c.danger,
      surfaceTint: Colors.transparent,
    );
    final base = ThemeData(brightness: brightness, colorScheme: scheme, fontFamily: fontFamily);
    final textTheme = base.textTheme.copyWith(
      titleLarge: base.textTheme.titleLarge?.copyWith(
        fontSize: FontSizes.headline,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: base.textTheme.titleMedium?.copyWith(
        fontSize: FontSizes.title,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: base.textTheme.bodyLarge?.copyWith(fontSize: FontSizes.title),
      bodyMedium: base.textTheme.bodyMedium?.copyWith(fontSize: FontSizes.body),
      bodySmall: base.textTheme.bodySmall?.copyWith(fontSize: FontSizes.caption, color: c.textHint),
    );
    final borderRadius = BorderRadius.circular(radius);
    final buttonShape = RoundedRectangleBorder(borderRadius: borderRadius);

    return base.copyWith(
      extensions: [c],
      textTheme: textTheme,
      scaffoldBackgroundColor: c.background,
      dividerColor: c.divider,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: c.card,
        foregroundColor: c.text,
        titleTextStyle: textTheme.titleLarge?.copyWith(color: c.text),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: c.card,
        indicatorColor: brandColor.withValues(alpha: 0.12),
        height: 64,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: c.card,
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
      ),
      dividerTheme: DividerThemeData(space: 1, thickness: 0.5, color: c.divider),
      listTileTheme: ListTileThemeData(tileColor: c.card, iconColor: c.textSecondary),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: c.textHint, fontSize: FontSizes.body),
        border: OutlineInputBorder(borderRadius: borderRadius),
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: c.border),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: Insets.md, vertical: Insets.md),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(minimumSize: const Size(64, 44), shape: buttonShape),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 44),
          shape: buttonShape,
          foregroundColor: brandColor,
          side: BorderSide(color: brandColor),
        ),
      ),
      textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(shape: buttonShape)),
      dialogTheme: DialogThemeData(
        backgroundColor: c.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.lg)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.card,
        showDragHandle: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.lg)),
        ),
      ),
      // iOS 风格的右滑返回
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
