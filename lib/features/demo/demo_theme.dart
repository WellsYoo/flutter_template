import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xjj_app_base/core/theme/x_theme.dart';

/// 示例里可选的品牌色
const demoBrandColors = <(String, Color)>[
  ('科技蓝', brandColor),
  ('靛紫', Color(0xFF5B5BD6)),
  ('青绿', Color(0xFF12A594)),
  ('森绿', Color(0xFF2F9E44)),
  ('暖橙', Color(0xFFF76808)),
  ('玫红', Color(0xFFE5484D)),
];

/// 演示“换品牌色”：`app.dart` 监听它，把颜色传给 `XTheme.create(primary:)`。
///
/// 仅用于示例，不持久化。真实项目的品牌色是固定的，直接改 `brandColor` 常量即可，
/// 删除示例时把 `app.dart` 里对它的引用一起去掉。
final demoBrandColorProvider = NotifierProvider<DemoBrandColorNotifier, Color>(
  DemoBrandColorNotifier.new,
);

class DemoBrandColorNotifier extends Notifier<Color> {
  @override
  Color build() => brandColor;

  void set(Color color) => state = color;
}
