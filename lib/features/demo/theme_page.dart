import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xjj_app_base/core/theme/theme_mode.dart';
import 'package:xjj_app_base/features/demo/demo_theme.dart';
import 'package:xjj_app_base/shared/ui/ui.dart';

/// 主题与样式：色板、文字层级、间距、圆角；顶部可切换深浅色和品牌色，立即生效。
class ThemePage extends ConsumerWidget {
  const ThemePage({super.key});

  static const _modes = {ThemeMode.system: '跟随系统', ThemeMode.light: '浅色', ThemeMode.dark: '深色'};

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.xColors;
    final brand = ref.watch(demoBrandColorProvider);
    final mode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('主题与样式')),
      body: ListView(
        padding: XPad.all16,
        children: [
          _Block(
            title: '品牌色',
            hint: '改 app.dart 里 XTheme.create(primary:) 即可，这里只是实时预览',
            child: Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                for (final (name, color) in demoBrandColors)
                  GestureDetector(
                    onTap: () => ref.read(demoBrandColorProvider.notifier).set(color),
                    child: Column(
                      children: [
                        XContainer(
                          size: 40,
                          circle: true,
                          color: color,
                          alignment: Alignment.center,
                          child: color == brand
                              ? const Icon(Icons.check_rounded, size: 20, color: Colors.white)
                              : null,
                        ),
                        XGap.v6,
                        XText.caption(name, color: color == brand ? c.text : c.textHint),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          _Block(
            title: '深浅色',
            hint: 'themeModeProvider 已持久化，重启后保持',
            child: Row(
              spacing: 8,
              children: [
                for (final entry in _modes.entries)
                  Expanded(
                    child: entry.key == mode
                        ? XButton.primary(entry.value, size: XButtonSize.small, onPressed: () {})
                        : XButton.outline(
                            entry.value,
                            size: XButtonSize.small,
                            color: c.textSecondary,
                            onPressed: () => ref.read(themeModeProvider.notifier).set(entry.key),
                          ),
                  ),
              ],
            ),
          ),
          _Block(
            title: '语义色 context.xColors',
            hint: '颜色跟着深浅色主题变，页面里不要写裸色值',
            child: Column(
              children: [
                for (final (name, color) in <(String, Color)>[
                  ('text', c.text),
                  ('textSecondary', c.textSecondary),
                  ('textHint', c.textHint),
                  ('textDisabled', c.textDisabled),
                  ('divider', c.divider),
                  ('border', c.border),
                  ('background', c.background),
                  ('card', c.card),
                  ('fill', c.fill),
                  ('success', c.success),
                  ('warning', c.warning),
                  ('danger', c.danger),
                ])
                  Padding(
                    padding: XPad.v4,
                    child: Row(
                      children: [
                        XContainer(
                          size: 22,
                          radius: 6,
                          color: color,
                          border: true,
                          borderColor: c.border,
                        ),
                        XGap.h12,
                        XText.body('xColors.$name'),
                        const Spacer(),
                        XText.caption(_hex(color)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          _Block(
            title: '文字层级 context.textStyles',
            hint: '和 XText 用的是同一套',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 6,
              children: [
                _StyleRow('headline', 18, context.textStyles.headline),
                _StyleRow('title', 16, context.textStyles.title),
                _StyleRow('body', 14, context.textStyles.body),
                _StyleRow('secondary', 13, context.textStyles.secondary),
                _StyleRow('caption', 12, context.textStyles.caption),
              ],
            ),
          ),
          _Block(
            title: '间距 XGap / XPad',
            hint: '预设 2 / 4 / 6 / 8 / 10 / 12 / 16 / 20 / 24 / 32，自定义 XGap.v(18)',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                for (final size in const [4.0, 8.0, 12.0, 16.0, 24.0, 32.0])
                  Row(
                    children: [
                      XContainer(
                        width: size * 3,
                        height: 12,
                        radius: 3,
                        color: brand.withValues(alpha: 0.35),
                      ),
                      XGap.h12,
                      XText.caption('${size.toInt()}'),
                    ],
                  ),
              ],
            ),
          ),
          _Block(
            title: '圆角',
            hint: 'XTheme.create(radius: 12) 改全局默认',
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final radius in const [4.0, 8.0, 12.0, 16.0, 24.0])
                  XContainer(
                    size: 60,
                    radius: radius,
                    color: brand.withValues(alpha: 0.12),
                    alignment: Alignment.center,
                    child: XText.caption('${radius.toInt()}'),
                  ),
                XContainer(
                  size: 60,
                  circle: true,
                  color: brand.withValues(alpha: 0.12),
                  alignment: Alignment.center,
                  child: const XText.caption('圆形'),
                ),
              ],
            ),
          ),
          _Block(
            title: '组件预览',
            child: Column(
              spacing: 12,
              children: [
                Row(
                  spacing: 8,
                  children: [
                    XButton.primary('主按钮', onPressed: () {}),
                    XButton.outline('次按钮', onPressed: () {}),
                  ],
                ),
                XCard(
                  color: c.fill,
                  child: Row(
                    children: [
                      const XTag('标签'),
                      XGap.h8,
                      const XTag('成功', type: XTagType.success),
                      const Spacer(),
                      Switch(value: true, onChanged: (_) {}),
                    ],
                  ),
                ),
                const XSearchField(round: true, hintText: '搜索框'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _hex(Color color) =>
      '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
}

class _StyleRow extends StatelessWidget {
  const _StyleRow(this.name, this.size, this.style);

  final String name;
  final double size;
  final TextStyle style;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.baseline,
    textBaseline: TextBaseline.alphabetic,
    children: [
      SizedBox(width: 84, child: XText.caption('$name $size')),
      Expanded(child: Text('示例文字 Aa 123', style: style, maxLines: 1)),
    ],
  );
}

class _Block extends StatelessWidget {
  const _Block({required this.title, required this.child, this.hint});

  final String title;
  final String? hint;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: XCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          XText.title(title, bold: true),
          if (hint != null) ...[XGap.v4, XText.caption(hint!)],
          XGap.v16,
          child,
        ],
      ),
    ),
  );
}
