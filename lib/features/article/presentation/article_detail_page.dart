import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xjj_app_base/features/article/article_providers.dart';
import 'package:xjj_app_base/shared/ui/ui.dart';

/// 标准详情页：加载中 / 失败重试 / 下拉刷新 + 底部操作栏。
class ArticleDetailPage extends ConsumerWidget {
  const ArticleDetailPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = articleDetailProvider(id);
    final value = ref.watch(provider);

    return Scaffold(
      appBar: AppBar(title: const Text('详情')),
      body: XAsyncView(
        value: value,
        onRetry: () => ref.invalidate(provider),
        onRefresh: () => ref.refresh(provider.future),
        data: (article) => ListView(
          padding: XPad.all16,
          children: [
            XCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  XText.headline(article.title),
                  XGap.v12,
                  XInfoRow('作者', article.author),
                  XInfoRow('发布时间', Fmt.dateTime(article.createdAt)),
                  XInfoRow('编号', 'NO.${article.id.padLeft(6, '0')}'),
                ],
              ),
            ),
            XGap.v12,
            XCard(child: XText.body(article.summary)),
          ],
        ),
      ),
      // 数据加载成功后才显示底部按钮
      bottomNavigationBar: value.hasValue
          ? XBottomBar(
              children: [
                XButton.outline('分享', onPressed: () => XToast.show('已复制链接')),
                XButton.primary(
                  '收藏',
                  onPressed: () async {
                    await Future<void>.delayed(const Duration(milliseconds: 800));
                    XToast.success('收藏成功');
                  },
                ),
              ],
            )
          : null,
    );
  }
}
