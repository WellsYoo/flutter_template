import 'package:xjj_app_base/core/utils/json.dart';

/// 示例模型。手写 fromJson：字段少时比 json_serializable 更直观，也不需要 build_runner。
/// 取值用 `JsonX`（core/utils/json.dart）：字段缺失、类型不对时给默认值，不会整页报错。
class Article {
  const Article({
    required this.id,
    required this.title,
    required this.summary,
    required this.author,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String summary;
  final String author;
  final DateTime createdAt;

  factory Article.fromJson(Map<String, dynamic> json) => Article(
    id: json.str('id'),
    title: json.str('title'),
    summary: json.str('summary'),
    author: json.str('author'),
    createdAt: json.date('createdAt') ?? DateTime(1970),
  );
}
