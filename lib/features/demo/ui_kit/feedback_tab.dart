import 'package:flutter/material.dart';
import 'package:xjj_app_base/core/network/api_exception.dart';
import 'package:xjj_app_base/features/demo/ui_kit/demo_block.dart';
import 'package:xjj_app_base/shared/ui/ui.dart';

/// 反馈：轻提示、全屏 loading、弹窗、底部弹层。都不需要传 context。
class FeedbackTab extends StatelessWidget {
  const FeedbackTab({super.key});

  @override
  Widget build(BuildContext context) {
    return DemoTab(
      children: [
        DemoBlock(
          title: 'XToast 轻提示',
          code: "XToast.show('已复制')\nXToast.success('保存成功')\nXToast.error(e) // 直接传异常",
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              DemoChip('普通', () => XToast.show('这是一条提示')),
              DemoChip('成功', () => XToast.success('保存成功')),
              DemoChip('警告', () => XToast.warning('请先选择合同')),
              DemoChip(
                '失败',
                () => XToast.error(const ApiException(ApiErrorType.network, '网络连接失败')),
              ),
              DemoChip('底部', () => XToast.show('显示在底部', position: XToastPosition.bottom)),
            ],
          ),
        ),
        DemoBlock(
          title: 'XLoading 全屏加载',
          code: "await XLoading.run(() => repo.save(), message: '提交中')",
          child: Wrap(
            spacing: 8,
            children: [
              DemoChip(
                '加载 1 秒',
                () => XLoading.run(() => Future<void>.delayed(const Duration(seconds: 1))),
              ),
              DemoChip(
                '带文字',
                () => XLoading.run(
                  () => Future<void>.delayed(const Duration(seconds: 1)),
                  message: '提交中',
                ),
              ),
            ],
          ),
        ),
        DemoBlock(
          title: 'XDialog 弹窗',
          code:
              "if (await XDialog.confirm(content: '确定删除？', danger: true)) { ... }\nfinal name = await XDialog.input(title: '修改昵称')",
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              DemoChip('确认框', () async {
                final ok = await XDialog.confirm(
                  title: '删除合同',
                  content: '删除后不可恢复，确定删除吗？',
                  confirmText: '删除',
                  danger: true,
                );
                if (ok) XToast.show('已删除');
              }),
              DemoChip('提示框', () => XDialog.alert(content: '您的账号将于 7 天后过期')),
              DemoChip('输入框', () async {
                final v = await XDialog.input(
                  title: '修改昵称',
                  maxLength: 12,
                  validator: (v) => v.isEmpty ? '昵称不能为空' : null,
                );
                if (v != null) XToast.show(v);
              }),
            ],
          ),
        ),
        DemoBlock(
          title: 'XSheet 底部弹层',
          code:
              "final i = await XSheet.actions(['拍照', '从相册选择'])\nfinal date = await XSheet.date(title: '开始日期')",
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              DemoChip('操作菜单', () async {
                final i = await XSheet.actions(['拍照', '从相册选择', '删除'], danger: 2);
                if (i != null) XToast.show('选择了第 ${i + 1} 项');
              }),
              DemoChip('单选', () async {
                final v = await XSheet.select(
                  title: '城市',
                  options: ['北京', '上海', '深圳'],
                  selected: '上海',
                );
                if (v != null) XToast.show(v);
              }),
              DemoChip('多选', () async {
                final v = await XSheet.multiSelect(
                  title: '标签',
                  options: ['加急', '大客户', '续签'],
                  selected: ['加急'],
                );
                if (v != null) XToast.show(v.isEmpty ? '未选择' : v.join('、'));
              }),
              DemoChip('日期', () async {
                final v = await XSheet.date(title: '选择日期');
                if (v != null) XToast.show(Fmt.date(v));
              }),
              DemoChip('日期时间', () async {
                final v = await XSheet.date(title: '预约时间', withTime: true);
                if (v != null) XToast.show(Fmt.dateTime(v));
              }),
            ],
          ),
        ),
      ],
    );
  }
}
