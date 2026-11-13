import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xjj_app_base/core/network/api_client.dart';
import 'package:xjj_app_base/features/shop/data/product.dart';
import 'package:xjj_app_base/features/shop/data/product_repository.dart';
import 'package:xjj_app_base/shared/pagination.dart';

final productListProvider =
    AsyncNotifierProvider.autoDispose<ProductListNotifier, PagedState<Product>>(
      ProductListNotifier.new,
    );

class ProductListNotifier extends PagedNotifier<Product> {
  @override
  int get pageSize => 10;

  @override
  Future<PageResult<Product>> fetchPage(int page) => ref
      .read(productRepositoryProvider)
      .fetchPage(page: page, size: pageSize, cancelToken: ref.cancelToken());
}

final productDetailProvider = FutureProvider.autoDispose.family<Product, String>(
  (ref, id) => ref.watch(productRepositoryProvider).fetchDetail(id, cancelToken: ref.cancelToken()),
);

/// 购物车：跨页面共享、有交互的状态用 `Notifier`。
///
/// 不 autoDispose，离开商城再回来数据还在。列表页的角标、详情页的“加入购物车”、
/// 购物车页都读写这一个 provider，任何一处改了其他地方自动刷新。
final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(CartNotifier.new);

class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() => const [];

  /// 已有同款同规格就累加数量，否则加一行
  void add(Product product, {required String spec, int count = 1}) {
    final index = state.indexWhere((e) => e.product.id == product.id && e.spec == spec);
    if (index < 0) {
      state = [...state, CartItem(product: product, spec: spec, count: count)];
    } else {
      setCount(state[index], state[index].count + count);
    }
  }

  void setCount(CartItem item, int count) {
    // 状态是不可变的：生成新列表赋值，而不是改原列表
    state = [
      for (final e in state)
        if (identical(e, item)) e.copyWith(count: count) else e,
    ];
  }

  void remove(CartItem item) => state = state.where((e) => !identical(e, item)).toList();

  void clear() => state = const [];
}

/// 从购物车派生的值单独做成 provider：只关心件数的地方（角标）不会因为别的字段变化而重建
final cartCountProvider = Provider<int>(
  (ref) => ref.watch(cartProvider).fold(0, (sum, e) => sum + e.count),
);

final cartTotalProvider = Provider<double>(
  (ref) => ref.watch(cartProvider).fold(0, (sum, e) => sum + e.subtotal),
);
