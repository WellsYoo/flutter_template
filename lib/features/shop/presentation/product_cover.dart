import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:xjj_app_base/app/routes.dart';
import 'package:xjj_app_base/features/shop/data/product.dart';
import 'package:xjj_app_base/features/shop/shop_providers.dart';
import 'package:xjj_app_base/shared/ui/ui.dart';

/// 商品封面。演示数据没有图片，用“柔和渐变 + 品类图标”占位；
/// 有图片地址时直接显示图片：真实项目里这个组件可以整个换成 `XImage(product.cover)`。
class ProductCover extends StatelessWidget {
  const ProductCover(this.product, {super.key, this.radius = 0, this.iconSize = 56});

  final Product product;
  final double radius;
  final double iconSize;

  static const _icons = [
    Icons.headphones_rounded,
    Icons.keyboard_rounded,
    Icons.watch_rounded,
    Icons.chair_rounded,
    Icons.speaker_rounded,
    Icons.lightbulb_rounded,
    Icons.backpack_rounded,
    Icons.coffee_maker_rounded,
    Icons.videocam_rounded,
    Icons.local_cafe_rounded,
  ];

  /// 浅色 → 稍深的同色系，图标用更深的同色
  static const _palettes = [
    (Color(0xFFEAF1FF), Color(0xFFCADBFF), Color(0xFF3D6BE0)),
    (Color(0xFFFFF1E4), Color(0xFFFFD8B8), Color(0xFFE0752D)),
    (Color(0xFFE7F8EF), Color(0xFFC2EBD6), Color(0xFF1F9D6B)),
    (Color(0xFFF4ECFE), Color(0xFFDDCAFB), Color(0xFF7B4FD6)),
    (Color(0xFFFFEAEF), Color(0xFFFFCBD8), Color(0xFFD9476B)),
    (Color(0xFFE6F7F9), Color(0xFFC0E9EE), Color(0xFF1795A6)),
  ];

  @override
  Widget build(BuildContext context) {
    final cover = product.cover;
    if (cover != null && cover.isNotEmpty) {
      return XImage(cover, width: double.infinity, height: double.infinity, radius: radius);
    }
    final (from, to, deep) = _palettes[product.kind % _palettes.length];
    return XContainer(
      radius: radius,
      colors: [from, to],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      alignment: Alignment.center,
      child: Icon(_icons[product.kind % _icons.length], size: iconSize, color: deep),
    );
  }
}

/// 导航栏上的购物车按钮，角标跟着购物车件数变。
class CartButton extends ConsumerWidget {
  const CartButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      tooltip: '购物车',
      onPressed: () => context.push(Routes.cart),
      icon: XBadge(
        count: ref.watch(cartCountProvider),
        offset: const Offset(4, -4),
        child: const Icon(Icons.shopping_bag_outlined),
      ),
    );
  }
}
