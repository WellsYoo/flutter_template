import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:xjj_app_base/app/routes.dart';
import 'package:xjj_app_base/core/session/session.dart';
import 'package:xjj_app_base/features/home/dashboard_providers.dart';
import 'package:xjj_app_base/features/home/data/dashboard.dart';
import 'package:xjj_app_base/features/home/presentation/widgets/approval_section.dart';
import 'package:xjj_app_base/features/home/presentation/widgets/dashboard_header.dart';
import 'package:xjj_app_base/features/home/presentation/widgets/quick_actions.dart';
import 'package:xjj_app_base/shared/ui/ui.dart';

/// 工作台：非列表型首页的标准写法。
///
/// - 一个聚合接口对应一个 `AsyncNotifier`，页面用 `XAsyncView` 渲染加载 / 失败 / 数据
/// - 加载中不转圈，用和真实布局一致的骨架屏（`XAsyncView(loading:)`）
/// - 局部操作（审批）成功后直接改 provider 里的数据，不整页重新请求
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(sessionProvider.select((s) => s.displayName));

    return AnnotatedRegion<SystemUiOverlayStyle>(
      // 头部是深色渐变，状态栏图标用白色
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: XAsyncView<Dashboard>(
          value: ref.watch(dashboardProvider),
          onRetry: () => ref.invalidate(dashboardProvider),
          onRefresh: () => ref.read(dashboardProvider.notifier).refresh(),
          loading: _Body(name: name, data: null),
          data: (data) => _Body(name: name, data: data),
        ),
      ),
    );
  }
}

/// [data] 为 null 时渲染骨架屏，布局和有数据时一致，加载完成不会跳动。
class _Body extends StatelessWidget {
  const _Body({required this.name, required this.data});

  final String name;
  final Dashboard? data;

  List<QuickAction> _actions(BuildContext context) {
    final c = context.xColors;
    return [
      QuickAction(
        '新建合同',
        Icons.note_add_rounded,
        context.primary,
        () => context.push(Routes.contractNew),
      ),
      QuickAction(
        '合同',
        Icons.description_rounded,
        const Color(0xFF7B61FF),
        () => context.push(Routes.contracts),
      ),
      QuickAction('商城', Icons.storefront_rounded, c.warning, () => context.push(Routes.shop)),
      QuickAction('消息', Icons.chat_bubble_rounded, c.success, () => context.push(Routes.messages)),
      QuickAction(
        '文章',
        Icons.menu_book_rounded,
        const Color(0xFF14B8C4),
        () => context.push(Routes.articles),
      ),
      QuickAction(
        '组件',
        Icons.widgets_rounded,
        const Color(0xFFEB5E9B),
        () => context.push(Routes.uiKit),
      ),
      QuickAction(
        '主题',
        Icons.palette_rounded,
        const Color(0xFFF2A11B),
        () => context.push(Routes.theme),
      ),
      QuickAction(
        '设置',
        Icons.settings_rounded,
        c.textSecondary,
        () => context.push(Routes.settings),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final data = this.data;
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        DashboardHeader(name: name, data: data, onBell: () => context.push(Routes.messages)),
        Padding(
          padding: XPad.all16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              QuickActions(actions: _actions(context)),
              XGap.v24,
              if (data == null)
                const _ApprovalSkeleton()
              else
                ApprovalSection(
                  approvals: data.approvals,
                  onViewAll: () => context.push(Routes.contracts),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ApprovalSkeleton extends StatelessWidget {
  const _ApprovalSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const XSkeleton(width: 88, height: 20),
        XGap.v12,
        for (var i = 0; i < 3; i++) ...[
          const XCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                XSkeleton(width: 200),
                XSkeleton(width: 120, height: 12),
                XSkeleton(width: 96, height: 22),
              ],
            ),
          ),
          XGap.v12,
        ],
      ],
    );
  }
}
