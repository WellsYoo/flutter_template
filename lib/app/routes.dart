import 'package:xjj_app_base/features/demo/demo_list_page.dart';

/// 所有路由路径集中定义，页面跳转只用这里的常量 / 方法，不手写字符串。
///
/// ```dart
/// context.push(Routes.contractDetail(id));
/// context.go(Routes.home);
/// ```
abstract final class Routes {
  static const login = '/login';

  // 底部导航的三个 tab
  static const home = '/home';
  static const demo = '/demo';
  static const profile = '/profile';

  /// tab 内的二级页面写成子路由：保留底部导航
  static String demoList(ListScenario s) => '/demo/list/${s.name}';

  // 全屏页面（盖住底部导航）
  static const uiKit = '/ui-kit';
  static const theme = '/theme';
  static const settings = '/settings';
  static const messages = '/messages';

  static const articles = '/articles';
  static const articleDetailPattern = '/articles/:id';
  static String articleDetail(String id) => '/articles/$id';

  static const contracts = '/contracts';
  static const contractNew = '/contracts/new';
  static const contractDetailPattern = '/contracts/:id';
  static String contractDetail(String id) => '/contracts/$id';

  static const shop = '/shop';
  static const cart = '/shop/cart';
  static const productDetailPattern = '/shop/products/:id';
  static String productDetail(String id) => '/shop/products/$id';
}
