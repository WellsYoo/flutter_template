import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:xjj_app_base/app/routes.dart';
import 'package:xjj_app_base/features/shop/data/product.dart';
import 'package:xjj_app_base/features/shop/presentation/product_cover.dart';
import 'package:xjj_app_base/features/shop/shop_providers.dart';
import 'package:xjj_app_base/shared/ui/ui.dart';

/// 商品详情：大图 + 价格 + 规格 / 数量选择 + 底部“加入购物车 / 立即购买”。
///
/// 规格、数量是只属于这个页面的临时状态，用 `setState`；
/// 购物车是跨页面共享的状态，写进 `cartProvider`。
class ProductDetailPage extends ConsumerStatefulWidget {
  const ProductDetailPage({super.key, required this.id});

  final String id;

  @override
  ConsumerState<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends ConsumerState<ProductDetailPage> {
  String? _spec;
  int _count = 1;

  Future<String?> _pickSpec(Product product) async {
    final spec = await XSheet.select(title: '选择规格', options: product.specs, selected: _spec);
    if (spec != null && mounted) setState(() => _spec = spec);
    return spec;
  }

  /// 没选规格先弹规格选择，选完继续加入购物车
  Future<bool> _addToCart(Product product) async {
    final spec = _spec ?? await _pickSpec(product);
    // await 之后页面可能已经关闭，这时不能再用 ref
    if (spec == null || !mounted) return false;
    ref.read(cartProvider.notifier).add(product, spec: spec, count: _count);
    return true;
  }

  Future<void> _onAdd(Product product) async {
    if (await _addToCart(product)) XToast.success('已加入购物车');
  }

  Future<void> _onBuy(Product product) async {
    if (await _addToCart(product) && mounted) unawaited(context.push(Routes.cart));
  }

  @override
  Widget build(BuildContext context) {
    final provider = productDetailProvider(widget.id);
    final value = ref.watch(provider);
    final product = value.value;

    return Scaffold(
      appBar: AppBar(title: const Text('商品详情'), actions: const [CartButton(), XGap.h4]),
      body: XAsyncView(
        value: value,
        onRetry: () => ref.invalidate(provider),
        data: (product) => ListView(
          children: [
            AspectRatio(aspectRatio: 1.2, child: ProductCover(product, iconSize: 112)),
            ColoredBox(
              color: context.xColors.card,
              child: Padding(
                padding: XPad.all16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        XText.money(product.price, fontSize: 28),
                        XGap.h8,
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: XText.caption(
                            '¥${Fmt.number(product.originalPrice)}',
                            lineThrough: true,
                          ),
                        ),
                        const Spacer(),
                        XText.caption('已售 ${Fmt.count(product.sales)}'),
                      ],
                    ),
                    XGap.v10,
                    XText.headline(product.name),
                    XGap.v4,
                    XText.secondary(product.subtitle),
                    if (product.tags.isNotEmpty) ...[
                      XGap.v10,
                      Wrap(
                        spacing: 6,
                        children: [
                          for (final tag in product.tags) XTag(tag, type: XTagType.danger),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            XFormSection(
              children: [
                XFormItem.select(
                  label: '规格',
                  value: _spec,
                  hint: '请选择颜色',
                  onTap: () => _pickSpec(product),
                ),
                XFormItem(
                  label: '数量',
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: XStepper(
                      value: _count,
                      max: 99,
                      onChanged: (v) => setState(() => _count = v),
                    ),
                  ),
                ),
                const XCell('配送', value: '48 小时内发货 · 包邮'),
              ],
            ),
            XGap.v12,
            ColoredBox(
              color: context.xColors.card,
              child: Padding(
                padding: XPad.all16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const XText.title('商品详情', bold: true),
                    XGap.v8,
                    XExpandableText(
                      product.description,
                      maxLines: 3,
                      style: context.textStyles.secondary,
                    ),
                  ],
                ),
              ),
            ),
            XGap.v24,
          ],
        ),
      ),
      bottomNavigationBar: product == null
          ? null
          : XBottomBar(
              children: [
                // 这两个按钮等的是用户操作（选规格），不是接口：
                // 用 unawaited，按钮不会在弹层打开期间一直转圈
                XButton.outline('加入购物车', onPressed: () => unawaited(_onAdd(product))),
                XButton.primary('立即购买', onPressed: () => unawaited(_onBuy(product))),
              ],
            ),
    );
  }
}
