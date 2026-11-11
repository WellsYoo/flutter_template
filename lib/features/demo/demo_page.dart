import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:xjj_app_base/app/routes.dart';
import 'package:xjj_app_base/features/demo/demo_list_page.dart';
import 'package:xjj_app_base/shared/ui/ui.dart';

/// 示例入口。新项目里可以整个 features/demo 目录删掉。
class DemoPage extends StatelessWidget {
  const DemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('示例')),
      body: ListView(
        children: [
          XFormSection(
            title: '组件',
            children: [
              XFormItem(
                label: 'UI 组件一览',
                arrow: true,
                onTap: () => context.push(Routes.demoUiKit),
                child: const XText.caption('文本 / 按钮 / 标签 / 弹层…', align: TextAlign.end),
              ),
              XFormItem(
                label: '表单',
                arrow: true,
                onTap: () => context.push(Routes.demoForm),
                child: const XText.caption('输入 / 选择 / 日期 / 提交', align: TextAlign.end),
              ),
              XFormItem(
                label: '详情页',
                arrow: true,
                onTap: () => context.push(Routes.articleDetail('0')),
                child: const XText.caption('下拉刷新 + 底部操作栏', align: TextAlign.end),
              ),
            ],
          ),
          XFormSection(
            title: '列表状态',
            children: [
              for (final s in ListScenario.values)
                XFormItem(
                  label: s.title,
                  arrow: true,
                  onTap: () => context.push(Routes.demoList(s)),
                  child: XText.caption(s.description, align: TextAlign.end, maxLines: 2),
                ),
            ],
          ),
          const SizedBox(height: Insets.xl),
        ],
      ),
    );
  }
}
