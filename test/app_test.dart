import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xjj_app_base/app/app.dart';
import 'package:xjj_app_base/app/router.dart';
import 'package:xjj_app_base/core/storage/local_storage.dart';
import 'package:xjj_app_base/features/article/data/article_repository.dart';
import 'package:xjj_app_base/features/home/data/dashboard_repository.dart';

Widget _app(LocalStorage storage) => ProviderScope(
  overrides: [
    localStorageProvider.overrideWithValue(storage),
    articleRepositoryProvider.overrideWithValue(FakeArticleRepository(delay: Duration.zero)),
    dashboardRepositoryProvider.overrideWithValue(FakeDashboardRepository(delay: Duration.zero)),
  ],
  retry: (_, _) => null,
  child: const App(),
);

void main() {
  testWidgets('未登录进入登录页，登录后进入首页，退出后回到登录页', (tester) async {
    final storage = MemoryStorage();
    await tester.pumpWidget(_app(storage));
    await tester.pumpAndSettle();
    expect(find.text('欢迎登录'), findsOneWidget);

    // 密码错误
    await tester.enterText(find.byType(TextFormField).at(0), 'wells');
    await tester.enterText(find.byType(TextFormField).at(1), 'wrong');
    await tester.tap(find.widgetWithText(FilledButton, '登录'));
    await tester.pumpAndSettle();
    expect(find.text('账号或密码错误'), findsOneWidget);

    // 密码正确
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.tap(find.widgetWithText(FilledButton, '登录'));
    await tester.pumpAndSettle();
    expect(find.text('待我审批'), findsOneWidget);
    expect(storage.getString(StorageKeys.token), isNotNull);

    // 从工作台进文章列表，再进详情，然后逐级返回
    await tester.tap(find.text('文章'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('示例文章 #1'));
    await tester.pumpAndSettle();
    expect(find.text('详情'), findsOneWidget);
    await tester.tap(find.byType(BackButton).last);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(BackButton).last);
    await tester.pumpAndSettle();
    expect(find.text('待我审批'), findsOneWidget);

    // 退出登录
    await tester.tap(find.text('我的'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('退出登录'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('确定'));
    await tester.pumpAndSettle();
    expect(find.text('欢迎登录'), findsOneWidget);
    expect(storage.getString(StorageKeys.token), isNull);
  });

  testWidgets('已登录直接进入首页', (tester) async {
    await tester.pumpWidget(_app(MemoryStorage({StorageKeys.token: 't'})));
    await tester.pumpAndSettle();
    expect(find.text('待我审批'), findsOneWidget);
  });

  testWidgets('路径不存在或参数非法：显示 404，可以返回首页', (tester) async {
    await tester.pumpWidget(_app(MemoryStorage({StorageKeys.token: 't'})));
    await tester.pumpAndSettle();
    final router = ProviderScope.containerOf(tester.element(find.byType(App))).read(routerProvider);

    router.go('/no-such-page');
    await tester.pumpAndSettle();
    expect(find.text('页面不存在或已失效'), findsOneWidget);

    await tester.tap(find.text('返回首页'));
    await tester.pumpAndSettle();
    expect(find.text('待我审批'), findsOneWidget);

    router.go('/demo/list/not-a-scenario');
    await tester.pumpAndSettle();
    expect(find.text('页面不存在或已失效'), findsOneWidget);
  });
}
