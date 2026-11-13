import 'package:flutter/material.dart';
import 'package:xjj_app_base/features/demo/ui_kit/basic_tab.dart';
import 'package:xjj_app_base/features/demo/ui_kit/display_tab.dart';
import 'package:xjj_app_base/features/demo/ui_kit/feedback_tab.dart';
import 'package:xjj_app_base/features/demo/ui_kit/input_tab.dart';

/// 组件一览：按用途分成四类，每个组件一块，附最常用的写法。
class UiKitPage extends StatelessWidget {
  const UiKitPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('组件'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '基础', height: 40),
              Tab(text: '展示', height: 40),
              Tab(text: '反馈', height: 40),
              Tab(text: '录入', height: 40),
            ],
          ),
        ),
        body: const TabBarView(children: [BasicTab(), DisplayTab(), FeedbackTab(), InputTab()]),
      ),
    );
  }
}
