import 'package:xjj_app_base/features/demo/demo_list_page.dart';

/// 所有路由路径集中定义，页面跳转只用这里的常量 / 方法，不手写字符串。
///
/// ```dart
/// context.push(Routes.articleDetail(id));
/// context.go(Routes.home);
/// ```
abstract final class Routes {
  static const login = '/login';
  static const home = '/home';
  static const profile = '/profile';

  /// tab 内的二级页面写成子路由：保留底部导航
  static const demo = '/demo';
  static String demoList(ListScenario s) => '/demo/list/${s.name}';
  static const demoUiKit = '/demo/ui';
  static const demoForm = '/demo/form';

  static const articleDetailPattern = '/articles/:id';
  static String articleDetail(String id) => '/articles/$id';
}
