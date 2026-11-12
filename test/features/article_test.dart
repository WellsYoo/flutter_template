import 'package:flutter_test/flutter_test.dart';
import 'package:xjj_app_base/features/article/data/article.dart';

void main() {
  test('fromJson：字段类型不稳定或缺失时不抛异常', () {
    final article = Article.fromJson({'id': 12, 'title': '标题', 'createdAt': 1735689600});
    expect(article.id, '12');
    expect(article.title, '标题');
    expect(article.summary, '');
    expect(article.createdAt.year, 2025);

    final empty = Article.fromJson({});
    expect(empty.id, '');
    expect(empty.createdAt, DateTime(1970));
  });
}
