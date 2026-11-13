import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:xjj_app_base/app/not_found_page.dart';
import 'package:xjj_app_base/app/routes.dart';
import 'package:xjj_app_base/core/session/session.dart';
import 'package:xjj_app_base/features/article/presentation/article_detail_page.dart';
import 'package:xjj_app_base/features/article/presentation/article_list_page.dart';
import 'package:xjj_app_base/features/auth/presentation/login_page.dart';
import 'package:xjj_app_base/features/contract/presentation/contract_detail_page.dart';
import 'package:xjj_app_base/features/contract/presentation/contract_form_page.dart';
import 'package:xjj_app_base/features/contract/presentation/contract_list_page.dart';
import 'package:xjj_app_base/features/demo/demo_list_page.dart';
import 'package:xjj_app_base/features/demo/demo_page.dart';
import 'package:xjj_app_base/features/demo/theme_page.dart';
import 'package:xjj_app_base/features/demo/ui_kit_page.dart';
import 'package:xjj_app_base/features/home/home_shell.dart';
import 'package:xjj_app_base/features/home/presentation/dashboard_page.dart';
import 'package:xjj_app_base/features/message/presentation/message_page.dart';
import 'package:xjj_app_base/features/profile/profile_page.dart';
import 'package:xjj_app_base/features/profile/settings_page.dart';
import 'package:xjj_app_base/features/shop/presentation/cart_page.dart';
import 'package:xjj_app_base/features/shop/presentation/product_detail_page.dart';
import 'package:xjj_app_base/features/shop/presentation/shop_page.dart';
import 'package:xjj_app_base/shared/ui/x_feedback.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // 会话变化时通知 GoRouter 重新执行 redirect（登录后进首页、退出/401 后回登录页）
  final sessionChanged = ValueNotifier(0);
  ref.listen(sessionProvider, (_, _) => sessionChanged.value++);

  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: Routes.home,
    debugLogDiagnostics: kDebugMode,
    refreshListenable: sessionChanged,
    // 没有匹配的路由（链接失效、路径写错）
    errorBuilder: (_, _) => const NotFoundPage(),
    redirect: (context, state) {
      final loggedIn = ref.read(sessionProvider).isLoggedIn;
      final atLogin = state.matchedLocation == Routes.login;

      if (!loggedIn && !atLogin) {
        // 记住原地址，登录后跳回去
        return Uri(path: Routes.login, queryParameters: {'from': state.uri.toString()}).toString();
      }
      if (loggedIn && atLogin) {
        return state.uri.queryParameters['from'] ?? Routes.home;
      }
      return null;
    },
    routes: [
      GoRoute(path: Routes.login, builder: (_, _) => const LoginPage()),

      // 带底部导航的页面
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => HomeShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: Routes.home, builder: (_, _) => const DashboardPage())],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.demo,
                builder: (_, _) => const DemoPage(),
                routes: [
                  // 路径参数可能来自外部链接，非法值显示 404，不要抛异常
                  GoRoute(
                    path: 'list/:scenario',
                    builder: (_, state) {
                      final scenario = ListScenario.values
                          .asNameMap()[state.pathParameters['scenario']];
                      return scenario == null
                          ? const NotFoundPage()
                          : DemoListPage(scenario: scenario);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: Routes.profile, builder: (_, _) => const ProfilePage())],
          ),
        ],
      ),

      // 全屏页面放在 shell 外面，会盖住底部导航
      GoRoute(path: Routes.uiKit, builder: (_, _) => const UiKitPage()),
      GoRoute(path: Routes.theme, builder: (_, _) => const ThemePage()),
      GoRoute(path: Routes.settings, builder: (_, _) => const SettingsPage()),
      GoRoute(path: Routes.messages, builder: (_, _) => const MessagePage()),

      GoRoute(path: Routes.articles, builder: (_, _) => const ArticleListPage()),
      GoRoute(
        path: Routes.articleDetailPattern,
        builder: (_, state) => ArticleDetailPage(id: state.pathParameters['id']!),
      ),

      GoRoute(path: Routes.contracts, builder: (_, _) => const ContractListPage()),
      // 静态路径要写在 :id 前面，否则 /contracts/new 会先匹配到详情
      GoRoute(path: Routes.contractNew, builder: (_, _) => const ContractFormPage()),
      GoRoute(
        path: Routes.contractDetailPattern,
        builder: (_, state) => ContractDetailPage(id: state.pathParameters['id']!),
      ),

      GoRoute(path: Routes.shop, builder: (_, _) => const ShopPage()),
      GoRoute(path: Routes.cart, builder: (_, _) => const CartPage()),
      GoRoute(
        path: Routes.productDetailPattern,
        builder: (_, state) => ProductDetailPage(id: state.pathParameters['id']!),
      ),
    ],
  );

  ref.onDispose(() {
    router.dispose();
    sessionChanged.dispose();
  });
  return router;
});
