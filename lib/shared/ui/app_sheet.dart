import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:xjj_app_base/core/theme/app_theme.dart';
import 'package:xjj_app_base/core/utils/context_ext.dart';
import 'package:xjj_app_base/shared/ui/feedback.dart';

/// 底部弹层。全部返回 Future，用户取消时结果为 null。
///
/// ```dart
/// final i = await AppSheet.actions(['拍照', '从相册选择']);
/// final type = await AppSheet.select(title: '选择类型', options: OrderType.values,
///     labelOf: (t) => t.label, selected: current);
/// final date = await AppSheet.date(title: '开始日期', initial: start);
/// ```
abstract final class AppSheet {
  /// 操作菜单，返回点击的下标
  static Future<int?> actions(List<String> actions, {String? title}) {
    return _show<int>(
      (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.all(Insets.md),
              child: Text(title, style: TextStyle(color: context.appColors.textHint)),
            ),
          for (var i = 0; i < actions.length; i++) ...[
            if (i > 0 || title != null) const Divider(),
            _SheetRow(text: actions[i], onTap: () => Navigator.pop(context, i)),
          ],
          Container(height: Insets.sm, color: context.appColors.background),
          _SheetRow(text: '取消', onTap: () => Navigator.pop(context)),
        ],
      ),
    );
  }

  /// 单选列表，点击即返回
  static Future<T?> select<T>({
    required List<T> options,
    String? title,
    T? selected,
    String Function(T)? labelOf,
  }) {
    final label = labelOf ?? (v) => '$v';
    return _show<T>(
      (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SheetHeader(title: title, onCancel: () => Navigator.pop(context)),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final o in options)
                  ListTile(
                    title: Text(label(o)),
                    trailing: o == selected
                        ? Icon(Icons.check, color: context.colors.primary)
                        : null,
                    onTap: () => Navigator.pop(context, o),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 多选列表，点“确定”返回
  static Future<List<T>?> multiSelect<T>({
    required List<T> options,
    String? title,
    List<T> selected = const [],
    String Function(T)? labelOf,
  }) {
    return _show<List<T>>(
      (context) => _MultiSelect<T>(
        title: title,
        options: options,
        initial: selected,
        labelOf: labelOf ?? (v) => '$v',
      ),
    );
  }

  /// 日期 / 日期时间选择
  static Future<DateTime?> date({
    String? title,
    DateTime? initial,
    DateTime? min,
    DateTime? max,
    CupertinoDatePickerMode mode = CupertinoDatePickerMode.date,
  }) {
    var value = initial ?? DateTime.now();
    return _show<DateTime>(
      (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SheetHeader(
            title: title,
            onCancel: () => Navigator.pop(context),
            onConfirm: () => Navigator.pop(context, value),
          ),
          SizedBox(
            height: 220,
            child: CupertinoDatePicker(
              mode: mode,
              initialDateTime: value,
              minimumDate: min,
              maximumDate: max,
              use24hFormat: true,
              onDateTimeChanged: (v) => value = v,
            ),
          ),
        ],
      ),
    );
  }

  /// 自定义内容
  static Future<T?> custom<T>(WidgetBuilder builder) => _show<T>(builder);

  static Future<T?> _show<T>(WidgetBuilder builder) async {
    final context = rootNavigatorKey.currentContext;
    if (context == null) return null;
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.7),
      builder: (context) => SafeArea(top: false, child: builder(context)),
    );
  }
}

class _SheetRow extends StatelessWidget {
  const _SheetRow({required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 52,
        width: double.infinity,
        child: Center(
          child: Text(text, style: const TextStyle(fontSize: FontSizes.title)),
        ),
      ),
    );
  }
}

/// 弹层顶部：取消 / 标题 / 确定
class _SheetHeader extends StatelessWidget {
  const _SheetHeader({this.title, required this.onCancel, this.onConfirm});

  final String? title;
  final VoidCallback onCancel;
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 52,
          child: Row(
            children: [
              TextButton(
                onPressed: onCancel,
                child: Text('取消', style: TextStyle(color: c.textSecondary)),
              ),
              Expanded(
                child: Text(
                  title ?? '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: FontSizes.title, fontWeight: FontWeight.w500),
                ),
              ),
              // 没有“确定”时占位，保持标题居中
              Opacity(
                opacity: onConfirm == null ? 0 : 1,
                child: TextButton(onPressed: onConfirm, child: const Text('确定')),
              ),
            ],
          ),
        ),
        const Divider(),
      ],
    );
  }
}

class _MultiSelect<T> extends StatefulWidget {
  const _MultiSelect({
    required this.title,
    required this.options,
    required this.initial,
    required this.labelOf,
  });

  final String? title;
  final List<T> options;
  final List<T> initial;
  final String Function(T) labelOf;

  @override
  State<_MultiSelect<T>> createState() => _MultiSelectState<T>();
}

class _MultiSelectState<T> extends State<_MultiSelect<T>> {
  late final Set<T> _selected = {...widget.initial};

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SheetHeader(
          title: widget.title,
          onCancel: () => Navigator.pop(context),
          // 保持原选项顺序
          onConfirm: () =>
              Navigator.pop(context, widget.options.where(_selected.contains).toList()),
        ),
        Flexible(
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final o in widget.options)
                CheckboxListTile(
                  value: _selected.contains(o),
                  title: Text(widget.labelOf(o)),
                  onChanged: (v) => setState(() => v! ? _selected.add(o) : _selected.remove(o)),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
