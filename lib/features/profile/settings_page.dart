import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:xjj_app_base/app/routes.dart';
import 'package:xjj_app_base/core/config/app_config.dart';
import 'package:xjj_app_base/core/theme/theme_mode.dart';
import 'package:xjj_app_base/features/profile/profile_providers.dart';
import 'package:xjj_app_base/shared/ui/ui.dart';

/// 设置页：XFormSection + XCell 的典型用法（选择、开关、带确认的操作）。
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  static const _themeLabels = {
    ThemeMode.system: '跟随系统',
    ThemeMode.light: '浅色',
    ThemeMode.dark: '深色',
  };

  /// 演示用的缓存大小
  int _cacheBytes = 12902400;

  Future<void> _pickTheme() async {
    final mode = await XSheet.select(
      title: '主题模式',
      options: ThemeMode.values,
      selected: ref.read(themeModeProvider),
      labelOf: (m) => _themeLabels[m]!,
    );
    if (mode != null && mounted) await ref.read(themeModeProvider.notifier).set(mode);
  }

  Future<void> _clearCache() async {
    if (!await XDialog.confirm(content: '确定清除缓存吗？')) return;
    await XLoading.run(
      () => Future<void>.delayed(const Duration(milliseconds: 800)),
      message: '清理中',
    );
    if (!mounted) return;
    setState(() => _cacheBytes = 0);
    XToast.success('已清除');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          XFormSection(
            title: '外观',
            children: [
              XCell('主题模式', value: _themeLabels[ref.watch(themeModeProvider)], onTap: _pickTheme),
              XCell('品牌色与样式', onTap: () => context.push(Routes.theme)),
            ],
          ),
          XFormSection(
            title: '通知',
            children: [
              XCell(
                '消息通知',
                subtitle: '审批、系统公告等消息的推送',
                trailing: Switch(
                  value: ref.watch(notifyEnabledProvider),
                  onChanged: (v) => ref.read(notifyEnabledProvider.notifier).set(v),
                ),
              ),
            ],
          ),
          XFormSection(
            title: '通用',
            children: [
              XCell('清除缓存', value: Fmt.fileSize(_cacheBytes), onTap: _clearCache),
              const XCell('当前环境', value: AppConfig.env),
              const XCell('版本', value: '0.1.0'),
              XCell(
                '关于',
                onTap: () => XDialog.alert(
                  title: '关于',
                  content: 'Flutter 项目模板的示例应用。\nRiverpod + go_router + dio，无代码生成。',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
