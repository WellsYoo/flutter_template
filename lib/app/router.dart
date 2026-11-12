import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:xjj_app_base/app/not_found_page.dart';
import 'package:xjj_app_base/app/routes.dart';
import 'package:xjj_app_base/core/session/session.dart';
import 'package:xjj_app_base/features/article/presentation/article_detail_page.dart';
import 'package:xjj_app_base/features/article/presentation/article_list_page.dart';
import 'package:xjj_app_base/features/auth/presentation/login_page.dart';
import 'package:xjj_app_base/features/demo/demo_list_page.dart';
import 'package:xjj_app_base/features/demo/demo_page.dart';
import 'package:xjj_app_base/features/demo/form_demo_page.dart';
import 'package:xjj_app_base/features/demo/ui_kit_page.dart';
import 'package:xjj_app_base/features/home/home_shell.dart';
import 'package:xjj_app_base/features/profile/profile_page.dart';
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
            routes: [GoRoute(path: Routes.home, builder: (_, _) => const ArticleListPage())],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.demo,
                builder: (_, _) => const DemoPage(),
                routes: [
                  GoRoute(
                    path: 'list/:scenario',
                    // 路径参数可能来自外部链接，非法值显示 404，不要抛异常
                    builder: (_, state) {
                      final scenario = ListScenario.values
                          .asNameMap()[state.pathParameters['scenario']];
                      return scenario == null
                          ? const NotFoundPage()
                          : DemoListPage(scenario: scenario);
                    },
                  ),
                  GoRoute(path: 'ui', builder: (_, _) => const UiKitPage()),
                  // 页面自带底部操作栏：挂到根 Navigator，盖住底部导航
                  GoRoute(
                    path: 'form',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (_, _) => const FormDemoPage(),
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

      // 全屏页面（盖住底部导航）放在 shell 外面
      GoRoute(
        path: Routes.articleDetailPattern,
        builder: (_, state) => ArticleDetailPage(id: state.pathParameters['id']!),
      ),
    ],
  );

  ref.onDispose(() {
    router.dispose();
    sessionChanged.dispose();
  });
  return router;
});
