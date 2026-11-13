import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xjj_app_base/features/contract/contract_providers.dart';
import 'package:xjj_app_base/features/contract/data/contract.dart';
import 'package:xjj_app_base/features/contract/presentation/contract_widgets.dart';
import 'package:xjj_app_base/shared/ui/ui.dart';

/// 业务详情页：概览卡 + 信息分组 + 审批流程 + 随状态变化的底部操作栏。
class ContractDetailPage extends ConsumerWidget {
  const ContractDetailPage({super.key, required this.id});

  final String id;

  Future<void> _act(String done) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    XToast.success(done);
  }

  /// 不同状态能做的操作不一样；没有可做的操作就不显示底部栏
  List<Widget> _actions(ContractStatus status) => switch (status) {
    ContractStatus.pending => [
      XButton.outline('驳回', confirm: '确定驳回这份合同吗？', onPressed: () => _act('已驳回')),
      XButton.primary('通过', onPressed: () => _act('已通过')),
    ],
    ContractStatus.active => [
      XButton.outline('申请终止', confirm: '终止后不可恢复，确定申请终止吗？', onPressed: () => _act('已提交终止申请')),
      XButton.primary('续签', onPressed: () => _act('已发起续签')),
    ],
    ContractStatus.rejected => [XButton.primary('重新提交', onPressed: () => _act('已重新提交'))],
    ContractStatus.done => const [],
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = contractDetailProvider(id);
    final value = ref.watch(provider);
    final actions = value.hasValue ? _actions(value.requireValue.status) : const <Widget>[];

    return Scaffold(
      appBar: AppBar(title: const Text('合同详情')),
      body: XAsyncView(
        value: value,
        onRetry: () => ref.invalidate(provider),
        onRefresh: () => ref.refresh(provider.future),
        data: (contract) => ListView(
          padding: XPad.all16,
          children: [
            _Overview(contract),
            XGap.v12,
            _Section(
              title: '基本信息',
              child: Column(
                children: [
                  XInfoRow('合同编号', 'HT-2025-${contract.id.padLeft(6, '0')}'),
                  XInfoRow('客户', contract.customer),
                  XInfoRow('经办人', contract.owner),
                  XInfoRow('签订日期', Fmt.date(contract.signDate)),
                  XInfoRow('到期日期', Fmt.date(contract.signDate.addMonths(12))),
                ],
              ),
            ),
            XGap.v12,
            _Section(title: '审批流程', child: FlowTimeline(contract.flow)),
            XGap.v12,
            _Section(
              title: '付款条款',
              child: XExpandableText(
                contract.remark,
                maxLines: 2,
                style: context.textStyles.secondary,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: actions.isEmpty ? null : XBottomBar(children: actions),
    );
  }
}

class _Overview extends StatelessWidget {
  const _Overview(this.contract);

  final Contract contract;

  @override
  Widget build(BuildContext context) {
    return XCard(
      padding: XPad.all20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ContractStatusTag(contract.status),
          XGap.v10,
          XText.headline(contract.title),
          XGap.v16,
          const XText.caption('合同金额'),
          XGap.v2,
          XText.money(contract.amount, fontSize: 26, color: context.xColors.text),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return XCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [XText.title(title, bold: true), XGap.v12, child],
      ),
    );
  }
}
