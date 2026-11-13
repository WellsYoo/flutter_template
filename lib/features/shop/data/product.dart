import 'package:xjj_app_base/core/utils/json.dart';

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.price,
    required this.originalPrice,
    required this.sales,
    required this.kind,
    this.cover,
    this.tags = const [],
    this.specs = const [],
    this.description = '',
  });

  final String id;
  final String name;
  final String subtitle;
  final double price;
  final double originalPrice;
  final int sales;

  /// 品类序号，没有封面图时用它决定占位封面的图标和配色
  final int kind;

  /// 封面图地址；演示数据没有图片，统一用占位封面
  final String? cover;
  final List<String> tags;
  final List<String> specs;
  final String description;

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json.str('id'),
    name: json.str('name'),
    subtitle: json.str('subtitle'),
    price: json.number('price'),
    originalPrice: json.number('originalPrice'),
    sales: json.integer('sales'),
    kind: json.integer('kind'),
    cover: json.strOrNull('cover'),
    tags: json.listOf<String>('tags'),
    specs: json.listOf<String>('specs'),
    description: json.str('description'),
  );
}

/// 购物车里的一行：同一商品不同规格算两行
class CartItem {
  const CartItem({required this.product, required this.spec, required this.count});

  final Product product;
  final String spec;
  final int count;

  double get subtotal => product.price * count;

  CartItem copyWith({int? count}) =>
      CartItem(product: product, spec: spec, count: count ?? this.count);
}
