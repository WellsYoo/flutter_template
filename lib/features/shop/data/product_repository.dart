import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xjj_app_base/core/network/api_client.dart';
import 'package:xjj_app_base/core/network/api_exception.dart';
import 'package:xjj_app_base/features/shop/data/product.dart';
import 'package:xjj_app_base/shared/pagination.dart';

abstract interface class ProductRepository {
  Future<PageResult<Product>> fetchPage({
    required int page,
    required int size,
    CancelToken? cancelToken,
  });
  Future<Product> fetchDetail(String id, {CancelToken? cancelToken});
}

/// 接入真实后端：`ApiProductRepository(ref.watch(apiClientProvider))`
final productRepositoryProvider = Provider<ProductRepository>((ref) => FakeProductRepository());

class ApiProductRepository implements ProductRepository {
  ApiProductRepository(this._api);

  final ApiClient _api;

  @override
  Future<PageResult<Product>> fetchPage({
    required int page,
    required int size,
    CancelToken? cancelToken,
  }) {
    return _api.get(
      '/products',
      cancelToken: cancelToken,
      query: {'page': page, 'size': size},
      decode: (data) {
        final map = data! as Map<String, dynamic>;
        final list = (map['list'] as List<dynamic>).cast<Map<String, dynamic>>();
        return PageResult(
          items: list.map(Product.fromJson).toList(),
          hasMore: page * size < (map['total'] as int),
        );
      },
    );
  }

  @override
  Future<Product> fetchDetail(String id, {CancelToken? cancelToken}) => _api.get(
    '/products/$id',
    cancelToken: cancelToken,
    decode: (d) => Product.fromJson(d! as Map<String, dynamic>),
  );
}

/// 演示用假数据，共 [total] 条
class FakeProductRepository implements ProductRepository {
  FakeProductRepository({this.total = 34, this.delay = const Duration(milliseconds: 500)});

  final int total;
  final Duration delay;

  static const _items = [
    ('无线降噪耳机', '40 小时续航 · 自适应降噪', 899.0, 1299.0),
    ('机械键盘 87 键', '热插拔轴体 · 三模连接', 459.0, 599.0),
    ('智能手表', '血氧心率监测 · 14 天续航', 1299.0, 1599.0),
    ('人体工学椅', '4D 扶手 · 腰托自适应', 1899.0, 2499.0),
    ('便携蓝牙音箱', 'IP67 防水 · 双单元立体声', 329.0, 399.0),
    ('护眼台灯', '全光谱 · 无频闪无蓝光', 269.0, 349.0),
    ('通勤双肩包', '16 寸电脑仓 · 防泼水面料', 239.0, 299.0),
    ('手冲咖啡壶套装', '细口壶 + 滤杯 + 分享壶', 189.0, 259.0),
    ('运动相机', '4K 60 帧 · 超级防抖', 1999.0, 2399.0),
    ('保温杯 500ml', '316 不锈钢 · 12 小时保温', 129.0, 169.0),
  ];
  static const _tags = [
    ['新品', '包邮'],
    ['热卖'],
    ['限时特惠', '包邮'],
    <String>[],
  ];

  @override
  Future<PageResult<Product>> fetchPage({
    required int page,
    required int size,
    CancelToken? cancelToken,
  }) async {
    await Future<void>.delayed(delay);
    final start = ((page - 1) * size).clamp(0, total);
    final end = (start + size).clamp(0, total);
    return PageResult(items: [for (var i = start; i < end; i++) _product(i)], hasMore: end < total);
  }

  @override
  Future<Product> fetchDetail(String id, {CancelToken? cancelToken}) async {
    await Future<void>.delayed(delay);
    final i = int.tryParse(id);
    if (i == null || i < 0 || i >= total) {
      throw const ApiException(ApiErrorType.business, '商品不存在或已下架');
    }
    return _product(i);
  }

  Product _product(int i) {
    final kind = i % _items.length;
    final (name, subtitle, price, originalPrice) = _items[kind];
    return Product(
      id: '$i',
      name: name,
      subtitle: subtitle,
      price: price,
      originalPrice: originalPrice,
      sales: 12800 - i * 317,
      kind: kind,
      tags: _tags[i % _tags.length],
      specs: const ['曜石黑', '云雾白', '海盐蓝'],
      description:
          '$name，$subtitle。采用环保材料与一体化工艺，细节处做了圆角与防滑处理，长时间使用也舒适。'
          '支持 7 天无理由退换和 1 年质保，全国联保。下单后 48 小时内发货，偏远地区配送时间可能延长。'
          '包装内含主体、说明书和保修卡，配件以实际收到的为准。',
    );
  }
}
