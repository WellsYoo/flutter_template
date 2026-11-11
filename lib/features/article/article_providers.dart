import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xjj_app_base/core/network/api_client.dart';
import 'package:xjj_app_base/features/article/data/article.dart';
import 'package:xjj_app_base/features/article/data/article_repository.dart';
import 'package:xjj_app_base/shared/pagination.dart';

/// 列表：继承 PagedNotifier，只写取数逻辑。
///
/// 用 family 按搜索词区分：搜索词变了就是另一个 provider，自动从第一页加载，
/// 不会和旧搜索的“加载更多”结果混在一起。筛选条件多时把参数换成 record，
/// 例如 `({String keyword, int? status})`。
final articleListProvider = AsyncNotifierProvider.autoDispose
    .family<ArticleListNotifier, PagedState<Article>, String>(ArticleListNotifier.new);

class ArticleListNotifier extends PagedNotifier<Article> {
  ArticleListNotifier(this.keyword);

  final String keyword;

  @override
  Future<PageResult<Article>> fetchPage(int page) => ref
      .read(articleRepositoryProvider)
      .fetchPage(
        page: page,
        size: pageSize,
        keyword: keyword,
        // 离开页面或搜索词变化时，取消还没返回的请求
        cancelToken: ref.cancelToken(),
      );
}

/// 详情：只读数据用 FutureProvider 就够了，按 id 区分
final articleDetailProvider = FutureProvider.autoDispose.family<Article, String>(
  (ref, id) => ref.watch(articleRepositoryProvider).fetchDetail(id, cancelToken: ref.cancelToken()),
);
