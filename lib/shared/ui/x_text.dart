import 'package:flutter/material.dart';
import 'package:xjj_app_base/core/theme/x_theme.dart';
import 'package:xjj_app_base/core/utils/context_ext.dart';
import 'package:xjj_app_base/core/utils/formatters.dart';

enum _TextKind { headline, title, body, secondary, caption }

/// 统一字号 / 颜色的文本。字号、颜色、粗细默认按层级取，需要时单独覆盖。
///
/// ```dart
/// XText.title('订单详情')
/// XText.secondary('创建于 2025-01-01', maxLines: 1)
/// XText.body('已失效', color: context.xColors.textHint, lineThrough: true)
/// XText('自定义字号', size: 20, bold: true)
/// XText.money(1234.5) // ¥1,234.50
/// ```
class XText extends StatelessWidget {
  /// 正文样式，一般配合 [size] 等参数做自定义
  const XText(
    this.data, {
    super.key,
    this.size,
    this.color,
    this.weight,
    this.bold = false,
    this.maxLines,
    this.align,
    this.height,
    this.lineThrough = false,
  }) : _kind = _TextKind.body;

  /// 18 页面标题
  const XText.headline(
    this.data, {
    super.key,
    this.size,
    this.color,
    this.weight,
    this.bold = false,
    this.maxLines,
    this.align,
    this.height,
    this.lineThrough = false,
  }) : _kind = _TextKind.headline;

  /// 16 卡片 / 列表标题
  const XText.title(
    this.data, {
    super.key,
    this.size,
    this.color,
    this.weight,
    this.bold = false,
    this.maxLines,
    this.align,
    this.height,
    this.lineThrough = false,
  }) : _kind = _TextKind.title;

  /// 14 正文
  const XText.body(
    this.data, {
    super.key,
    this.size,
    this.color,
    this.weight,
    this.bold = false,
    this.maxLines,
    this.align,
    this.height,
    this.lineThrough = false,
  }) : _kind = _TextKind.body;

  /// 13 次要内容，灰色
  const XText.secondary(
    this.data, {
    super.key,
    this.size,
    this.color,
    this.weight,
    this.bold = false,
    this.maxLines,
    this.align,
    this.height,
    this.lineThrough = false,
  }) : _kind = _TextKind.secondary;

  /// 12 辅助说明，浅灰
  const XText.caption(
    this.data, {
    super.key,
    this.size,
    this.color,
    this.weight,
    this.bold = false,
    this.maxLines,
    this.align,
    this.height,
    this.lineThrough = false,
  }) : _kind = _TextKind.caption;

  final String data;
  final _TextKind _kind;

  /// 字号，默认按层级
  final double? size;
  final Color? color;

  /// 粗细；只是想加粗用 [bold] 更短
  final FontWeight? weight;

  /// 加粗（w600）
  final bool bold;

  /// 最多行数，超出显示省略号
  final int? maxLines;
  final TextAlign? align;

  /// 行高倍数，默认 1.4
  final double? height;

  /// 删除线（原价等）
  final bool lineThrough;

  /// 金额：¥ 符号小一号，数字加粗
  static Widget money(num? value, {Key? key, Color? color, double fontSize = FontSizes.amount}) =>
      _MoneyText(value, key: key, color: color, fontSize: fontSize);

  @override
  Widget build(BuildContext context) {
    final c = context.xColors;
    final (defaultSize, defaultWeight, defaultColor) = switch (_kind) {
      _TextKind.headline => (FontSizes.headline, FontWeight.w600, c.text),
      _TextKind.title => (FontSizes.title, FontWeight.w500, c.text),
      _TextKind.body => (FontSizes.body, FontWeight.normal, c.text),
      _TextKind.secondary => (FontSizes.secondary, FontWeight.normal, c.textSecondary),
      _TextKind.caption => (FontSizes.caption, FontWeight.normal, c.textHint),
    };
    final textColor = color ?? defaultColor;
    return Text(
      data,
      maxLines: maxLines,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
      textAlign: align,
      style: TextStyle(
        fontSize: size ?? defaultSize,
        fontWeight: weight ?? (bold ? FontWeight.w600 : defaultWeight),
        color: textColor,
        height: height ?? 1.4,
        decoration: lineThrough ? TextDecoration.lineThrough : null,
        decorationColor: textColor,
      ),
    );
  }
}

class _MoneyText extends StatelessWidget {
  const _MoneyText(this.value, {super.key, this.color, required this.fontSize});

  final num? value;
  final Color? color;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final c = color ?? context.xColors.danger;
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '¥',
            style: TextStyle(fontSize: fontSize * 0.65),
          ),
          TextSpan(text: value == null ? '--' : Fmt.money(value)),
        ],
      ),
      style: TextStyle(color: c, fontSize: fontSize, fontWeight: FontWeight.w600),
    );
  }
}
