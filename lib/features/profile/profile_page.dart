import 'dart:async';

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
    final mode = await AppSheet.select(
      title: '主题',
      options: ThemeMode.values,
      selected: ref.read(themeModeProvider),
      labelOf: (m) => _themeLabels[m]!,
    );
    if (mode != null) await ref.read(themeModeProvider.notifier).set(mode);
  }

  Future<void> _logout(WidgetRef ref) async {
    if (!await AppDialog.confirm(content: '确定退出登录吗？')) return;
    await ref.read(sessionProvider.notifier).signOut();
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
            color: context.appColors.card,
            child: Padding(
              padding: const EdgeInsets.all(Insets.lg),
              child: Row(
                children: [
                  const AppImage.network(null, width: 56, height: 56, radius: 28),
                  const SizedBox(width: Insets.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText.title(token.replaceFirst('fake-token-', '')),
                        const SizedBox(height: Insets.xs),
                        const AppTag('普通会员'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          FormSection(
            title: '设置',
            children: [
              FormItem.select(
                label: '主题',
                value: _themeLabels[themeMode],
                onTap: () => _pickTheme(ref),
              ),
              FormItem.text(label: '当前环境', value: AppConfig.env),
            ],
          ),
          const SizedBox(height: Insets.xl),
          Padding(
            padding: Insets.page,
            // 弹确认框不需要按钮 loading，所以不返回 Future
            child: AppButton.outline('退出登录', block: true, onPressed: () => unawaited(_logout(ref))),
          ),
        ],
      ),
    );
  }
}
