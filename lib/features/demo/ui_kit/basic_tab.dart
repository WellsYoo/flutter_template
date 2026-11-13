import 'package:flutter/material.dart';
import 'package:xjj_app_base/core/network/api_exception.dart';
import 'package:xjj_app_base/features/demo/ui_kit/demo_block.dart';
import 'package:xjj_app_base/shared/ui/ui.dart';

/// 基础：文本、按钮、标签、容器、图片
class BasicTab extends StatelessWidget {
  const BasicTab({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.xColors;
    return DemoTab(
      children: [
        DemoBlock(
          title: 'XText 文本',
          code: "XText.title('标题')\nXText.secondary('说明', maxLines: 1)\nXText.money(12345.6)",
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 6,
            children: [
              const XText.headline('headline 18 · 页面标题'),
              const XText.title('title 16 · 卡片标题'),
              const XText.body('body 14 · 正文内容'),
              const XText.secondary('secondary 13 · 次要内容'),
              const XText.caption('caption 12 · 辅助说明'),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                spacing: 8,
                children: [
                  XText.money(12345.6),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 3),
                    child: XText.caption('¥15,999', lineThrough: true),
                  ),
                ],
              ),
            ],
          ),
        ),
        DemoBlock(
          title: 'XButton 类型与尺寸',
          code:
              "XButton.outline('次要', size: XButtonSize.small, onPressed: ...)\nXButton.danger('删除', confirm: '确定删除吗？', onPressed: ...)",
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  XButton.primary('主要', size: XButtonSize.small, onPressed: () {}),
                  XButton.outline('次要', size: XButtonSize.small, onPressed: () {}),
                  XButton.danger('危险', size: XButtonSize.small, onPressed: () {}),
                  XButton.text('文字', size: XButtonSize.small, onPressed: () {}),
                  const XButton.primary('禁用', size: XButtonSize.small, onPressed: null),
                ],
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  XButton.outline('图标', size: XButtonSize.small, icon: Icons.add, onPressed: () {}),
                  XButton.primary(
                    '胶囊 + 自定义色',
                    size: XButtonSize.small,
                    round: true,
                    color: c.warning,
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
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  XButton.primary('large', onPressed: () {}),
                  XButton.primary('medium', size: XButtonSize.medium, onPressed: () {}),
                  XButton.primary('small', size: XButtonSize.small, onPressed: () {}),
                ],
              ),
            ],
          ),
        ),
        DemoBlock(
          title: 'XButton 异步',
          code: 'onPressed 返回 Future：\n自动 loading、防重复点击、失败自动 toast',
          child: Column(
            spacing: 12,
            children: [
              XButton.primary(
                '提交（1 秒后成功）',
                block: true,
                onPressed: () => Future<void>.delayed(const Duration(seconds: 1)),
              ),
              XButton.outline(
                '提交（失败，自动提示）',
                block: true,
                onPressed: () async {
                  await Future<void>.delayed(const Duration(milliseconds: 600));
                  throw const ApiException(ApiErrorType.business, '余额不足');
                },
              ),
            ],
          ),
        ),
        const DemoBlock(
          title: 'XTag 标签',
          code:
              "XTag('待审核', type: XTagType.warning)\nXTag('VIP', color: Colors.purple, outlined: true)",
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              XTag('进行中'),
              XTag('已完成', type: XTagType.success),
              XTag('待审核', type: XTagType.warning),
              XTag('已驳回', type: XTagType.danger),
              XTag('已关闭', type: XTagType.gray),
              XTag('描边', outlined: true),
              XTag('自定义', color: Color(0xFF7B61FF), icon: Icons.star_rounded),
            ],
          ),
        ),
        DemoBlock(
          title: 'XContainer 容器',
          code: 'XContainer(colors: [c1, c2], radius: 12, shadow: true, onTap: ..., child: ...)',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              XContainer(
                size: 68,
                radius: 14,
                color: c.fill,
                alignment: Alignment.center,
                child: const XText.caption('圆角'),
              ),
              XContainer(
                size: 68,
                radius: 14,
                colors: brandGradient(context.primary),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                alignment: Alignment.center,
                child: const XText.caption('渐变', color: Colors.white),
              ),
              XContainer(
                size: 68,
                radius: 14,
                borderColor: context.primary,
                borderWidth: 1,
                alignment: Alignment.center,
                child: const XText.caption('边框'),
              ),
              XContainer(
                size: 68,
                radius: 14,
                color: c.card,
                shadow: true,
                alignment: Alignment.center,
                child: const XText.caption('阴影'),
              ),
              XContainer(
                size: 68,
                circle: true,
                color: context.primary.withValues(alpha: 0.12),
                alignment: Alignment.center,
                onTap: () => XToast.show('点击了圆形'),
                child: XText.caption('可点击', color: context.primary),
              ),
            ],
          ),
        ),
        const DemoBlock(
          title: 'XImage 图片',
          code: 'XImage(url, width: 120, height: 80, radius: 8)\nXImage.avatar(url, size: 40)',
          child: Row(
            spacing: 12,
            children: [
              XImage(null, size: 68, radius: 12),
              XImage('https://invalid.example/x.png', size: 68, radius: 12),
              XImage.avatar(null, size: 52),
              Expanded(child: XText.caption('地址为空 / 加载失败 / 头像，都有统一的占位')),
            ],
          ),
        ),
      ],
    );
  }
}
