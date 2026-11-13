import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:xjj_app_base/app/routes.dart';
import 'package:xjj_app_base/features/contract/contract_providers.dart';
import 'package:xjj_app_base/features/contract/data/contract.dart';
import 'package:xjj_app_base/features/contract/presentation/contract_widgets.dart';
import 'package:xjj_app_base/shared/ui/ui.dart';

/// 带状态筛选的列表：顶部 tab 切换筛选条件，每个 tab 是一个独立的分页列表。
class ContractListPage extends StatelessWidget {
  const ContractListPage({super.key});

  /// null 表示“全部”
  static const _tabs = <ContractStatus?>[null, ...ContractStatus.values];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('合同'),
          actions: [
            IconButton(
              tooltip: '新建合同',
              icon: const Icon(Icons.add_rounded),
              onPressed: () => context.push(Routes.contractNew),
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [for (final status in _tabs) Tab(text: status?.label ?? '全部', height: 40)],
          ),
        ),
        body: TabBarView(
          children: [
            for (final status in _tabs)
              XPagedListView(
                // 切换 tab 时保留各自的滚动位置
                key: PageStorageKey(status),
                provider: contractListProvider(status),
                empty: XEmptyView(message: '没有${status?.label ?? ''}的合同'),
                itemBuilder: (context, contract, _) => ContractTile(contract),
              ),
          ],
        ),
      ),
    );
  }
}

class ContractTile extends StatelessWidget {
  const ContractTile(this.contract, {super.key});

  final Contract contract;

  @override
  Widget build(BuildContext context) {
    final c = context.xColors;
    return XCard(
      onTap: () => context.push(Routes.contractDetail(contract.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: XText.title(contract.title, maxLines: 1)),
              XGap.h8,
              ContractStatusTag(contract.status),
            ],
          ),
          XGap.v8,
          XText.secondary(contract.customer, maxLines: 1),
          XGap.v12,
          const Divider(),
          XGap.v12,
          Row(
            children: [
              XText.money(contract.amount, fontSize: 17, color: c.text),
              const Spacer(),
              Icon(Icons.person_outline_rounded, size: 14, color: c.textHint),
              XGap.h2,
              XText.caption(contract.owner),
              XGap.h12,
              Icon(Icons.event_outlined, size: 14, color: c.textHint),
              XGap.h2,
              XText.caption(Fmt.date(contract.signDate)),
            ],
          ),
        ],
      ),
    );
  }
}
