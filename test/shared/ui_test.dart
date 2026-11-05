import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xjj_app_base/core/network/api_exception.dart';
import 'package:xjj_app_base/shared/ui/ui.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(
      navigatorKey: rootNavigatorKey,
      theme: AppTheme.light,
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  group('AppButton', () {
    testWidgets('返回 Future 时显示 loading，期间重复点击无效', (tester) async {
      final done = Completer<void>();
      var calls = 0;
      await _pump(
        tester,
        AppButton.primary(
          '提交',
          onPressed: () {
            calls++;
            return done.future;
          },
        ),
      );

      await tester.tap(find.text('提交'));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.tap(find.byType(FilledButton));
      expect(calls, 1);

      done.complete();
      await tester.pumpAndSettle();
      expect(find.text('提交'), findsOneWidget);
    });

    testWidgets('异常自动 toast，并恢复可点击', (tester) async {
      await _pump(
        tester,
        AppButton.primary(
          '提交',
          onPressed: () async => throw const ApiException(ApiErrorType.business, '余额不足'),
        ),
      );
      await tester.tap(find.text('提交'));
      await tester.pump();
      await tester.pump();
      expect(find.text('余额不足'), findsOneWidget);
      expect(find.text('提交'), findsOneWidget);
      await tester.pump(const Duration(seconds: 3)); // 等 toast 消失
    });

    testWidgets('onPressed 为 null 时禁用', (tester) async {
      await _pump(tester, const AppButton.primary('提交', onPressed: null));
      expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed, isNull);
    });
  });

  group('FormItem', () {
    testWidgets('select：空值显示 hint，必填显示星号，点击回调', (tester) async {
      var tapped = false;
      await _pump(
        tester,
        FormSection(
          children: [
            FormItem.select(label: '类型', value: null, required: true, onTap: () => tapped = true),
          ],
        ),
      );
      expect(find.text('请选择'), findsOneWidget);
      expect(find.textContaining('* 类型', findRichText: true), findsOneWidget);
      await tester.tap(find.text('请选择'));
      expect(tapped, isTrue);
    });

    testWidgets('input：输入回调 onChanged', (tester) async {
      String? value;
      await _pump(tester, FormItem.input(label: '姓名', onChanged: (v) => value = v));
      await tester.enterText(find.byType(TextField), '张三');
      expect(value, '张三');
    });

    testWidgets('radio：点击切换', (tester) async {
      String? value = 'A';
      await _pump(
        tester,
        StatefulBuilder(
          builder: (context, setState) => FormItem.radio(
            label: '选项',
            options: const ['A', 'B'],
            value: value,
            onChanged: (v) => setState(() => value = v),
          ),
        ),
      );
      await tester.tap(find.text('B'));
      expect(value, 'B');
    });
  });

  group('InputFormats', () {
    TextEditingValue apply(TextInputFormatter f, String old, String next) =>
        f.formatEditUpdate(TextEditingValue(text: old), TextEditingValue(text: next));

    test('decimal(2)：最多两位小数，不允许多个小数点', () {
      final f = InputFormats.decimal(2);
      expect(apply(f, '1', '1.').text, '1.');
      expect(apply(f, '1.2', '1.23').text, '1.23');
      expect(apply(f, '1.23', '1.234').text, '1.23');
      expect(apply(f, '1.2', '1.2.').text, '1.2');
      expect(apply(f, '', 'a').text, '');
    });

    test('Validators', () {
      expect(Validators.required(' ', '姓名'), '请填写姓名');
      expect(Validators.required('a', '姓名'), isNull);
      expect(Validators.phone('13800000000'), isNull);
      expect(Validators.phone('1380000'), isNotNull);
    });
  });

  testWidgets('AppSheet.select 返回所选项，取消返回 null', (tester) async {
    await _pump(tester, const SizedBox());

    final first = AppSheet.select(options: ['北京', '上海'], title: '城市');
    await tester.pumpAndSettle();
    await tester.tap(find.text('上海'));
    await tester.pumpAndSettle();
    expect(await first, '上海');

    final second = AppSheet.select(options: ['北京', '上海'], title: '城市');
    await tester.pumpAndSettle();
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();
    expect(await second, isNull);
  });
}
