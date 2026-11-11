import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xjj_app_base/core/network/api_exception.dart';
import 'package:xjj_app_base/shared/ui/ui.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(
      navigatorKey: rootNavigatorKey,
      theme: XTheme.light,
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  group('XButton', () {
    testWidgets('返回 Future 时显示 loading，期间重复点击无效', (tester) async {
      final done = Completer<void>();
      var calls = 0;
      await _pump(
        tester,
        XButton.primary(
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
        XButton.primary(
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
      await _pump(tester, const XButton.primary('提交', onPressed: null));
      expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed, isNull);
    });

    testWidgets('confirm：确认后才执行，取消不执行', (tester) async {
      var calls = 0;
      await _pump(tester, XButton.danger('删除', confirm: '确定删除吗？', onPressed: () => calls++));

      await tester.tap(find.text('删除'));
      await tester.pumpAndSettle();
      expect(find.text('确定删除吗？'), findsOneWidget);
      await tester.tap(find.text('取消'));
      await tester.pumpAndSettle();
      expect(calls, 0);

      await tester.tap(find.text('删除'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('确定'));
      await tester.pumpAndSettle();
      expect(calls, 1);
    });

    testWidgets('loading 由外部控制时显示转圈且不可点击', (tester) async {
      var calls = 0;
      await _pump(tester, XButton.primary('提交', loading: true, onPressed: () => calls++));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(find.byType(FilledButton));
      expect(calls, 0);
    });

    testWidgets('color / round / width 生效', (tester) async {
      await _pump(
        tester,
        Center(
          child: XButton.primary(
            '领取',
            color: Colors.orange,
            round: true,
            width: 200,
            onPressed: () {},
          ),
        ),
      );
      final material = tester.widget<Material>(
        find.descendant(of: find.byType(FilledButton), matching: find.byType(Material)),
      );
      expect(material.color, Colors.orange);
      expect(material.shape, isA<StadiumBorder>());
      expect(tester.getSize(find.byType(FilledButton)).width, 200);
    });
  });

  testWidgets('XText：size / bold / lineThrough 覆盖默认样式', (tester) async {
    await _pump(tester, const XText.caption('原价', size: 20, bold: true, lineThrough: true));
    final style = tester.widget<Text>(find.text('原价')).style!;
    expect(style.fontSize, 20);
    expect(style.fontWeight, FontWeight.w600);
    expect(style.decoration, TextDecoration.lineThrough);
  });

  group('XContainer', () {
    BoxDecoration decoration(WidgetTester tester) =>
        tester.widget<Container>(find.byType(Container)).decoration! as BoxDecoration;

    testWidgets('圆角 / 渐变 / 边框 / 阴影', (tester) async {
      await _pump(
        tester,
        const Center(
          child: XContainer(
            size: 80,
            radius: 12,
            colors: [Colors.red, Colors.blue],
            borderColor: Colors.green,
            borderWidth: 2,
            shadow: true,
          ),
        ),
      );
      final d = decoration(tester);
      expect(d.borderRadius, BorderRadius.circular(12));
      expect((d.gradient! as LinearGradient).colors, [Colors.red, Colors.blue]);
      expect(d.border, Border.all(color: Colors.green, width: 2));
      expect(d.boxShadow, isNotEmpty);
      expect(tester.getSize(find.byType(XContainer)), const Size(80, 80));
    });

    testWidgets('border: true 用主题边框色；circle 为圆形；borderRadius 优先于 radius', (tester) async {
      await _pump(tester, const Center(child: XContainer(size: 40, circle: true, border: true)));
      var d = decoration(tester);
      expect(d.shape, BoxShape.circle);
      expect(d.border!.top.color, XColors.light.border);

      const top = BorderRadius.vertical(top: Radius.circular(16));
      await _pump(tester, const Center(child: XContainer(size: 40, radius: 4, borderRadius: top)));
      d = decoration(tester);
      expect(d.borderRadius, top);
    });

    testWidgets('onTap：内边距区域也能点击', (tester) async {
      var taps = 0;
      await _pump(
        tester,
        Center(
          child: XContainer(
            padding: const EdgeInsets.all(40),
            color: Colors.white,
            onTap: () => taps++,
            child: const Text('点我'),
          ),
        ),
      );
      final box = tester.getRect(find.byType(XContainer));
      await tester.tapAt(box.topLeft + const Offset(5, 5));
      expect(taps, 1);
    });
  });

  testWidgets('XBadge：0 不显示，超过上限显示 99+', (tester) async {
    await _pump(tester, const Center(child: XBadge(child: Text('消息'))));
    expect(find.descendant(of: find.byType(XBadge), matching: find.byType(Stack)), findsNothing);
    await _pump(tester, const Center(child: XBadge(count: 5, child: Text('消息'))));
    expect(find.text('5'), findsOneWidget);
    await _pump(tester, const Center(child: XBadge(count: 120, child: Text('消息'))));
    expect(find.text('99+'), findsOneWidget);
  });

  testWidgets('XStepper：到上下限后不再变化', (tester) async {
    var value = 1;
    await _pump(
      tester,
      StatefulBuilder(
        builder: (context, setState) =>
            XStepper(value: value, max: 2, onChanged: (v) => setState(() => value = v)),
      ),
    );
    await tester.tap(find.byIcon(Icons.remove));
    expect(value, 1);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(value, 2);
  });

  group('XCountdownButton', () {
    testWidgets('发送成功后倒计时，结束后可重新获取', (tester) async {
      var sends = 0;
      await _pump(tester, XCountdownButton(seconds: 3, onSend: () async => sends++));
      await tester.tap(find.text('获取验证码'));
      await tester.pump();
      await tester.pump();
      expect(sends, 1);
      expect(find.text('3s'), findsOneWidget);

      await tester.tap(find.text('3s'), warnIfMissed: false);
      expect(sends, 1, reason: '倒计时中不能点击');

      await tester.pump(const Duration(seconds: 4));
      expect(find.text('重新获取'), findsOneWidget);
    });

    testWidgets('发送失败：toast 提示，不倒计时', (tester) async {
      await _pump(
        tester,
        XCountdownButton(
          onSend: () async => throw const ApiException(ApiErrorType.business, '发送太频繁'),
        ),
      );
      await tester.tap(find.text('获取验证码'));
      await tester.pump();
      await tester.pump();
      expect(find.text('发送太频繁'), findsOneWidget);
      expect(find.text('获取验证码'), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
    });
  });

  testWidgets('XExpandableText：长文本折叠，点击展开 / 收起；短文本不显示按钮', (tester) async {
    final long = '很长的文字' * 60;
    await _pump(tester, XExpandableText(long, maxLines: 2));
    final collapsed = tester.getSize(find.byType(XExpandableText)).height;
    expect(find.textContaining('展开', findRichText: true), findsOneWidget);

    // “展开”是文字里的一段，直接触发它的点击回调
    final rich = tester.widget<RichText>(
      find.descendant(of: find.byType(XExpandableText), matching: find.byType(RichText)),
    );
    TapGestureRecognizer? link;
    rich.text.visitChildren((span) {
      if (span is TextSpan && span.recognizer != null) {
        link = span.recognizer! as TapGestureRecognizer;
      }
      return true;
    });
    link!.onTap!();
    await tester.pump();
    expect(find.textContaining('收起', findRichText: true), findsOneWidget);
    expect(tester.getSize(find.byType(XExpandableText)).height, greaterThan(collapsed));

    await _pump(tester, const XExpandableText('短文本', maxLines: 2));
    expect(find.textContaining('展开', findRichText: true), findsNothing);
  });

  testWidgets('XCell：显示值，可点击时带箭头', (tester) async {
    var tapped = false;
    await _pump(
      tester,
      Column(
        children: [
          XCell('缓存', value: '12 MB', onTap: () => tapped = true),
          const XCell('版本', value: '1.0.0'),
        ],
      ),
    );
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    await tester.tap(find.text('缓存'));
    expect(tapped, isTrue);
  });

  testWidgets('XTheme.create：品牌色和圆角可配置', (tester) async {
    final theme = XTheme.create(primary: Colors.green, radius: 2);
    expect(theme.colorScheme.primary, Colors.green);
    expect(
      (theme.cardTheme.shape! as RoundedRectangleBorder).borderRadius,
      BorderRadius.circular(2),
    );
    expect(XTheme.create(brightness: Brightness.dark).extension<XColors>(), XColors.dark);
  });

  testWidgets('XDialog.input：校验不通过不关闭，通过后返回输入内容', (tester) async {
    await _pump(tester, const SizedBox());
    final result = XDialog.input(title: '昵称', validator: (v) => v.isEmpty ? '不能为空' : null);
    await tester.pumpAndSettle();

    await tester.tap(find.text('确定'));
    await tester.pumpAndSettle();
    expect(find.text('不能为空'), findsOneWidget);

    await tester.enterText(find.byType(TextField), ' 张三 ');
    await tester.tap(find.text('确定'));
    await tester.pumpAndSettle();
    expect(await result, '张三');
    await tester.pump(const Duration(seconds: 1)); // 等延迟释放
  });

  testWidgets('XLoading：run 结束后自动关闭', (tester) async {
    await _pump(tester, const SizedBox());
    final done = Completer<void>();
    final task = XLoading.run(() => done.future, message: '提交中');
    await tester.pump();
    expect(find.text('提交中'), findsOneWidget);
    expect(XLoading.isShowing, isTrue);

    done.complete();
    await task;
    await tester.pump();
    expect(find.text('提交中'), findsNothing);
    expect(XLoading.isShowing, isFalse);
  });

  group('XFormItem', () {
    testWidgets('picker：点击弹出选项，选完回调', (tester) async {
      String? value;
      await _pump(
        tester,
        XFormItem.picker(
          label: '城市',
          options: const ['北京', '上海'],
          value: value,
          onChanged: (v) => value = v,
        ),
      );
      await tester.tap(find.text('请选择'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('上海'));
      await tester.pumpAndSettle();
      expect(value, '上海');
    });

    testWidgets('help 显示说明文字，XFormSection.labelWidth 统一标签宽度', (tester) async {
      await _pump(
        tester,
        XFormSection(
          labelWidth: 100,
          children: [XFormItem.input(label: '金额', help: '最多两位小数')],
        ),
      );
      expect(find.text('最多两位小数'), findsOneWidget);
      expect(tester.getSize(find.text('金额', findRichText: true)).width, 100);
    });

    testWidgets('select：空值显示 hint，必填显示星号，点击回调', (tester) async {
      var tapped = false;
      await _pump(
        tester,
        XFormSection(
          children: [
            XFormItem.select(label: '类型', value: null, required: true, onTap: () => tapped = true),
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
      await _pump(tester, XFormItem.input(label: '姓名', onChanged: (v) => value = v));
      await tester.enterText(find.byType(TextField), '张三');
      expect(value, '张三');
    });

    testWidgets('radio：点击切换', (tester) async {
      String? value = 'A';
      await _pump(
        tester,
        StatefulBuilder(
          builder: (context, setState) => XFormItem.radio(
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

  testWidgets('XSheet.select 返回所选项，取消返回 null', (tester) async {
    await _pump(tester, const SizedBox());

    final first = XSheet.select(options: ['北京', '上海'], title: '城市');
    await tester.pumpAndSettle();
    await tester.tap(find.text('上海'));
    await tester.pumpAndSettle();
    expect(await first, '上海');

    final second = XSheet.select(options: ['北京', '上海'], title: '城市');
    await tester.pumpAndSettle();
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();
    expect(await second, isNull);
  });
}
