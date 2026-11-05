import 'package:flutter/material.dart';
import 'package:xjj_app_base/core/network/api_exception.dart';
import 'package:xjj_app_base/shared/ui/ui.dart';

/// 组件一览：文本、按钮、标签、卡片、图片、反馈、弹层。
class UiKitPage extends StatelessWidget {
  const UiKitPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('组件')),
      body: ListView(
        padding: const EdgeInsets.all(Insets.lg),
        children: [
          _Block(
            title: 'AppText 文本',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Insets.xs,
              children: [
                const AppText.headline('headline 18 页面标题'),
                const AppText.title('title 16 卡片标题'),
                const AppText.body('body 14 正文内容'),
                const AppText.secondary('secondary 13 次要内容'),
                const AppText.caption('caption 12 辅助说明'),
                AppText.money(12345.6),
              ],
            ),
          ),
          _Block(
            title: 'AppButton 按钮（返回 Future 自动 loading）',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Insets.md,
              children: [
                AppButton.primary(
                  '异步提交',
                  block: true,
                  onPressed: () => Future<void>.delayed(const Duration(seconds: 1)),
                ),
                AppButton.primary(
                  '异步失败（自动 toast）',
                  block: true,
                  onPressed: () async {
                    await Future<void>.delayed(const Duration(milliseconds: 600));
                    throw const ApiException(ApiErrorType.business, '余额不足');
                  },
                ),
                Wrap(
                  spacing: Insets.sm,
                  runSpacing: Insets.sm,
                  children: [
                    AppButton.primary('主要', size: ButtonSize.small, onPressed: () {}),
                    AppButton.outline('次要', size: ButtonSize.small, onPressed: () {}),
                    AppButton.danger('危险', size: ButtonSize.small, onPressed: () {}),
                    AppButton.text('文字', size: ButtonSize.small, onPressed: () {}),
                    const AppButton.primary('禁用', size: ButtonSize.small, onPressed: null),
                    AppButton.outline(
                      '图标',
                      size: ButtonSize.small,
                      icon: Icons.add,
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
          const _Block(
            title: 'AppTag 标签',
            child: Wrap(
              spacing: Insets.sm,
              children: [
                AppTag('进行中'),
                AppTag('已完成', type: TagType.success),
                AppTag('待审核', type: TagType.warning),
                AppTag('已驳回', type: TagType.danger),
                AppTag('已关闭', type: TagType.gray),
              ],
            ),
          ),
          _Block(
            title: 'AppCard + InfoRow',
            child: AppCard(
              onTap: () => Toast.show('点击卡片'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Expanded(child: AppText.title('某某工程采购合同')),
                      AppTag('待审核', type: TagType.warning),
                    ],
                  ),
                  const SizedBox(height: Insets.sm),
                  const InfoRow('合同编号', 'HT-2025-000123'),
                  const InfoRow('供应商', '某某建材有限公司'),
                  InfoRow('合同金额', '¥${Fmt.money(1280000)}', valueColor: context.appColors.danger),
                  const InfoRow('备注', null),
                ],
              ),
            ),
          ),
          const _Block(
            title: 'AppImage 图片',
            child: Row(
              spacing: Insets.md,
              children: [
                AppImage.network(null, width: 64, height: 64, radius: Radii.md),
                AppImage.network('https://invalid.example/x.png', width: 64, height: 64),
                AppImage.network(null, width: 48, height: 48, radius: 24),
              ],
            ),
          ),
          _Block(
            title: '反馈',
            child: Wrap(
              spacing: Insets.sm,
              runSpacing: Insets.sm,
              children: [
                _chip('Toast', () => Toast.show('这是一条提示')),
                _chip('成功', () => Toast.success('保存成功')),
                _chip('失败', () => Toast.error(const ApiException(ApiErrorType.network, '网络连接失败'))),
                _chip(
                  'Loading',
                  () => withLoading(
                    () => Future<void>.delayed(const Duration(seconds: 1)),
                    message: '加载中',
                  ),
                ),
                _chip('确认框', () async {
                  final ok = await AppDialog.confirm(
                    title: '删除',
                    content: '删除后不可恢复，确定删除吗？',
                    confirmText: '删除',
                    danger: true,
                  );
                  if (ok) Toast.show('已删除');
                }),
                _chip('提示框', () => AppDialog.alert(content: '您的账号将于 7 天后过期')),
              ],
            ),
          ),
          _Block(
            title: 'AppSheet 底部弹层',
            child: Wrap(
              spacing: Insets.sm,
              runSpacing: Insets.sm,
              children: [
                _chip('操作菜单', () async {
                  final i = await AppSheet.actions(['拍照', '从相册选择']);
                  if (i != null) Toast.show('选择了第 ${i + 1} 项');
                }),
                _chip('单选', () async {
                  final v = await AppSheet.select(title: '城市', options: ['北京', '上海', '深圳']);
                  if (v != null) Toast.show(v);
                }),
                _chip('多选', () async {
                  final v = await AppSheet.multiSelect(title: '标签', options: ['A', 'B', 'C']);
                  if (v != null) Toast.show(v.isEmpty ? '未选择' : v.join('、'));
                }),
                _chip('日期', () async {
                  final v = await AppSheet.date(title: '选择日期');
                  if (v != null) Toast.show(Fmt.date(v));
                }),
              ],
            ),
          ),
          const _Block(
            title: '状态视图',
            child: SizedBox(height: 160, child: EmptyView(message: 'EmptyView 空状态')),
          ),
        ],
      ),
    );
  }

  static Widget _chip(String label, VoidCallback onTap) =>
      AppButton.outline(label, size: ButtonSize.small, onPressed: onTap);
}

class _Block extends StatelessWidget {
  const _Block({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Insets.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppText.secondary(title, color: context.colors.primary),
          const SizedBox(height: Insets.sm),
          child,
        ],
      ),
    );
  }
}
