import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:xjj_app_base/app/routes.dart';
import 'package:xjj_app_base/features/article/article_providers.dart';
import 'package:xjj_app_base/features/article/data/article.dart';
import 'package:xjj_app_base/shared/ui/ui.dart';

/// 文章列表：搜索 + 下拉刷新 + 上拉加载 + 空状态 + 错误重试。
/// 搜索词变化就是一个新的 provider，旧请求自动取消、结果自动丢弃。
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
      appBar: AppBar(title: const Text('文章')),
      body: Column(
        children: [
          ColoredBox(
            color: context.xColors.card,
            child: Padding(
              padding: const XPad.ltrb(16, 4, 16, 10),
              child: XSearchField(
                hintText: '搜索标题，试试输入 “1” 或 “xyz”',
                onChanged: (v) => setState(() => _keyword = v),
              ),
            ),
          ),
          Expanded(
            child: XPagedListView(
              provider: articleListProvider(_keyword),
              empty: XEmptyView(message: _keyword.isEmpty ? '暂无数据' : '没有找到“$_keyword”相关内容'),
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
      0 => const XTag('已发布', type: XTagType.success),
      1 => const XTag('审核中', type: XTagType.warning),
      _ => const XTag('草稿', type: XTagType.gray),
    };
    return XCard(
      onTap: () => context.push(Routes.articleDetail(article.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: XText.title(article.title, maxLines: 1)),
              XGap.h8,
              tag,
            ],
          ),
          XGap.v4,
          XText.secondary(article.summary, maxLines: 2),
          XGap.v8,
          XText.caption('${article.author} · ${Fmt.dateTime(article.createdAt)}'),
        ],
      ),
    );
  }
}
