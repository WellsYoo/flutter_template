import 'package:flutter/material.dart';
import 'package:xjj_app_base/core/utils/context_ext.dart';

/// 容器：圆角、渐变、边框、阴影、点击这些常用装饰直接传参，不用手写 BoxDecoration。
///
/// ```dart
/// XContainer(color: Colors.white, radius: 12, padding: const EdgeInsets.all(16), child: ...)
/// XContainer(colors: const [Color(0xFF4FACFE), Color(0xFF00F2FE)], radius: 8, child: ...)
/// XContainer(border: true, radius: 8, onTap: _open, child: ...)
/// XContainer(size: 40, circle: true, color: context.colors.primary, alignment: Alignment.center, child: ...)
/// XContainer(
///   color: Colors.white,
///   borderRadius: const BorderRadius.vertical(top: Radius.circular(16)), // 只要上面两个圆角
///   shadow: true,
///   child: ...,
/// )
/// ```
class XContainer extends StatelessWidget {
  const XContainer({
    super.key,
    this.child,
    double? size,
    double? width,
    double? height,
    this.padding,
    this.margin,
    this.alignment,
    this.color,
    this.colors,
    this.begin = Alignment.centerLeft,
    this.end = Alignment.centerRight,
    this.gradient,
    this.radius,
    this.borderRadius,
    this.circle = false,
    this.border = false,
    this.borderColor,
    this.borderWidth = 0.5,
    this.shadow = false,
    this.boxShadow,
    this.clip = false,
    this.onTap,
    this.onLongPress,
  }) : width = width ?? size,
       height = height ?? size;

  final Widget? child;

  /// 宽高；传 `size` 时宽高相等
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  /// 子组件的对齐方式。传了以后容器会尽量撑满父容器（同 Container）
  final AlignmentGeometry? alignment;

  /// 背景色
  final Color? color;

  /// 渐变色，默认从左到右；方向用 [begin] / [end] 改
  /// （上到下：`begin: Alignment.topCenter, end: Alignment.bottomCenter`）
  final List<Color>? colors;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;

  /// 完全自定义的渐变（径向、带 stops 等），传了就不看 [colors]
  final Gradient? gradient;

  /// 四个角相同的圆角
  final double? radius;

  /// 单独设置某几个角，传了就不看 [radius]
  final BorderRadiusGeometry? borderRadius;

  /// 圆形（宽高应相等）
  final bool circle;

  /// 显示边框，颜色默认取主题的边框色。传了 [borderColor] 也会显示
  final bool border;
  final Color? borderColor;
  final double borderWidth;

  /// 显示一层柔和的默认阴影；要自定义用 [boxShadow]
  final bool shadow;
  final List<BoxShadow>? boxShadow;

  /// 按圆角裁剪子组件（子组件是图片等会超出圆角的内容时打开）
  final bool clip;

  /// 传了就可点击，带水波纹
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  static const _defaultShadow = [
    BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 4)),
  ];

  @override
  Widget build(BuildContext context) {
    final radius = circle
        ? null
        : borderRadius ?? (this.radius == null ? null : BorderRadius.circular(this.radius!));
    final showBorder = border || borderColor != null;

    Widget? content = child;
    if (onTap != null || onLongPress != null) {
      // 内边距、对齐放在 InkWell 里面，整个容器都能点、都有水波纹
      if (padding != null) content = Padding(padding: padding!, child: content);
      if (alignment != null) content = Align(alignment: alignment!, child: content);
      content = Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          customBorder: circle
              ? const CircleBorder()
              : RoundedRectangleBorder(borderRadius: radius ?? BorderRadius.zero),
          child: content,
        ),
      );
      return _box(context, radius, showBorder, content, null, null);
    }
    return _box(context, radius, showBorder, content, padding, alignment);
  }

  Widget _box(
    BuildContext context,
    BorderRadiusGeometry? radius,
    bool showBorder,
    Widget? content,
    EdgeInsetsGeometry? padding,
    AlignmentGeometry? alignment,
  ) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      alignment: alignment,
      clipBehavior: clip ? Clip.antiAlias : Clip.none,
      decoration: BoxDecoration(
        color: color,
        gradient:
            gradient ??
            (colors == null ? null : LinearGradient(colors: colors!, begin: begin, end: end)),
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: radius,
        border: showBorder
            ? Border.all(color: borderColor ?? context.xColors.border, width: borderWidth)
            : null,
        boxShadow: boxShadow ?? (shadow ? _defaultShadow : null),
      ),
      child: content,
    );
  }
}
