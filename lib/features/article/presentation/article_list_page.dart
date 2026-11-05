import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:xjj_app_base/app/routes.dart';
import 'package:xjj_app_base/features/article/article_providers.dart';
import 'package:xjj_app_base/features/article/data/article.dart';
import 'package:xjj_app_base/shared/ui/ui.dart';

/// 标准列表页：搜索 + 下拉刷新 + 上拉加载 + 空状态 + 错误重试。
class ArticleListPage extends StatefulWidget {
  const ArticleListPage({super.key});

  @override
  State<ArticleListPage> createState() => _ArticleListPageState();
}

class _ArticleListPageState extends State<ArticleListPage> {
  String _keyword = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('首页')),
      body: Column(
        children: [
          ColoredBox(
            color: context.appColors.card,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(Insets.lg, Insets.xs, Insets.lg, Insets.sm),
              child: SearchField(
                hintText: '搜索标题，试试输入 “1” 或 “xyz”',
                onChanged: (v) => setState(() => _keyword = v),
              ),
            ),
          ),
          Expanded(
            child: PagedListView(
              provider: articleListProvider(_keyword),
              empty: EmptyView(message: _keyword.isEmpty ? '暂无数据' : '没有找到“$_keyword”相关内容'),
              itemBuilder: (context, article, _) => ArticleTile(article),
            ),
          ),
        ],
      ),
    );
  }
}

class ArticleTile extends StatelessWidget {
  const ArticleTile(this.article, {super.key});

  final Article article;

  @override
  Widget build(BuildContext context) {
    final tag = switch (int.parse(article.id) % 3) {
      0 => const AppTag('已发布', type: TagType.success),
      1 => const AppTag('审核中', type: TagType.warning),
      _ => const AppTag('草稿', type: TagType.gray),
    };
    return AppCard(
      onTap: () => context.push(Routes.articleDetail(article.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: AppText.title(article.title, maxLines: 1)),
              const SizedBox(width: Insets.sm),
              tag,
            ],
          ),
          const SizedBox(height: Insets.xs),
          AppText.secondary(article.summary, maxLines: 2),
          const SizedBox(height: Insets.sm),
          AppText.caption('${article.author} · ${Fmt.dateTime(article.createdAt)}'),
        ],
      ),
    );
  }
}
