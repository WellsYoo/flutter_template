import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xjj_app_base/app/app_config.dart';
import 'package:xjj_app_base/core/session/session.dart';
import 'package:xjj_app_base/core/theme/theme_mode.dart';
import 'package:xjj_app_base/shared/ui/ui.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  static const _themeLabels = {
    ThemeMode.system: '跟随系统',
    ThemeMode.light: '浅色',
    ThemeMode.dark: '深色',
  };

  Future<void> _pickTheme(WidgetRef ref) async {
    final mode = await XSheet.select(
      title: '主题',
      options: ThemeMode.values,
      selected: ref.read(themeModeProvider),
      labelOf: (m) => _themeLabels[m]!,
    );
    if (mode != null) await ref.read(themeModeProvider.notifier).set(mode);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final token = ref.watch(sessionProvider).token ?? '';
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('我的')),
      body: ListView(
        children: [
          ColoredBox(
            color: context.xColors.card,
            child: Padding(
              padding: XPad.all16,
              child: Row(
                children: [
                  const XImage.avatar(null, size: 56),
                  XGap.h12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        XText.title(token.replaceFirst('fake-token-', '')),
                        XGap.v4,
                        const XTag('普通会员'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          XFormSection(
            title: '设置',
            children: [
              XCell(
                '主题',
                icon: Icons.palette_outlined,
                value: _themeLabels[themeMode],
                onTap: () => _pickTheme(ref),
              ),
              const XCell('当前环境', icon: Icons.dns_outlined, value: AppConfig.env),
            ],
          ),
          XGap.v24,
          Padding(
            padding: XPad.page,
            child: XButton.outline(
              '退出登录',
              block: true,
              confirm: '确定退出登录吗？',
              onPressed: () => ref.read(sessionProvider.notifier).signOut(),
            ),
          ),
        ],
      ),
    );
  }
}
