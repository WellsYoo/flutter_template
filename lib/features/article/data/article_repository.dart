import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xjj_app_base/core/network/api_client.dart';
import 'package:xjj_app_base/core/network/api_exception.dart';
import 'package:xjj_app_base/features/article/data/article.dart';
import 'package:xjj_app_base/shared/pagination.dart';

abstract interface class ArticleRepository {
  Future<PageResult<Article>> fetchPage({
    required int page,
    required int size,
    String keyword = '',
    CancelToken? cancelToken,
  });
  Future<Article> fetchDetail(String id, {CancelToken? cancelToken});
}

/// 接入真实后端：`ApiArticleRepository(ref.watch(apiClientProvider))`
final articleRepositoryProvider = Provider<ArticleRepository>((ref) => FakeArticleRepository());

class ApiArticleRepository implements ArticleRepository {
  ApiArticleRepository(this._api);

  final ApiClient _api;

  @override
  Future<PageResult<Article>> fetchPage({
    required int page,
    required int size,
    String keyword = '',
    CancelToken? cancelToken,
  }) {
    return _api.get(
      '/articles',
      cancelToken: cancelToken,
      query: {'page': page, 'size': size, if (keyword.isNotEmpty) 'keyword': keyword},
      decode: (data) {
        final map = data! as Map<String, dynamic>;
        final list = (map['list'] as List<dynamic>).cast<Map<String, dynamic>>();
        return PageResult(
          items: list.map(Article.fromJson).toList(),
          hasMore: page * size < (map['total'] as int),
        );
      },
    );
  }

  @override
  Future<Article> fetchDetail(String id, {CancelToken? cancelToken}) => _api.get(
    '/articles/$id',
    cancelToken: cancelToken,
    decode: (d) => Article.fromJson(d! as Map<String, dynamic>),
  );
}

/// 演示用的本地假数据，共 [total] 条。
class FakeArticleRepository implements ArticleRepository {
  FakeArticleRepository({this.total = 45, this.delay = const Duration(milliseconds: 500)});

  final int total;
  final Duration delay;

  @override
  Future<PageResult<Article>> fetchPage({
    required int page,
    required int size,
    String keyword = '',
    CancelToken? cancelToken,
  }) async {
    await Future<void>.delayed(delay);
    final matched = [
      for (var i = 0; i < total; i++) _article(i),
    ].where((a) => a.title.contains(keyword)).toList();
    final start = ((page - 1) * size).clamp(0, matched.length);
    final end = (start + size).clamp(0, matched.length);
    return PageResult(items: matched.sublist(start, end), hasMore: end < matched.length);
  }

  @override
  Future<Article> fetchDetail(String id, {CancelToken? cancelToken}) async {
    await Future<void>.delayed(delay);
    // id 来自路由参数，可能是任意内容：像真实后端一样返回“不存在”，而不是让解析抛异常
    final i = int.tryParse(id);
    if (i == null || i < 0 || i >= total) {
      throw const ApiException(ApiErrorType.business, '文章不存在');
    }
    return _article(i);
  }

  Article _article(int i) => Article(
    id: '$i',
    title: '示例文章 #${i + 1}',
    summary: '这是第 ${i + 1} 条数据，用来演示分页列表、下拉刷新和详情页。',
    author: '作者 ${i % 5 + 1}',
    createdAt: DateTime(2025, 1, 1).add(Duration(hours: i * 7)),
  );
}
