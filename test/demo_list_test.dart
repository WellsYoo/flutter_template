import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xjj_app_base/core/theme/app_theme.dart';
import 'package:xjj_app_base/features/demo/demo_list_page.dart';
import 'package:xjj_app_base/shared/ui/feedback.dart';

/// 用示例页验证 PagedListView 在各种状态下的表现
Future<void> _pump(WidgetTester tester, ListScenario scenario) async {
  await tester.pumpWidget(
    ProviderScope(
      retry: (_, _) => null,
      child: MaterialApp(
        navigatorKey: rootNavigatorKey,
        theme: AppTheme.light,
        home: DemoListPage(scenario: scenario),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Finder get _list => find.byType(Scrollable).first;

Future<void> _pullDown(WidgetTester tester) async {
  await tester.drag(_list, const Offset(0, 300));
  await tester.pumpAndSettle();
}

/// 上拉到底，触发加载更多
Future<void> _pullUp(WidgetTester tester) async {
  await tester.drag(_list, const Offset(0, -3000));
  await tester.pumpAndSettle();
}

/// toast、刷新头尾有定时器，测试结束前等它们走完
Future<void> _flushTimers(WidgetTester tester) => tester.pump(const Duration(seconds: 3));

void main() {
  testWidgets('正常分页：上拉加载，到底显示没有更多', (tester) async {
    await _pump(tester, ListScenario.normal);
    expect(find.textContaining('第 1 条'), findsOneWidget);

    for (var i = 0; i < 4; i++) {
      await _pullUp(tester);
    }
    expect(find.textContaining('第 35 条'), findsOneWidget);
    expect(find.text('没有更多了'), findsWidgets);
    await _flushTimers(tester);
  });

  testWidgets('空数据：显示空状态，下拉刷新后出现数据', (tester) async {
    await _pump(tester, ListScenario.empty);
    expect(find.text('暂无数据'), findsOneWidget);

    await _pullDown(tester);
    expect(find.textContaining('第 1 条'), findsOneWidget);
    await _flushTimers(tester);
  });

  testWidgets('首屏失败：显示错误，重试后成功', (tester) async {
    await _pump(tester, ListScenario.firstPageError);
    expect(find.text('网络连接失败，请检查网络'), findsOneWidget);

    await tester.tap(find.text('重试'));
    await tester.pumpAndSettle();
    expect(find.textContaining('第 1 条'), findsOneWidget);
  });

  testWidgets('加载更多失败：提示错误，再次上拉成功', (tester) async {
    await _pump(tester, ListScenario.loadMoreError);
    await _pullUp(tester);
    expect(find.text('网络超时'), findsOneWidget); // toast
    expect(find.text('加载失败，上拉重试'), findsOneWidget); // footer
    expect(find.textContaining('第 16 条'), findsNothing);

    // 失败后第一次上拉会把 footer 复位，再上拉触发重试
    await _pullUp(tester);
    await _pullUp(tester);
    final container = ProviderScope.containerOf(tester.element(find.byType(DemoListPage)));
    final state = container.read(demoListProvider(ListScenario.loadMoreError)).requireValue;
    expect(state.items.length, greaterThan(15));
    expect(state.loadMoreError, isNull);
    await _flushTimers(tester);
  });

  testWidgets('刷新失败：保留旧数据并提示', (tester) async {
    await _pump(tester, ListScenario.refreshError);
    await _pullDown(tester);
    expect(find.textContaining('第 1 条'), findsOneWidget);
    expect(find.text('网络连接失败，请检查网络'), findsOneWidget); // toast
    await _flushTimers(tester);
  });
}
