import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:xjj_app_base/app/routes.dart';
import 'package:xjj_app_base/features/shop/data/product.dart';
import 'package:xjj_app_base/features/shop/presentation/product_cover.dart';
import 'package:xjj_app_base/features/shop/shop_providers.dart';
import 'package:xjj_app_base/shared/pagination.dart';
import 'package:xjj_app_base/shared/ui/ui.dart';

/// 商品网格：`XPagedListView` 只管单列列表，网格、瀑布流这类布局
/// 直接用 `PagedNotifier` + `XRefresh` 自己摆，分页逻辑完全一样。
class ShopPage extends ConsumerWidget {
  const ShopPage({super.key});

  static const _spacing = 12.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(productListProvider.notifier);
    // 封面是正方形，下面的文字区高度固定，算出每格的总高度。
    // 文字区的高度跟着系统字体大小缩放，否则调大字体后最后一行会被裁掉
    final itemWidth = (context.screenSize.width - _spacing * 3) / 2;
    final grid = SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      mainAxisSpacing: _spacing,
      crossAxisSpacing: _spacing,
      mainAxisExtent: itemWidth + MediaQuery.textScalerOf(context).scale(100),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('商城'), actions: const [CartButton(), XGap.h4]),
      body: ref
          .watch(productListProvider)
          .when(
            loading: () => GridView.builder(
              padding: const XPad.all(_spacing),
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: grid,
              itemCount: 6,
              itemBuilder: (_, _) => const _ProductSkeleton(),
            ),
            error: (e, _) =>
                XErrorView(error: e, onRetry: () => ref.invalidate(productListProvider)),
            data: (state) => XRefresh(
              onRefresh: () async {
                try {
                  await notifier.refresh();
                  return IndicatorResult.success;
                } catch (e) {
                  XToast.error(e);
                  return IndicatorResult.fail;
                }
              },
              onLoad: state.hasMore
                  ? () async => switch (await notifier.loadMore()) {
                      LoadMoreResult.loaded || LoadMoreResult.noMore => IndicatorResult.success,
                      LoadMoreResult.failed => IndicatorResult.fail,
                      LoadMoreResult.skipped => IndicatorResult.none,
                    }
                  : null,
              child: GridView.builder(
                padding: const XPad.all(_spacing),
                gridDelegate: grid,
                itemCount: state.items.length,
                itemBuilder: (context, index) => ProductTile(state.items[index]),
              ),
            ),
          ),
    );
  }
}

class ProductTile extends StatelessWidget {
  const ProductTile(this.product, {super.key});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return XCard(
      padding: EdgeInsets.zero,
      onTap: () => context.push(Routes.productDetail(product.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(aspectRatio: 1, child: ProductCover(product)),
          Padding(
            padding: const XPad.ltrb(12, 10, 12, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                XText.body(product.name, weight: FontWeights.medium, maxLines: 1),
                XGap.v2,
                XText.caption(product.subtitle, maxLines: 1),
                XGap.v8,
                // 一行放得下：价格在左、销量在右；放不下（价格很长或系统字体调大）
                // 销量换到下一行完整显示，不截成看不懂的「1.2…」
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.end,
                  spacing: 4,
                  children: [
                    XText.money(product.price, fontSize: 17),
                    XText.caption('${Fmt.count(product.sales)}人付款', maxLines: 1),
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

class _ProductSkeleton extends StatelessWidget {
  const _ProductSkeleton();

  @override
  Widget build(BuildContext context) {
    return XCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(aspectRatio: 1, child: ColoredBox(color: context.xColors.fill)),
          const Padding(
            padding: XPad.all12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                XSkeleton(width: 110),
                XSkeleton(width: 80, height: 12),
                XSkeleton(width: 64, height: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
