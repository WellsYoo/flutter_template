/// 示例模型。手写 fromJson：字段少时比 json_serializable 更直观，也不需要 build_runner。
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
    id: json['id'].toString(),
    title: json['title'] as String? ?? '',
    summary: json['summary'] as String? ?? '',
    author: json['author'] as String? ?? '',
    createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime(1970),
  );
}
