import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xjj_app_base/core/network/api_client.dart';
import 'package:xjj_app_base/core/utils/ref_ext.dart';
import 'package:xjj_app_base/features/contract/data/contract.dart';
import 'package:xjj_app_base/features/contract/data/contract_repository.dart';
import 'package:xjj_app_base/shared/pagination.dart';

/// 按状态筛选的分页列表：筛选条件作为 family 参数，每个状态各自一份列表和页码。
/// 参数是 `null` 表示全部。条件多的时候换成 record：`({ContractStatus? status, String keyword})`。
final contractListProvider = AsyncNotifierProvider.autoDispose
    .family<ContractListNotifier, PagedState<Contract>, ContractStatus?>(ContractListNotifier.new);

class ContractListNotifier extends PagedNotifier<Contract> {
  ContractListNotifier(this.status);

  final ContractStatus? status;

  @override
  Future<PagedState<Contract>> build() {
    // 切到别的 tab 后列表再留 1 分钟，切回来不用重新加载
    ref.cacheFor(const Duration(minutes: 1));
    return super.build();
  }

  @override
  Future<PageResult<Contract>> fetchPage(int page) => ref
      .read(contractRepositoryProvider)
      .fetchPage(page: page, size: pageSize, status: status, cancelToken: ref.cancelToken());
}

final contractDetailProvider = FutureProvider.autoDispose.family<Contract, String>(
  (ref, id) =>
      ref.watch(contractRepositoryProvider).fetchDetail(id, cancelToken: ref.cancelToken()),
);
