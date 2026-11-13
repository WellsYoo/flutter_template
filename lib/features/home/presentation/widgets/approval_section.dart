import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xjj_app_base/features/home/dashboard_providers.dart';
import 'package:xjj_app_base/features/home/data/dashboard.dart';
import 'package:xjj_app_base/shared/ui/ui.dart';

/// “待我审批”区块：标题行 + 审批卡片，没有待办时显示空状态。
class ApprovalSection extends ConsumerWidget {
  const ApprovalSection({super.key, required this.approvals, this.onViewAll});

  final List<Approval> approvals;
  final VoidCallback? onViewAll;

  /// 审批后提示。按钮的 loading 和失败 toast 由 XButton 处理，这里只管成功之后。
  Future<void> _decide(
    DashboardNotifier notifier,
    Approval approval, {
    required bool approved,
  }) async {
    await notifier.decide(approval, approved: approved);
    XToast.success(approved ? '已通过' : '已驳回');
  }

  Future<void> _openDetail(DashboardNotifier notifier, Approval approval) async {
    // 弹层只负责收集用户的选择，真正的请求放在弹层关闭之后，用全屏 loading 表示进行中
    final approved = await XSheet.custom<bool>((context) => _ApprovalSheet(approval));
    if (approved == null) return;
    try {
      await XLoading.run(() => _decide(notifier, approval, approved: approved), message: '提交中');
    } catch (e) {
      XToast.error(e);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 在 build 里取出 notifier 传给回调：回调里有 await（等弹层、等接口），
    // 等完之后这个组件可能已经不在了，那时 ref 不能再用
    final notifier = ref.read(dashboardProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const XPad.ltrb(4, 0, 0, 4),
          child: Row(
            children: [
              const XText.title('待我审批', bold: true),
              XGap.h8,
              if (approvals.isNotEmpty) XTag('${approvals.length}', type: XTagType.danger),
              const Spacer(),
              XButton.text('全部合同', size: XButtonSize.small, onPressed: onViewAll),
            ],
          ),
        ),
        if (approvals.isEmpty)
          const XCard(
            padding: XPad.v32,
            child: XEmptyView(icon: Icons.task_alt_rounded, message: '都处理完了，休息一下'),
          )
        else
          for (final approval in approvals) ...[
            XCard(
              key: ValueKey(approval.id),
              onTap: () => _openDetail(notifier, approval),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: XText.title(approval.title, maxLines: 1)),
                      XGap.h8,
                      const XTag('待审批', type: XTagType.warning),
                    ],
                  ),
                  XGap.v6,
                  XText.caption('${approval.applicant} · ${Fmt.timeAgo(approval.createdAt)}提交'),
                  XGap.v12,
                  Row(
                    children: [
                      XText.money(approval.amount, fontSize: 18, color: context.xColors.text),
                      const Spacer(),
                      XButton.outline(
                        '驳回',
                        size: XButtonSize.small,
                        color: context.xColors.textSecondary,
                        confirm: '确定驳回「${approval.title}」吗？',
                        onPressed: () => _decide(notifier, approval, approved: false),
                      ),
                      XGap.h8,
                      XButton.primary(
                        '通过',
                        size: XButtonSize.small,
                        onPressed: () => _decide(notifier, approval, approved: true),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            XGap.v12,
          ],
      ],
    );
  }
}

/// 审批详情弹层：点“通过 / 驳回”把结果 pop 回去。
class _ApprovalSheet extends StatelessWidget {
  const _ApprovalSheet(this.approval);

  final Approval approval;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const XPad.ltrb(20, 12, 20, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: XContainer(width: 36, height: 4, radius: 2, color: context.xColors.border)),
          XGap.v16,
          XText.headline(approval.title),
          XGap.v12,
          XContainer(
            padding: const XPad.hv(12, 8),
            radius: 12,
            color: context.xColors.fill,
            child: Column(
              children: [
                XInfoRow('合同编号', approval.id),
                XInfoRow('申请人', approval.applicant),
                XInfoRow('合同金额', '¥${Fmt.money(approval.amount)}'),
                XInfoRow('提交时间', Fmt.dateTime(approval.createdAt)),
              ],
            ),
          ),
          XGap.v20,
          Row(
            spacing: 12,
            children: [
              Expanded(
                child: XButton.outline('驳回', onPressed: () => Navigator.pop(context, false)),
              ),
              Expanded(child: XButton.primary('通过', onPressed: () => Navigator.pop(context, true))),
            ],
          ),
        ],
      ),
    );
  }
}
