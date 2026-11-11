import 'dart:async';

import 'package:flutter/material.dart';
import 'package:xjj_app_base/core/theme/x_theme.dart';
import 'package:xjj_app_base/core/utils/context_ext.dart';

/// 搜索框：输入停顿 [debounce] 后回调，带清除按钮。
///
/// ```dart
/// XSearchField(onChanged: (v) => setState(() => keyword = v))
/// XSearchField(round: true, hintText: '搜索商品', autofocus: true, onSubmitted: _search)
/// ```
class XSearchField extends StatefulWidget {
  const XSearchField({
    super.key,
    this.onChanged,
    this.onSubmitted,
    this.hintText = '搜索',
    this.initialValue,
    this.controller,
    this.autofocus = false,
    this.round = false,
    this.debounce = const Duration(milliseconds: 400),
  });

  /// 输入停顿后回调（已 trim）；点清除、按键盘“搜索”时立即回调
  final ValueChanged<String>? onChanged;

  /// 按键盘“搜索”时回调。只想在提交时搜索就只传这个
  final ValueChanged<String>? onSubmitted;
  final String hintText;
  final String? initialValue;

  /// 需要在外部读写内容时传；不传时内部自己管理
  final TextEditingController? controller;
  final bool autofocus;

  /// 灰底胶囊样式（放在白色导航栏 / 白色背景上用）；默认是带边框的输入框
  final bool round;
  final Duration debounce;

  @override
  State<XSearchField> createState() => _XSearchFieldState();
}

class _XSearchFieldState extends State<XSearchField> {
  late final TextEditingController _controller =
      widget.controller ?? TextEditingController(text: widget.initialValue);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.removeListener(_onTextChanged);
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  // 刷新清除按钮（外部改 controller 时也能更新）
  void _onTextChanged() => setState(() {});

  void _emit(String value, {bool immediately = false}) {
    _timer?.cancel();
    if (immediately) {
      widget.onChanged?.call(value.trim());
    } else {
      _timer = Timer(widget.debounce, () => widget.onChanged?.call(value.trim()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.xColors;
    final pill = OutlineInputBorder(
      borderRadius: BorderRadius.circular(100),
      borderSide: BorderSide.none,
    );
    return TextField(
      controller: _controller,
      autofocus: widget.autofocus,
      textInputAction: TextInputAction.search,
      style: const TextStyle(fontSize: FontSizes.body),
      onTapOutside: (_) => FocusScope.of(context).unfocus(),
      onChanged: _emit,
      onSubmitted: (v) {
        _emit(v, immediately: true);
        widget.onSubmitted?.call(v.trim());
      },
      decoration: InputDecoration(
        hintText: widget.hintText,
        isDense: true,
        filled: widget.round,
        fillColor: widget.round ? c.background : null,
        border: widget.round ? pill : null,
        enabledBorder: widget.round ? pill : null,
        focusedBorder: widget.round ? pill : null,
        contentPadding: widget.round ? const EdgeInsets.symmetric(vertical: Insets.sm) : null,
        prefixIcon: Icon(Icons.search, size: 20, color: c.textHint),
        suffixIcon: _controller.text.isEmpty
            ? null
            : IconButton(
                icon: Icon(Icons.cancel, size: 18, color: c.textHint),
                onPressed: () {
                  _controller.clear();
                  _emit('', immediately: true);
                },
              ),
      ),
    );
  }
}
