import 'package:flutter/material.dart';
import 'package:xjj_app_base/shared/ui/ui.dart';

/// 组件示例的一块：标题 + 效果 + 一行用法代码。
class DemoBlock extends StatelessWidget {
  const DemoBlock({super.key, required this.title, required this.child, this.code});

  final String title;
  final Widget child;

  /// 最常用的写法，方便照抄
  final String? code;

  @override
  Widget build(BuildContext context) {
    final c = context.xColors;
    return XCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          XText.title(title, bold: true),
          XGap.v12,
          child,
          if (code != null) ...[
            XGap.v16,
            XContainer(
              padding: const XPad.hv(10, 8),
              radius: 8,
              color: c.fill,
              child: Text(
                code!,
                style: TextStyle(
                  fontSize: 11.5,
                  height: 1.5,
                  color: c.textSecondary,
                  fontFamily: 'monospace',
                  fontFamilyFallback: const ['Menlo', 'Roboto Mono', 'Courier'],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 一个分类 tab 的内容：若干 DemoBlock 竖排
class DemoTab extends StatelessWidget {
  const DemoTab({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => ListView.separated(
    padding: XPad.all16,
    itemCount: children.length,
    separatorBuilder: (_, _) => XGap.v12,
    itemBuilder: (_, index) => children[index],
  );
}

/// 触发弹层 / 提示的小按钮
class DemoChip extends StatelessWidget {
  const DemoChip(this.label, this.onTap, {super.key});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) =>
      XButton.outline(label, size: XButtonSize.small, onPressed: onTap);
}
