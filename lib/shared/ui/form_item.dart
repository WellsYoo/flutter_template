import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xjj_app_base/core/theme/app_theme.dart';
import 'package:xjj_app_base/core/utils/context_ext.dart';

/// 表单分组：白底卡片，内部 [FormItem] 之间自动加分割线。
///
/// ```dart
/// FormSection(
///   title: '基本信息',
///   children: [
///     FormItem.input(label: '姓名', required: true, onChanged: (v) => name = v),
///     FormItem.select(label: '类型', value: type?.label, onTap: _pickType),
///   ],
/// )
/// ```
class FormSection extends StatelessWidget {
  const FormSection({super.key, required this.children, this.title, this.margin});

  final List<Widget> children;
  final String? title;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Padding(
      padding: margin ?? const EdgeInsets.only(top: Insets.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(Insets.lg, 0, Insets.lg, Insets.sm),
              child: Text(
                title!,
                style: TextStyle(fontSize: FontSizes.secondary, color: c.textHint),
              ),
            ),
          ColoredBox(
            color: c.card,
            child: Column(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0) const Divider(indent: Insets.lg),
                  children[i],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 表单行：左边标签，右边内容。覆盖“展示 / 选择 / 输入 / 多行 / 开关 / 单选”几种常见形态，
/// 都不满足时用默认构造传 [child]。
class FormItem extends StatelessWidget {
  /// 自定义右侧内容
  const FormItem({
    super.key,
    required this.label,
    required this.child,
    this.required = false,
    this.onTap,
    this.arrow = false,
    this.vertical = false,
  }) : _builder = null;

  /// 只读展示
  FormItem.text({
    super.key,
    required this.label,
    required String? value,
    this.onTap,
    this.arrow = false,
  }) : required = false,
       vertical = false,
       child = null,
       _builder = ((context) => _ValueText(value, placeholder: '--'));

  /// 点击选择（弹出 AppSheet 等），右侧显示箭头
  FormItem.select({
    super.key,
    required this.label,
    required String? value,
    required this.onTap,
    String hint = '请选择',
    this.required = false,
  }) : arrow = true,
       vertical = false,
       child = null,
       _builder = ((context) => _ValueText(value, placeholder: hint));

  /// 单行输入。不传 [controller] 时用 [initialValue] + [onChanged]。
  FormItem.input({
    super.key,
    required this.label,
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
    String? suffix,
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
         textAlign: TextAlign.end,
         style: TextStyle(fontSize: FontSizes.body, color: context.appColors.text),
         decoration: _bareDecoration.copyWith(hintText: hint, suffixText: suffix, counterText: ''),
       ));

  /// 多行输入，标签在上
  FormItem.textarea({
    super.key,
    required this.label,
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
         style: TextStyle(fontSize: FontSizes.body, color: context.appColors.text),
         decoration: _bareDecoration.copyWith(hintText: hint),
       ));

  /// 开关
  FormItem.switcher({
    super.key,
    required this.label,
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
  final bool required;
  final VoidCallback? onTap;
  final bool arrow;

  /// 标签在上、内容在下（多行内容用）
  final bool vertical;
  final Widget? child;
  final WidgetBuilder? _builder;

  /// 单选（选项少时用，选项多用 [FormItem.select] + AppSheet.select）
  static Widget radio<T>({
    Key? key,
    required String label,
    required List<T> options,
    required T? value,
    required ValueChanged<T> onChanged,
    String Function(T)? labelOf,
    bool required = false,
  }) {
    return FormItem(
      key: key,
      label: label,
      required: required,
      child: _RadioGroup<T>(
        options: options,
        value: value,
        onChanged: onChanged,
        labelOf: labelOf ?? (v) => '$v',
      ),
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

    final Widget body = vertical
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              labelWidget,
              const SizedBox(height: Insets.sm),
              content,
            ],
          )
        : Row(
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 88, maxWidth: 140),
                child: labelWidget,
              ),
              const SizedBox(width: Insets.md),
              Expanded(child: content),
              if (arrow) ...[
                const SizedBox(width: Insets.xs),
                Icon(Icons.chevron_right, size: 20, color: context.appColors.textHint),
              ],
            ],
          );

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
          padding: const EdgeInsets.symmetric(horizontal: Insets.lg, vertical: Insets.md),
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
    final c = context.appColors;
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
    final c = context.appColors;
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
    final c = context.appColors;
    return Wrap(
      alignment: WrapAlignment.end,
      spacing: Insets.sm,
      runSpacing: Insets.sm,
      children: [
        for (final o in options)
          GestureDetector(
            onTap: () => onChanged(o),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: Insets.md, vertical: Insets.xs),
              decoration: BoxDecoration(
                color: o == value ? primary.withValues(alpha: 0.1) : c.background,
                border: Border.all(color: o == value ? primary : Colors.transparent),
                borderRadius: BorderRadius.circular(Radii.sm),
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
