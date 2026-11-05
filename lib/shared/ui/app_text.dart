import 'package:flutter/material.dart';
import 'package:xjj_app_base/core/theme/app_theme.dart';
import 'package:xjj_app_base/core/utils/context_ext.dart';
import 'package:xjj_app_base/core/utils/formatters.dart';

enum _TextKind { headline, title, body, secondary, caption }

/// 统一字号 / 颜色的文本。颜色默认按层级取，需要时用 [color] 覆盖。
///
/// ```dart
/// AppText.title('订单详情')
/// AppText.secondary('创建于 2025-01-01', maxLines: 1)
/// AppText.money(1234.5) // ¥1,234.50
/// ```
class AppText extends StatelessWidget {
  /// 18 页面标题
  const AppText.headline(this.data, {super.key, this.color, this.weight, this.maxLines, this.align})
    : _kind = _TextKind.headline;

  /// 16 卡片 / 列表标题
  const AppText.title(this.data, {super.key, this.color, this.weight, this.maxLines, this.align})
    : _kind = _TextKind.title;

  /// 14 正文
  const AppText.body(this.data, {super.key, this.color, this.weight, this.maxLines, this.align})
    : _kind = _TextKind.body;

  /// 13 次要内容，灰色
  const AppText.secondary(
    this.data, {
    super.key,
    this.color,
    this.weight,
    this.maxLines,
    this.align,
  }) : _kind = _TextKind.secondary;

  /// 12 辅助说明，浅灰
  const AppText.caption(this.data, {super.key, this.color, this.weight, this.maxLines, this.align})
    : _kind = _TextKind.caption;

  final String data;
  final _TextKind _kind;
  final Color? color;
  final FontWeight? weight;
  final int? maxLines;
  final TextAlign? align;

  /// 金额：¥ 符号小一号，数字加粗
  static Widget money(num? value, {Key? key, Color? color, double fontSize = FontSizes.amount}) =>
      _MoneyText(value, key: key, color: color, fontSize: fontSize);

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final (size, defaultWeight, defaultColor) = switch (_kind) {
      _TextKind.headline => (FontSizes.headline, FontWeight.w600, c.text),
      _TextKind.title => (FontSizes.title, FontWeight.w500, c.text),
      _TextKind.body => (FontSizes.body, FontWeight.normal, c.text),
      _TextKind.secondary => (FontSizes.secondary, FontWeight.normal, c.textSecondary),
      _TextKind.caption => (FontSizes.caption, FontWeight.normal, c.textHint),
    };
    return Text(
      data,
      maxLines: maxLines,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
      textAlign: align,
      style: TextStyle(
        fontSize: size,
        fontWeight: weight ?? defaultWeight,
        color: color ?? defaultColor,
        height: 1.4,
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
    final c = color ?? context.appColors.danger;
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
