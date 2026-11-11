import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xjj_app_base/app/router.dart';
import 'package:xjj_app_base/core/theme/theme_mode.dart';
import 'package:xjj_app_base/core/theme/x_theme.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'App',
      debugShowCheckedModeBanner: false,
      routerConfig: ref.watch(routerProvider),
      theme: XTheme.light,
      darkTheme: XTheme.dark,
      themeMode: ref.watch(themeModeProvider),
      locale: const Locale('zh', 'CN'),
      supportedLocales: const [Locale('zh', 'CN'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      builder: (context, child) {
        // 限制系统字体缩放范围，防止极端设置把布局撑坏
        final mq = MediaQuery.of(context);
        return MediaQuery(
          data: mq.copyWith(textScaler: mq.textScaler.clamp(maxScaleFactor: 1.3)),
          // 点击空白处收起键盘（按钮、输入框等自身的点击不受影响）
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: child,
          ),
        );
      },
    );
  }
}
