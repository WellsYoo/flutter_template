import 'dart:async';

import 'package:flutter/material.dart';

/// 搜索框：输入停顿 [debounce] 后回调，带清除按钮。
///
/// ```dart
/// SearchField(onChanged: (v) => setState(() => keyword = v))
/// ```
class SearchField extends StatefulWidget {
  const SearchField({
    super.key,
    required this.onChanged,
    this.hintText = '搜索',
    this.debounce = const Duration(milliseconds: 400),
  });

  final ValueChanged<String> onChanged;
  final String hintText;
  final Duration debounce;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final _controller = TextEditingController();
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _emit(String value, {bool immediately = false}) {
    _timer?.cancel();
    if (immediately) {
      widget.onChanged(value.trim());
    } else {
      _timer = Timer(widget.debounce, () => widget.onChanged(value.trim()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      textInputAction: TextInputAction.search,
      onTapOutside: (_) => FocusScope.of(context).unfocus(),
      onChanged: (v) {
        setState(() {}); // 刷新清除按钮
        _emit(v);
      },
      onSubmitted: (v) => _emit(v, immediately: true),
      decoration: InputDecoration(
        hintText: widget.hintText,
        isDense: true,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _controller.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _controller.clear();
                  setState(() {});
                  _emit('', immediately: true);
                },
              ),
      ),
    );
  }
}
