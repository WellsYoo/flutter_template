import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:xjj_app_base/features/shop/data/product.dart';
import 'package:xjj_app_base/features/shop/presentation/product_cover.dart';
import 'package:xjj_app_base/features/shop/shop_providers.dart';
import 'package:xjj_app_base/shared/ui/ui.dart';

/// 购物车：读写 `cartProvider`。改数量、删除后，合计和别的页面上的角标自动更新。
class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  /// 传 notifier 而不是 ref：等接口的时候用户可能已经离开这个页面，
  /// 页面销毁后 ref 不能再用，notifier 不受影响。
  Future<void> _checkout(CartNotifier cart) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    cart.clear();
    XToast.success('下单成功');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(cartProvider);
    final cart = ref.read(cartProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('购物车'),
        actions: [
          if (items.isNotEmpty)
            XButton.text(
              '清空',
              confirm: '确定清空购物车吗？',
              color: context.xColors.textSecondary,
              onPressed: cart.clear,
            ),
        ],
      ),
      body: items.isEmpty
          ? XEmptyView(
              icon: Icons.shopping_bag_outlined,
              message: '购物车是空的',
              actionText: '去逛逛',
              onAction: () => context.pop(),
            )
          : ListView.separated(
              padding: XPad.all16,
              itemCount: items.length,
              separatorBuilder: (_, _) => XGap.v12,
              itemBuilder: (context, index) => _CartTile(
                items[index],
                onCount: (count) => cart.setCount(items[index], count),
                onRemove: () => cart.remove(items[index]),
              ),
            ),
      bottomNavigationBar: items.isEmpty
          ? null
          : XBottomBar(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    XText.caption('共 ${ref.watch(cartCountProvider)} 件，合计'),
                    XText.money(ref.watch(cartTotalProvider), fontSize: 20),
                  ],
                ),
                XButton.primary('去结算', onPressed: () => _checkout(cart)),
              ],
            ),
    );
  }
}

class _CartTile extends StatelessWidget {
  const _CartTile(this.item, {required this.onCount, required this.onRemove});

  final CartItem item;
  final ValueChanged<int> onCount;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return XCard(
      padding: XPad.all12,
      child: Row(
        children: [
          SizedBox.square(
            dimension: 84,
            child: ProductCover(item.product, radius: 10, iconSize: 36),
          ),
          XGap.h12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: XText.body(item.product.name, weight: FontWeights.medium, maxLines: 1),
                    ),
                    GestureDetector(
                      onTap: onRemove,
                      child: Icon(Icons.close_rounded, size: 18, color: context.xColors.textHint),
                    ),
                  ],
                ),
                XGap.v4,
                XTag(item.spec, type: XTagType.gray),
                XGap.v12,
                Row(
                  children: [
                    XText.money(item.product.price, fontSize: 16),
                    const Spacer(),
                    XStepper(value: item.count, max: 99, onChanged: onCount),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
