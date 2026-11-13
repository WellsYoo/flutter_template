import 'package:flutter/material.dart';

/// 默认品牌色。换主题色改这一行，或在 `XTheme.create(primary:)` 里传。
const brandColor = Color(0xFF1677FF);

/// 品牌渐变：从品牌色算出一个更深的邻近色，用在头图、头像、标志这类需要强调的地方。
/// 换品牌色时渐变自动跟着变。
///
/// ```dart
/// XContainer(colors: brandGradient(context.primary), begin: Alignment.topLeft, end: Alignment.bottomRight)
/// ```
List<Color> brandGradient(Color primary) {
  final hsl = HSLColor.fromColor(primary);
  final deep = hsl
      .withHue((hsl.hue + 24) % 360)
      .withLightness((hsl.lightness * 0.72).clamp(0.0, 1.0))
      .toColor();
  return [primary, Color.lerp(deep, const Color(0xFF4B3FA8), 0.35)!];
}

/// 空白间隔。v 是上下间隔（放在 Column 里），h 是左右间隔（放在 Row 里），后面的数字就是大小。
///
/// ```dart
/// Column(children: [title, XGap.v8, content])      // 常用值：直接点出来
/// Row(children: [icon, XGap.h4, label])
/// const XGap.v(18)                                 // 没有预设的值：自己填
/// ```
///
/// 预设值：2 / 4 / 6 / 8 / 10 / 12 / 16 / 20 / 24 / 32。
/// 所有子项间距相同时，直接用 `Column(spacing: 8)` 更省事。
class XGap extends SizedBox {
  /// 自定义上下间隔
  const XGap.v(double size, {super.key}) : super(height: size);

  /// 自定义左右间隔
  const XGap.h(double size, {super.key}) : super(width: size);

  // 上下间隔
  static const v2 = XGap.v(2);
  static const v4 = XGap.v(4);
  static const v6 = XGap.v(6);
  static const v8 = XGap.v(8);
  static const v10 = XGap.v(10);
  static const v12 = XGap.v(12);
  static const v16 = XGap.v(16);
  static const v20 = XGap.v(20);
  static const v24 = XGap.v(24);
  static const v32 = XGap.v(32);

  // 左右间隔
  static const h2 = XGap.h(2);
  static const h4 = XGap.h(4);
  static const h6 = XGap.h(6);
  static const h8 = XGap.h(8);
  static const h10 = XGap.h(10);
  static const h12 = XGap.h(12);
  static const h16 = XGap.h(16);
  static const h20 = XGap.h(20);
  static const h24 = XGap.h(24);
  static const h32 = XGap.h(32);
}

/// 内边距。all 四周、h 左右、v 上下，后面的数字就是大小。
/// 它就是 EdgeInsets，任何要 EdgeInsets 的地方都能用。
///
/// ```dart
/// XPad.all16                // 常用值：直接点出来
/// XPad.h16                  // 左右 16
/// XPad.v8                   // 上下 8
/// XPad.all(18)              // 没有预设的值：自己填
/// XPad.hv(16, 8)            // 左右 16，上下 8
/// XPad.only(top: 8, left: 16)
/// XPad.ltrb(16, 8, 16, 0)   // 左、上、右、下
/// ```
///
/// 预设值：4 / 8 / 10 / 12 / 16 / 20 / 24 / 32。
class XPad extends EdgeInsets {
  /// 自定义四周
  const XPad.all(super.value) : super.all();

  /// 自定义左右
  const XPad.h(double value) : super.symmetric(horizontal: value);

  /// 自定义上下
  const XPad.v(double value) : super.symmetric(vertical: value);

  /// 左右 [h]，上下 [v]
  const XPad.hv(double h, double v) : super.symmetric(horizontal: h, vertical: v);

  const XPad.only({super.left, super.top, super.right, super.bottom}) : super.only();

  /// 左、上、右、下
  const XPad.ltrb(super.left, super.top, super.right, super.bottom) : super.fromLTRB();

  // 四周
  static const all4 = XPad.all(4);
  static const all8 = XPad.all(8);
  static const all10 = XPad.all(10);
  static const all12 = XPad.all(12);
  static const all16 = XPad.all(16);
  static const all20 = XPad.all(20);
  static const all24 = XPad.all(24);
  static const all32 = XPad.all(32);

  // 只有左右
  static const h4 = XPad.h(4);
  static const h8 = XPad.h(8);
  static const h10 = XPad.h(10);
  static const h12 = XPad.h(12);
  static const h16 = XPad.h(16);
  static const h20 = XPad.h(20);
  static const h24 = XPad.h(24);
  static const h32 = XPad.h(32);

  // 只有上下
  static const v4 = XPad.v(4);
  static const v8 = XPad.v(8);
  static const v10 = XPad.v(10);
  static const v12 = XPad.v(12);
  static const v16 = XPad.v(16);
  static const v20 = XPad.v(20);
  static const v24 = XPad.v(24);
  static const v32 = XPad.v(32);

  /// 页面左右边距。全项目统一改这里。
  static const page = h16;
}

/// 字重。设计稿：Regular = regular，Medium = medium，Semibold = semibold，Bold = bold。
abstract final class FontWeights {
  static const regular = FontWeight.w400;
  static const medium = FontWeight.w500;
  static const semibold = FontWeight.w600;
  static const bold = FontWeight.w700;
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
    required this.textDisabled,
    required this.divider,
    required this.border,
    required this.background,
    required this.card,
    required this.fill,
    required this.mask,
    required this.success,
    required this.warning,
    required this.danger,
  });

  /// 主要文字
  final Color text;

  /// 次要文字
  final Color textSecondary;

  /// 提示 / 占位文字
  final Color textHint;

  /// 禁用文字
  final Color textDisabled;

  /// 分割线
  final Color divider;

  /// 边框
  final Color border;

  /// 页面背景
  final Color background;

  /// 卡片 / 表单 / 导航栏背景
  final Color card;

  /// 浅灰填充：输入框底色、标签底色、占位块
  final Color fill;

  /// 半透明黑色遮罩
  final Color mask;

  final Color success;
  final Color warning;
  final Color danger;

  static const light = XColors(
    text: Color(0xFF1F2329),
    textSecondary: Color(0xFF646A73),
    textHint: Color(0xFF8F959E),
    textDisabled: Color(0xFFC9CDD4),
    divider: Color(0xFFEFF0F2),
    border: Color(0xFFDEE0E3),
    background: Color(0xFFF4F5F7),
    card: Color(0xFFFFFFFF),
    fill: Color(0xFFF2F3F5),
    mask: Color(0x73000000),
    success: Color(0xFF00B578),
    warning: Color(0xFFFF8F1F),
    danger: Color(0xFFF93A4A),
  );

  static const dark = XColors(
    text: Color(0xFFEBEDF0),
    textSecondary: Color(0xFFA6ABB3),
    textHint: Color(0xFF6F757E),
    textDisabled: Color(0xFF4A4F57),
    divider: Color(0xFF26292E),
    border: Color(0xFF363A40),
    background: Color(0xFF0F1113),
    card: Color(0xFF1A1C1F),
    fill: Color(0xFF25282C),
    mask: Color(0x99000000),
    success: Color(0xFF1FC98E),
    warning: Color(0xFFFFA040),
    danger: Color(0xFFFF5C69),
  );

  @override
  XColors copyWith({
    Color? text,
    Color? textSecondary,
    Color? textHint,
    Color? textDisabled,
    Color? divider,
    Color? border,
    Color? background,
    Color? card,
    Color? fill,
    Color? mask,
    Color? success,
    Color? warning,
    Color? danger,
  }) => XColors(
    text: text ?? this.text,
    textSecondary: textSecondary ?? this.textSecondary,
    textHint: textHint ?? this.textHint,
    textDisabled: textDisabled ?? this.textDisabled,
    divider: divider ?? this.divider,
    border: border ?? this.border,
    background: background ?? this.background,
    card: card ?? this.card,
    fill: fill ?? this.fill,
    mask: mask ?? this.mask,
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
      textDisabled: l(textDisabled, other.textDisabled),
      divider: l(divider, other.divider),
      border: l(border, other.border),
      background: l(background, other.background),
      card: l(card, other.card),
      fill: l(fill, other.fill),
      mask: l(mask, other.mask),
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
/// 现成的文字样式，和 XText 的层级一一对应。给 TextField、Text.rich 等需要 TextStyle 的地方用。
///
/// ```dart
/// TextField(style: context.textStyles.body)
/// Text('标题', style: context.textStyles.title.copyWith(color: context.primary))
/// ```
class XTextStyles {
  const XTextStyles(this._c);

  final XColors _c;

  static const double _height = 1.4;

  /// 18 半粗，页面标题
  TextStyle get headline => TextStyle(
    fontSize: FontSizes.headline,
    fontWeight: FontWeights.semibold,
    color: _c.text,
    height: _height,
  );

  /// 16 中粗，卡片 / 列表标题
  TextStyle get title => TextStyle(
    fontSize: FontSizes.title,
    fontWeight: FontWeights.medium,
    color: _c.text,
    height: _height,
  );

  /// 14 正文
  TextStyle get body => TextStyle(
    fontSize: FontSizes.body,
    fontWeight: FontWeights.regular,
    color: _c.text,
    height: _height,
  );

  /// 13 次要内容，灰色
  TextStyle get secondary => TextStyle(
    fontSize: FontSizes.secondary,
    fontWeight: FontWeights.regular,
    color: _c.textSecondary,
    height: _height,
  );

  /// 12 辅助说明，浅灰
  TextStyle get caption => TextStyle(
    fontSize: FontSizes.caption,
    fontWeight: FontWeights.regular,
    color: _c.textHint,
    height: _height,
  );
}

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
    double radius = 12,
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
        height: 60,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 11,
            fontWeight: FontWeights.medium,
            color: states.contains(WidgetState.selected) ? brandColor : c.textHint,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 24,
            color: states.contains(WidgetState.selected) ? brandColor : c.textHint,
          ),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: brandColor,
        unselectedLabelColor: c.textSecondary,
        indicatorColor: brandColor,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: c.divider,
        dividerHeight: 0.5,
        labelStyle: const TextStyle(fontSize: FontSizes.body, fontWeight: FontWeights.semibold),
        unselectedLabelStyle: const TextStyle(fontSize: FontSizes.body),
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
        contentPadding: const XPad.hv(12, 12),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.card,
        showDragHandle: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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
