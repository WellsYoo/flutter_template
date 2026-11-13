// 临时文件：把页面渲染成图片用于人工检查视觉效果，检查完删除，不入库
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xjj_app_base/app/app.dart';
import 'package:xjj_app_base/app/router.dart';
import 'package:xjj_app_base/app/routes.dart';
import 'package:xjj_app_base/core/storage/local_storage.dart';
import 'package:xjj_app_base/features/shop/data/product.dart';
import 'package:xjj_app_base/features/shop/shop_providers.dart';

Future<void> _loadFonts() async {
  final sdk = Platform.environment['FLUTTER_ROOT'] ?? '.fvm/flutter_sdk';
  Future<ByteData> read(String path) async =>
      ByteData.view(Uint8List.fromList(await File(path).readAsBytes()).buffer);
  final icons = FontLoader('MaterialIcons')
    ..addFont(read('$sdk/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf'));
  await icons.load();
  for (final family in ['Roboto', '.SF UI Text', '.SF UI Display', 'monospace']) {
    final text = FontLoader(family)..addFont(read('/Library/Fonts/Arial Unicode.ttf'));
    await text.load();
  }
}

Future<void> _settle(WidgetTester tester, [int frames = 20]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  setUpAll(_loadFonts);

  Future<void> shot(
    WidgetTester tester,
    String name, {
    String? push,
    String? go,
    bool dark = false,
    bool loggedIn = true,
    double height = 844,
    Future<void> Function(WidgetTester tester, ProviderContainer c)? prepare,
  }) async {
    tester.view.devicePixelRatio = 2;
    tester.view.physicalSize = Size(390 * 2, height * 2);
    addTearDown(tester.view.reset);
    // TEXT_SCALE=1.3：按系统大字体渲染，检查布局有没有被撑坏
    final scale = double.tryParse(Platform.environment['TEXT_SCALE'] ?? '');
    if (scale != null) {
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    }
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localStorageProvider.overrideWithValue(
            MemoryStorage({
              if (loggedIn) StorageKeys.token: 'fake-token-wells',
              if (dark) StorageKeys.themeMode: 'dark',
            }),
          ),
        ],
        retry: (_, _) => null,
        child: const App(),
      ),
    );
    await _settle(tester);
    final container = ProviderScope.containerOf(tester.element(find.byType(App)));
    final router = container.read(routerProvider);
    if (go != null) router.go(go);
    if (push != null) unawaited(router.push(push));
    await _settle(tester);
    if (prepare != null) {
      await prepare(tester, container);
      await _settle(tester);
    }
    await expectLater(
      find.byType(App),
      matchesGoldenFile('${scale == null ? 'out' : 'out_scale'}/$name.png'),
    );
    // 等 toast 等定时器走完
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 5));
  }

  final only = Platform.environment['SHOT'];
  void t(String name, Future<void> Function(WidgetTester) body) {
    if (only != null && !name.contains(only)) return;
    testWidgets(name, body);
  }

  t('login', (t) => shot(t, 'login', loggedIn: false));
  t('home', (t) => shot(t, 'home', height: 1100));
  t('home_dark', (t) => shot(t, 'home_dark', dark: true, height: 1100));
  t('demo', (t) => shot(t, 'demo', go: Routes.demo, height: 1300));
  t('profile', (t) => shot(t, 'profile', go: Routes.profile));
  t('profile_dark', (t) => shot(t, 'profile_dark', go: Routes.profile, dark: true));
  t('contracts', (t) => shot(t, 'contracts', push: Routes.contracts));
  t(
    'contract_detail',
    (t) => shot(t, 'contract_detail', push: Routes.contractDetail('0'), height: 1100),
  );
  t('contract_new', (t) => shot(t, 'contract_new', push: Routes.contractNew, height: 1000));
  t('shop', (t) => shot(t, 'shop', push: Routes.shop));
  t('shop_dark', (t) => shot(t, 'shop_dark', push: Routes.shop, dark: true));
  t('product', (t) => shot(t, 'product', push: Routes.productDetail('2'), height: 1000));
  t(
    'cart',
    (t) => shot(
      t,
      'cart',
      push: Routes.cart,
      prepare: (tester, c) async {
        Product p(int kind, String name, double price) => Product(
          id: '$kind',
          name: name,
          subtitle: '',
          price: price,
          originalPrice: price,
          sales: 0,
          kind: kind,
        );
        c.read(cartProvider.notifier)
          ..add(p(0, '无线降噪耳机', 899), spec: '曜石黑', count: 2)
          ..add(p(2, '智能手表', 1299), spec: '云雾白');
      },
    ),
  );
  t('messages', (t) => shot(t, 'messages', push: Routes.messages));
  t('articles', (t) => shot(t, 'articles', push: Routes.articles));
  t('settings', (t) => shot(t, 'settings', push: Routes.settings));
  t('theme', (t) => shot(t, 'theme', push: Routes.theme, height: 1900));
  t('theme_dark', (t) => shot(t, 'theme_dark', push: Routes.theme, height: 1900, dark: true));
  t('kit_basic', (t) => shot(t, 'kit_basic', push: Routes.uiKit, height: 1900));
  for (final (i, name) in ['display', 'feedback', 'input'].indexed) {
    t(
      'kit_$name',
      (t) => shot(
        t,
        'kit_$name',
        push: Routes.uiKit,
        height: 1500,
        prepare: (tester, _) async {
          await tester.tap(find.byType(Tab).at(i + 1));
        },
      ),
    );
  }
}
