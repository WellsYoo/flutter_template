import 'package:flutter/material.dart';
import 'package:xjj_app_base/core/network/api_exception.dart';
import 'package:xjj_app_base/shared/ui/ui.dart';

/// 组件一览：文本、按钮、标签、卡片、列表行、图片、反馈、弹层。
class UiKitPage extends StatefulWidget {
  const UiKitPage({super.key});

  @override
  State<UiKitPage> createState() => _UiKitPageState();
}

class _UiKitPageState extends State<UiKitPage> {
  int _count = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('组件')),
      body: ListView(
        padding: const EdgeInsets.all(Insets.lg),
        children: [
          _Block(
            title: 'XText 文本',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Insets.xs,
              children: [
                const XText.headline('headline 18 页面标题'),
                const XText.title('title 16 卡片标题'),
                const XText.body('body 14 正文内容'),
                const XText.secondary('secondary 13 次要内容'),
                const XText.caption('caption 12 辅助说明'),
                const XText('自定义：size 20 + bold', size: 20, bold: true),
                const XText.secondary('原价 ¥199.00', lineThrough: true),
                XText.money(12345.6),
              ],
            ),
          ),
          _Block(
            title: 'XButton 按钮（返回 Future 自动 loading）',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Insets.md,
              children: [
                XButton.primary(
                  '异步提交',
                  block: true,
                  onPressed: () => Future<void>.delayed(const Duration(seconds: 1)),
                ),
                XButton.primary(
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
                    XButton.primary('主要', size: XButtonSize.small, onPressed: () {}),
                    XButton.outline('次要', size: XButtonSize.small, onPressed: () {}),
                    XButton.danger('危险', size: XButtonSize.small, onPressed: () {}),
                    XButton.text('文字', size: XButtonSize.small, onPressed: () {}),
                    const XButton.primary('禁用', size: XButtonSize.small, onPressed: null),
                    XButton.outline(
                      '图标',
                      size: XButtonSize.small,
                      icon: Icons.add,
                      onPressed: () {},
                    ),
                    XButton.primary(
                      '胶囊 + 自定义色',
                      size: XButtonSize.small,
                      round: true,
                      color: Colors.orange,
                      onPressed: () {},
                    ),
                    XButton.danger(
                      '带确认',
                      size: XButtonSize.small,
                      confirm: '删除后不可恢复，确定删除吗？',
                      onPressed: () => XToast.show('已删除'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const _Block(
            title: 'XTag 标签',
            child: Wrap(
              spacing: Insets.sm,
              children: [
                XTag('进行中'),
                XTag('已完成', type: XTagType.success),
                XTag('待审核', type: XTagType.warning),
                XTag('已驳回', type: XTagType.danger),
                XTag('已关闭', type: XTagType.gray),
                XTag('描边', outlined: true),
                XTag('自定义', color: Colors.purple, icon: Icons.star),
              ],
            ),
          ),
          _Block(
            title: 'XCard + XInfoRow',
            child: XCard(
              onTap: () => XToast.show('点击卡片'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Expanded(child: XText.title('某某工程采购合同')),
                      XTag('待审核', type: XTagType.warning),
                    ],
                  ),
                  const SizedBox(height: Insets.sm),
                  const XInfoRow('合同编号', 'HT-2025-000123'),
                  const XInfoRow('供应商', '某某建材有限公司'),
                  XInfoRow('合同金额', '¥${Fmt.money(1280000)}', valueColor: context.xColors.danger),
                  const XInfoRow('备注', null),
                ],
              ),
            ),
          ),
          _Block(
            title: 'XContainer 容器',
            child: Wrap(
              spacing: Insets.md,
              runSpacing: Insets.md,
              children: [
                XContainer(
                  size: 72,
                  radius: Radii.lg,
                  color: context.xColors.card,
                  alignment: Alignment.center,
                  child: const XText.caption('圆角'),
                ),
                const XContainer(
                  size: 72,
                  radius: Radii.lg,
                  colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
                  alignment: Alignment.center,
                  child: XText.caption('渐变', color: Colors.white),
                ),
                XContainer(
                  size: 72,
                  radius: Radii.lg,
                  borderColor: context.colors.primary,
                  borderWidth: 1,
                  alignment: Alignment.center,
                  child: const XText.caption('边框'),
                ),
                XContainer(
                  size: 72,
                  radius: Radii.lg,
                  color: context.xColors.card,
                  shadow: true,
                  alignment: Alignment.center,
                  child: const XText.caption('阴影'),
                ),
                XContainer(
                  size: 72,
                  circle: true,
                  color: context.colors.primary,
                  alignment: Alignment.center,
                  onTap: () => XToast.show('点击了圆形'),
                  child: const XText.caption('可点击', color: Colors.white),
                ),
                XContainer(
                  width: 72,
                  height: 72,
                  color: context.xColors.card,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  alignment: Alignment.center,
                  child: const XText.caption('上圆角'),
                ),
              ],
            ),
          ),
          const _Block(
            title: 'XImage 图片',
            child: Row(
              spacing: Insets.md,
              children: [
                XImage(null, size: 64, radius: Radii.md),
                XImage('https://invalid.example/x.png', size: 64),
                XImage.avatar(null, size: 48),
              ],
            ),
          ),
          _Block(
            title: '反馈',
            child: Wrap(
              spacing: Insets.sm,
              runSpacing: Insets.sm,
              children: [
                _chip('XToast', () => XToast.show('这是一条提示')),
                _chip('成功', () => XToast.success('保存成功')),
                _chip('失败', () => XToast.error(const ApiException(ApiErrorType.network, '网络连接失败'))),
                _chip(
                  'Loading',
                  () => XLoading.run(
                    () => Future<void>.delayed(const Duration(seconds: 1)),
                    message: '加载中',
                  ),
                ),
                _chip('确认框', () async {
                  final ok = await XDialog.confirm(
                    title: '删除',
                    content: '删除后不可恢复，确定删除吗？',
                    confirmText: '删除',
                    danger: true,
                  );
                  if (ok) XToast.show('已删除');
                }),
                _chip('提示框', () => XDialog.alert(content: '您的账号将于 7 天后过期')),
                _chip('输入框', () async {
                  final v = await XDialog.input(
                    title: '修改昵称',
                    maxLength: 12,
                    validator: (v) => v.isEmpty ? '昵称不能为空' : null,
                  );
                  if (v != null) XToast.show(v);
                }),
                _chip('底部 toast', () => XToast.show('显示在底部', position: XToastPosition.bottom)),
              ],
            ),
          ),
          _Block(
            title: 'XSheet 底部弹层',
            child: Wrap(
              spacing: Insets.sm,
              runSpacing: Insets.sm,
              children: [
                _chip('操作菜单', () async {
                  final i = await XSheet.actions(['拍照', '从相册选择', '删除'], danger: 2);
                  if (i != null) XToast.show('选择了第 ${i + 1} 项');
                }),
                _chip('单选', () async {
                  final v = await XSheet.select(title: '城市', options: ['北京', '上海', '深圳']);
                  if (v != null) XToast.show(v);
                }),
                _chip('多选', () async {
                  final v = await XSheet.multiSelect(title: '标签', options: ['A', 'B', 'C']);
                  if (v != null) XToast.show(v.isEmpty ? '未选择' : v.join('、'));
                }),
                _chip('日期', () async {
                  final v = await XSheet.date(title: '选择日期');
                  if (v != null) XToast.show(Fmt.date(v));
                }),
              ],
            ),
          ),
          _Block(
            title: 'XCell 列表行',
            child: XFormSection(
              margin: EdgeInsets.zero,
              children: [
                XCell('消息通知', icon: Icons.notifications_outlined, onTap: () {}),
                XCell('缓存', subtitle: '图片和临时文件', value: '12.3 MB', onTap: () {}),
                const XCell('版本', value: '1.0.0'),
              ],
            ),
          ),
          const _Block(title: 'XSearchField 搜索框', child: XSearchField(round: true)),
          _Block(
            title: '角标 / 步进器 / 验证码倒计时',
            child: Wrap(
              spacing: Insets.xl,
              runSpacing: Insets.md,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const XBadge(count: 8, child: Icon(Icons.notifications_outlined)),
                const XBadge(count: 120, child: Icon(Icons.mail_outline)),
                const XBadge(dot: true, child: XText.body('消息')),
                XStepper(value: _count, max: 5, onChanged: (v) => setState(() => _count = v)),
                XCountdownButton(
                  seconds: 10,
                  onSend: () => Future<void>.delayed(const Duration(milliseconds: 500)),
                ),
              ],
            ),
          ),
          const _Block(
            title: 'XExpandableText 展开收起',
            child: XExpandableText(
              '这是一段比较长的文字，用来演示超过指定行数之后自动折叠，并在末尾显示“展开”。'
              '点击展开后显示全部内容，末尾变成“收起”，再点一次恢复折叠。'
              '常用于商品详情、评论、公告这类长度不确定的内容。',
              maxLines: 2,
            ),
          ),
          const _Block(
            title: 'XSkeleton 骨架屏',
            child: Row(
              children: [
                XSkeleton.circle(),
                SizedBox(width: Insets.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: Insets.sm,
                    children: [XSkeleton(), XSkeleton(width: 120)],
                  ),
                ),
              ],
            ),
          ),
          _Block(
            title: '状态视图',
            child: SizedBox(
              height: 200,
              child: XEmptyView(
                message: 'XEmptyView 空状态',
                actionText: '去看看',
                onAction: () => XToast.show('点击了按钮'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _chip(String label, VoidCallback onTap) =>
      XButton.outline(label, size: XButtonSize.small, onPressed: onTap);
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
          XText.secondary(title, color: context.colors.primary),
          const SizedBox(height: Insets.sm),
          child,
        ],
      ),
    );
  }
}
