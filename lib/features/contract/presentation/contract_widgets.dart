import 'package:flutter/material.dart';
import 'package:xjj_app_base/features/contract/data/contract.dart';
import 'package:xjj_app_base/shared/ui/ui.dart';

/// 状态 → 标签颜色的对应关系放在界面层，模型里不出现 UI 类型。
class ContractStatusTag extends StatelessWidget {
  const ContractStatusTag(this.status, {super.key});

  final ContractStatus status;

  @override
  Widget build(BuildContext context) => XTag(
    status.label,
    type: switch (status) {
      ContractStatus.pending => XTagType.warning,
      ContractStatus.active => XTagType.primary,
      ContractStatus.done => XTagType.success,
      ContractStatus.rejected => XTagType.danger,
    },
  );
}

/// 审批流程时间线：左边圆点 + 连接线，右边步骤名、处理人和时间。
class FlowTimeline extends StatelessWidget {
  const FlowTimeline(this.steps, {super.key});

  final List<FlowStep> steps;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < steps.length; i++)
          _FlowRow(step: steps[i], isLast: i == steps.length - 1),
      ],
    );
  }
}

class _FlowRow extends StatelessWidget {
  const _FlowRow({required this.step, required this.isLast});

  final FlowStep step;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final c = context.xColors;
    final (color, icon) = switch (step.state) {
      FlowState.done => (c.success, Icons.check_rounded),
      FlowState.current => (context.primary, Icons.more_horiz_rounded),
      FlowState.rejected => (c.danger, Icons.close_rounded),
      FlowState.waiting => (c.textDisabled, null),
    };
    final waiting = step.state == FlowState.waiting;
    final hint = switch (step.state) {
      FlowState.current => '处理中',
      FlowState.rejected => '已驳回 · ${Fmt.dateTime(step.time)}',
      FlowState.waiting => '等待处理',
      FlowState.done => Fmt.dateTime(step.time),
    };

    // IntrinsicHeight 让左侧连接线跟右侧文字一样高
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              XContainer(
                size: 20,
                circle: true,
                color: waiting ? null : color,
                borderColor: waiting ? color : null,
                borderWidth: 1.5,
                alignment: Alignment.center,
                child: icon == null ? null : Icon(icon, size: 13, color: Colors.white),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1.5,
                    margin: XPad.v4,
                    color: waiting ? c.divider : color.withValues(alpha: 0.35),
                  ),
                ),
            ],
          ),
          XGap.h12,
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  XText.body(
                    step.title,
                    weight: FontWeights.medium,
                    color: waiting ? c.textHint : null,
                  ),
                  XGap.v2,
                  XText.caption('${step.operator} · $hint'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
