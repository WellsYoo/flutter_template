import 'package:flutter/material.dart';
import 'package:xjj_app_base/core/network/api_exception.dart';
import 'package:xjj_app_base/features/demo/ui_kit/demo_block.dart';
import 'package:xjj_app_base/shared/ui/ui.dart';

/// 展示：卡片、信息行、列表行、角标、长文本、骨架屏、状态视图
class DisplayTab extends StatelessWidget {
  const DisplayTab({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.xColors;
    return DemoTab(
      children: [
        DemoBlock(
          title: 'XCard + XInfoRow',
          code: "XCard(onTap: ..., child: Column(children: [\n  XInfoRow('合同编号', no),\n]))",
          child: XCard(
            color: c.fill,
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
                XGap.v8,
                const XInfoRow('合同编号', 'HT-2025-000123'),
                const XInfoRow('供应商', '某某建材有限公司'),
                XInfoRow('合同金额', '¥${Fmt.money(1280000)}', valueColor: c.danger),
                const XInfoRow('备注', null),
              ],
            ),
          ),
        ),
        DemoBlock(
          title: 'XCell 列表行',
          code: "XCell('缓存', icon: Icons.storage, value: '12 MB', onTap: _clear)",
          child: XContainer(
            radius: 12,
            clip: true,
            border: true,
            child: Column(
              children: <Widget>[
                XCell('消息通知', icon: Icons.notifications_outlined, onTap: () {}),
                XCell('缓存', subtitle: '图片和临时文件', value: '12.3 MB', onTap: () {}),
                const XCell('版本', value: '1.0.0'),
              ].separatedBy(const Divider(indent: 16)),
            ),
          ),
        ),
        const DemoBlock(
          title: 'XBadge 角标',
          code: 'XBadge(count: unread, child: Icon(...))\nXBadge(dot: hasNew, child: Text(...))',
          child: Row(
            spacing: 32,
            children: [
              XBadge(count: 8, child: Icon(Icons.notifications_outlined, size: 28)),
              XBadge(count: 120, child: Icon(Icons.mail_outline_rounded, size: 28)),
              XBadge(dot: true, child: Icon(Icons.chat_bubble_outline_rounded, size: 26)),
              XBadge(dot: true, child: XText.body('消息')),
            ],
          ),
        ),
        const DemoBlock(
          title: 'XExpandableText 展开收起',
          code: 'XExpandableText(content, maxLines: 2)',
          child: XExpandableText(
            '这是一段比较长的文字，用来演示超过指定行数之后自动折叠，并在末尾显示“展开”。'
            '点击展开后显示全部内容，末尾变成“收起”，再点一次恢复折叠。'
            '常用于商品详情、评论、公告这类长度不确定的内容。',
            maxLines: 2,
          ),
        ),
        const DemoBlock(
          title: 'XSkeleton 骨架屏',
          code: 'XSkeleton(width: 120)\nXSkeleton.circle(size: 40)',
          child: Row(
            children: [
              XSkeleton.circle(size: 44),
              XGap.h12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [XSkeleton(), XSkeleton(width: 140, height: 12)],
                ),
              ),
            ],
          ),
        ),
        DemoBlock(
          title: '状态视图',
          code:
              "XEmptyView(message: '还没有订单', actionText: '去逛逛', onAction: ...)\nXErrorView(error: e, onRetry: ...)",
          child: Row(
            children: [
              Expanded(
                child: XEmptyView(
                  message: '还没有订单',
                  actionText: '去逛逛',
                  onAction: () => XToast.show('点击了按钮'),
                ),
              ),
              Expanded(
                child: XErrorView(
                  error: const ApiException(ApiErrorType.network, '网络连接失败'),
                  onRetry: () => XToast.show('重试'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
