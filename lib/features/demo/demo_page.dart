import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:xjj_app_base/app/routes.dart';
import 'package:xjj_app_base/features/demo/demo_list_page.dart';
import 'package:xjj_app_base/shared/ui/ui.dart';

/// 示例目录：每一行是一个可以照着抄的场景，副标题写的是它用到的写法。
class DemoPage extends StatelessWidget {
  const DemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.xColors;
    void push(String location) => context.push(location);

    return Scaffold(
      appBar: AppBar(title: const Text('示例')),
      body: ListView(
        padding: const XPad.ltrb(16, 4, 16, 24),
        children: [
          _Section(
            title: '业务场景',
            children: [
              _Entry(
                '工作台',
                '聚合接口 · 骨架屏 · 局部更新',
                Icons.space_dashboard_rounded,
                context.primary,
                () => context.go(Routes.home),
              ),
              _Entry(
                '合同列表',
                '状态筛选 · family 分页 · 缓存',
                Icons.description_rounded,
                const Color(0xFF7B61FF),
                () => push(Routes.contracts),
              ),
              _Entry(
                '合同详情',
                '信息分组 · 审批时间线 · 动态操作栏',
                Icons.fact_check_rounded,
                const Color(0xFF7B61FF),
                () => push(Routes.contractDetail('0')),
              ),
              _Entry(
                '新建合同',
                '表单录入 · 校验 · 提交',
                Icons.note_add_rounded,
                context.primary,
                () => push(Routes.contractNew),
              ),
              _Entry(
                '商城',
                '网格分页 · 购物车共享状态',
                Icons.storefront_rounded,
                c.warning,
                () => push(Routes.shop),
              ),
              _Entry(
                '消息',
                '左滑删除 · 已读 · 乐观更新',
                Icons.chat_bubble_rounded,
                c.success,
                () => push(Routes.messages),
              ),
              _Entry(
                '文章',
                '搜索防抖 · 取消旧请求',
                Icons.menu_book_rounded,
                const Color(0xFF14B8C4),
                () => push(Routes.articles),
              ),
            ],
          ),
          _Section(
            title: '组件与样式',
            children: [
              _Entry(
                '组件一览',
                '按钮 · 弹层 · 表单 · 状态视图…',
                Icons.widgets_rounded,
                const Color(0xFFEB5E9B),
                () => push(Routes.uiKit),
              ),
              _Entry(
                '主题与样式',
                '品牌色 · 深浅色 · 字号 · 间距',
                Icons.palette_rounded,
                const Color(0xFFF2A11B),
                () => push(Routes.theme),
              ),
              _Entry(
                '设置页',
                '列表行 · 开关 · 本地存储',
                Icons.settings_rounded,
                c.textSecondary,
                () => push(Routes.settings),
              ),
            ],
          ),
          _Section(
            title: '列表的各种状态',
            children: [
              for (final s in ListScenario.values)
                _Entry(
                  s.title,
                  s.description,
                  s.icon,
                  c.textSecondary,
                  () => push(Routes.demoList(s)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Entry {
  const _Entry(this.title, this.subtitle, this.icon, this.color, this.onTap);

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<_Entry> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const XPad.ltrb(4, 16, 4, 8),
          child: XText.secondary(title, weight: FontWeights.medium),
        ),
        XCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: <Widget>[
              for (final e in children)
                XCell(
                  e.title,
                  subtitle: e.subtitle,
                  leading: XContainer(
                    size: 36,
                    radius: 11,
                    color: e.color.withValues(alpha: 0.12),
                    alignment: Alignment.center,
                    child: Icon(e.icon, size: 19, color: e.color),
                  ),
                  onTap: e.onTap,
                ),
            ].separatedBy(const Divider(indent: 64)),
          ),
        ),
      ],
    );
  }
}
