import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:xjj_app_base/app/routes.dart';
import 'package:xjj_app_base/shared/ui/ui.dart';

/// 路由没匹配上（链接失效、路径写错、参数非法）时显示的页面。
class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('页面不存在')),
      body: XEmptyView(
        icon: Icons.link_off,
        message: '页面不存在或已失效',
        actionText: '返回首页',
        onAction: () => context.go(Routes.home),
      ),
    );
  }
}
