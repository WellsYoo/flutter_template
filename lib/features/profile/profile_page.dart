import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:xjj_app_base/app/routes.dart';
import 'package:xjj_app_base/core/session/session.dart';
import 'package:xjj_app_base/shared/ui/ui.dart';

/// 个人中心：头像卡片 + 数据概览 + 功能入口。
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(sessionProvider.select((s) => s.displayName));
    final c = context.xColors;

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, context.safeTop + 16, 16, 24),
        children: [
          Row(
            children: [
              // 没有头像图片时，用名字首字做头像
              XContainer(
                size: 60,
                circle: true,
                colors: brandGradient(context.primary),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                alignment: Alignment.center,
                child: XText(
                  name.isEmpty ? '?' : name.characters.first.toUpperCase(),
                  size: 24,
                  bold: true,
                  color: Colors.white,
                ),
              ),
              XGap.h16,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    XText(name.orDefault('未命名用户'), size: 20, bold: true, maxLines: 1),
                    XGap.v6,
                    const Row(
                      spacing: 6,
                      children: [
                        XTag('法务部', type: XTagType.gray),
                        XTag('企业认证', icon: Icons.verified_rounded),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: '设置',
                icon: Icon(Icons.settings_outlined, color: c.textSecondary),
                onPressed: () => context.push(Routes.settings),
              ),
            ],
          ),
          XGap.v20,
          XCard(
            padding: XPad.v16,
            onTap: () => context.push(Routes.contracts),
            child: const Row(
              children: [_Stat('我的合同', '12'), _Stat('待我审批', '5'), _Stat('本月签约', '128.6万')],
            ),
          ),
          XGap.v12,
          _Group(
            children: [
              XCell(
                '我的合同',
                leading: const _CellIcon(Icons.description_rounded, Color(0xFF7B61FF)),
                onTap: () => context.push(Routes.contracts),
              ),
              XCell(
                '消息通知',
                leading: _CellIcon(Icons.chat_bubble_rounded, c.success),
                value: '4 条未读',
                valueColor: c.danger,
                onTap: () => context.push(Routes.messages),
              ),
              XCell(
                '购物车',
                leading: _CellIcon(Icons.shopping_bag_rounded, c.warning),
                onTap: () => context.push(Routes.cart),
              ),
            ],
          ),
          XGap.v12,
          _Group(
            children: [
              XCell(
                '主题与样式',
                leading: const _CellIcon(Icons.palette_rounded, Color(0xFFF2A11B)),
                onTap: () => context.push(Routes.theme),
              ),
              XCell(
                '设置',
                leading: _CellIcon(Icons.settings_rounded, c.textSecondary),
                onTap: () => context.push(Routes.settings),
              ),
            ],
          ),
          XGap.v24,
          XButton.outline(
            '退出登录',
            block: true,
            color: c.danger,
            confirm: '确定退出登录吗？',
            onPressed: () => ref.read(sessionProvider.notifier).signOut(),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(children: [XText(value, size: 20, bold: true), XGap.v2, XText.caption(label)]),
  );
}

/// 圆角卡片里放一组 XCell
class _Group extends StatelessWidget {
  const _Group({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => XCard(
    padding: EdgeInsets.zero,
    child: Column(children: children.separatedBy(const Divider(indent: 56))),
  );
}

class _CellIcon extends StatelessWidget {
  const _CellIcon(this.icon, this.color);

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => XContainer(
    size: 28,
    radius: 8,
    color: color.withValues(alpha: 0.12),
    alignment: Alignment.center,
    child: Icon(icon, size: 16, color: color),
  );
}
