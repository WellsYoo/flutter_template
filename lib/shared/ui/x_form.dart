import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xjj_app_base/core/theme/x_theme.dart';
import 'package:xjj_app_base/core/utils/context_ext.dart';
import 'package:xjj_app_base/core/utils/formatters.dart';
import 'package:xjj_app_base/shared/ui/x_sheet.dart';

/// 表单分组：白底卡片，内部 [XFormItem] / XCell 之间自动加分割线。
///
/// ```dart
/// XFormSection(
///   title: '基本信息',
///   labelWidth: 96, // 这一组的标签统一宽度，输入框左对齐时好看
///   children: [
///     XFormItem.input(label: '姓名', required: true, onChanged: (v) => name = v),
///     XFormItem.select(label: '类型', value: type?.label, onTap: _pickType),
///   ],
/// )
/// ```
class XFormSection extends StatelessWidget {
  const XFormSection({
    super.key,
    required this.children,
    this.title,
    this.margin,
    this.labelWidth,
    this.divider = true,
  });

  final List<Widget> children;
  final String? title;
  final EdgeInsetsGeometry? margin;

  /// 组内所有 [XFormItem] 的标签宽度；不传时按内容自适应（88 ~ 140）
  final double? labelWidth;

  /// 行之间是否显示分割线
  final bool divider;

  @override
  Widget build(BuildContext context) {
    final c = context.xColors;
    return Padding(
      padding: margin ?? const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null)
            Padding(
              padding: const XPad.ltrb(16, 0, 16, 8),
              child: Text(
                title!,
                style: TextStyle(fontSize: FontSizes.secondary, color: c.textHint),
              ),
            ),
          ColoredBox(
            color: c.card,
            child: _FormScope(
              labelWidth: labelWidth,
              child: Column(
                children: [
                  for (var i = 0; i < children.length; i++) ...[
                    if (i > 0 && divider) const Divider(indent: 16),
                    children[i],
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormScope extends InheritedWidget {
  const _FormScope({required this.labelWidth, required super.child});

  final double? labelWidth;

  @override
  bool updateShouldNotify(_FormScope old) => labelWidth != old.labelWidth;
}

/// 表单行：左边标签，右边内容。覆盖“展示 / 选择 / 输入 / 多行 / 开关 / 单选”几种常见形态，
/// 都不满足时用默认构造传 [child]。
class XFormItem extends StatelessWidget {
  /// 自定义右侧内容
  const XFormItem({
    super.key,
    required this.label,
    this.help,
    required this.child,
    this.required = false,
    this.onTap,
    this.arrow = false,
    this.vertical = false,
  }) : _builder = null;

  /// 只读展示
  XFormItem.text({
    super.key,
    required this.label,
    this.help,
    required String? value,
    this.onTap,
    this.arrow = false,
  }) : required = false,
       vertical = false,
       child = null,
       _builder = ((context) => _ValueText(value, placeholder: '--'));

  /// 点击选择（弹出 XSheet 等），右侧显示箭头
  XFormItem.select({
    super.key,
    required this.label,
    this.help,
    required String? value,
    required this.onTap,
    String hint = '请选择',
    this.required = false,
  }) : arrow = true,
       vertical = false,
       child = null,
       _builder = ((context) => _ValueText(value, placeholder: hint));

  /// 单行输入。不传 [controller] 时用 [initialValue] + [onChanged]。
  XFormItem.input({
    super.key,
    required this.label,
    this.help,
    TextEditingController? controller,
    String? initialValue,
    ValueChanged<String>? onChanged,
    String hint = '请输入',
    this.required = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
    bool obscureText = false,
    bool enabled = true,
    bool readOnly = false,
    TextAlign textAlign = TextAlign.end,
    TextInputAction? textInputAction,

    /// 输入框后面的单位文字，如 “元”
    String? suffix,

    /// 输入框后面的组件，如“获取验证码”按钮
    Widget? trailing,
  }) : onTap = null,
       arrow = false,
       vertical = false,
       child = null,
       _builder = ((context) => TextFormField(
         controller: controller,
         initialValue: controller == null ? initialValue : null,
         onChanged: onChanged,
         enabled: enabled,
         obscureText: obscureText,
         keyboardType: keyboardType,
         inputFormatters: inputFormatters,
         maxLength: maxLength,
         readOnly: readOnly,
         textAlign: textAlign,
         textInputAction: textInputAction,
         style: TextStyle(fontSize: FontSizes.body, color: context.xColors.text),
         decoration: _bareDecoration.copyWith(
           hintText: hint,
           suffixText: suffix,
           counterText: '',
           suffixIcon: trailing == null
               ? null
               : Padding(padding: const EdgeInsets.only(left: 8), child: trailing),
           suffixIconConstraints: const BoxConstraints(),
         ),
       ));

  /// 多行输入，标签在上
  XFormItem.textarea({
    super.key,
    required this.label,
    this.help,
    TextEditingController? controller,
    String? initialValue,
    ValueChanged<String>? onChanged,
    String hint = '请输入',
    this.required = false,
    int maxLength = 200,
    int minLines = 3,
  }) : onTap = null,
       arrow = false,
       vertical = true,
       child = null,
       _builder = ((context) => TextFormField(
         controller: controller,
         initialValue: controller == null ? initialValue : null,
         onChanged: onChanged,
         minLines: minLines,
         maxLines: null,
         maxLength: maxLength,
         style: TextStyle(fontSize: FontSizes.body, color: context.xColors.text),
         decoration: _bareDecoration.copyWith(hintText: hint),
       ));

  /// 开关
  XFormItem.switcher({
    super.key,
    required this.label,
    this.help,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) : required = false,
       onTap = null,
       arrow = false,
       vertical = false,
       child = null,
       _builder = ((context) => Align(
         alignment: Alignment.centerRight,
         child: Transform.scale(
           scale: 0.8,
           alignment: Alignment.centerRight,
           child: Switch(value: value, onChanged: onChanged),
         ),
       ));

  final String label;

  /// 显示在这一行下方的灰色说明文字
  final String? help;
  final bool required;
  final VoidCallback? onTap;
  final bool arrow;

  /// 标签在上、内容在下（多行内容用）
  final bool vertical;
  final Widget? child;
  final WidgetBuilder? _builder;

  /// 单选（选项少时用，选项多用 [XFormItem.select] + XSheet.select）
  static Widget radio<T>({
    Key? key,
    required String label,
    required List<T> options,
    required T? value,
    required ValueChanged<T> onChanged,
    String Function(T)? labelOf,
    String? help,
    bool required = false,
  }) {
    return XFormItem(
      key: key,
      label: label,
      help: help,
      required: required,
      child: _RadioGroup<T>(
        options: options,
        value: value,
        onChanged: onChanged,
        labelOf: labelOf ?? (v) => '$v',
      ),
    );
  }

  /// 日期选择：点击弹出日期选择器，选完回调 [onChanged]。
  static Widget date({
    Key? key,
    required String label,
    required DateTime? value,
    required ValueChanged<DateTime> onChanged,
    DateTime? min,
    DateTime? max,

    /// 同时选择时间（年月日 时分）
    bool withTime = false,
    String hint = '请选择',
    String? help,
    bool required = false,
  }) {
    return XFormItem.select(
      key: key,
      label: label,
      help: help,
      hint: hint,
      required: required,
      value: value == null ? null : (withTime ? Fmt.dateTime(value) : Fmt.date(value)),
      onTap: () async {
        final picked = await XSheet.date(
          title: label,
          initial: value,
          min: min,
          max: max,
          withTime: withTime,
        );
        if (picked != null) onChanged(picked);
      },
    );
  }

  /// 下拉单选：点击弹出选项列表，选完回调 [onChanged]。
  static Widget picker<T>({
    Key? key,
    required String label,
    required List<T> options,
    required T? value,
    required ValueChanged<T> onChanged,
    String Function(T)? labelOf,
    String hint = '请选择',
    String? help,
    bool required = false,
  }) {
    final text = labelOf ?? (v) => '$v';
    return XFormItem.select(
      key: key,
      label: label,
      help: help,
      hint: hint,
      required: required,
      value: value == null ? null : text(value),
      onTap: () async {
        final picked = await XSheet.select(
          title: label,
          options: options,
          selected: value,
          labelOf: labelOf,
        );
        if (picked != null) onChanged(picked);
      },
    );
  }

  static const _bareDecoration = InputDecoration(
    isDense: true,
    contentPadding: EdgeInsets.zero,
    border: InputBorder.none,
    enabledBorder: InputBorder.none,
    focusedBorder: InputBorder.none,
    disabledBorder: InputBorder.none,
    filled: false,
  );

  @override
  Widget build(BuildContext context) {
    final content = child ?? _builder!(context);
    final labelWidget = _Label(label, required: required);

    final labelWidth = context.dependOnInheritedWidgetOfExactType<_FormScope>()?.labelWidth;

    Widget body = vertical
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [labelWidget, XGap.v8, content],
          )
        : Row(
            children: [
              if (labelWidth != null)
                SizedBox(width: labelWidth, child: labelWidget)
              else
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 88, maxWidth: 140),
                  child: labelWidget,
                ),
              XGap.h12,
              Expanded(child: content),
              if (arrow) ...[
                XGap.h4,
                Icon(Icons.chevron_right, size: 20, color: context.xColors.textHint),
              ],
            ],
          );

    if (help != null) {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          body,
          XGap.v4,
          Text(
            help!,
            style: TextStyle(fontSize: FontSizes.caption, color: context.xColors.textHint),
          ),
        ],
      );
    }

    return InkWell(
      onTap: onTap == null
          ? null
          : () {
              context.hideKeyboard();
              onTap!();
            },
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 52),
        child: Padding(
          padding: const XPad.hv(16, 12),
          child: Align(alignment: Alignment.centerLeft, child: body),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text, {required this.required});

  final String text;
  final bool required;

  @override
  Widget build(BuildContext context) {
    final c = context.xColors;
    return Text.rich(
      TextSpan(
        children: [
          if (required)
            TextSpan(
              text: '* ',
              style: TextStyle(color: c.danger),
            ),
          TextSpan(text: text),
        ],
      ),
      style: TextStyle(fontSize: FontSizes.body, color: c.text),
    );
  }
}

class _ValueText extends StatelessWidget {
  const _ValueText(this.value, {required this.placeholder});

  final String? value;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    final c = context.xColors;
    final empty = value == null || value!.isEmpty;
    return Text(
      empty ? placeholder : value!,
      textAlign: TextAlign.end,
      style: TextStyle(fontSize: FontSizes.body, color: empty ? c.textHint : c.text),
    );
  }
}

class _RadioGroup<T> extends StatelessWidget {
  const _RadioGroup({
    required this.options,
    required this.value,
    required this.onChanged,
    required this.labelOf,
  });

  final List<T> options;
  final T? value;
  final ValueChanged<T> onChanged;
  final String Function(T) labelOf;

  @override
  Widget build(BuildContext context) {
    final primary = context.colors.primary;
    final c = context.xColors;
    return Wrap(
      alignment: WrapAlignment.end,
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final o in options)
          GestureDetector(
            onTap: () => onChanged(o),
            child: Container(
              padding: const XPad.hv(12, 4),
              decoration: BoxDecoration(
                color: o == value ? primary.withValues(alpha: 0.1) : c.background,
                border: Border.all(color: o == value ? primary : Colors.transparent),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                labelOf(o),
                style: TextStyle(
                  fontSize: FontSizes.secondary,
                  color: o == value ? primary : c.textSecondary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
