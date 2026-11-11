import 'dart:async';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:xjj_app_base/core/utils/context_ext.dart';

/// EasyRefresh 的统一样式封装。一般不直接用，列表用 XPagedListView，
/// 详情用 XAsyncView(onRefresh:)；特殊页面（如 CustomScrollView 首页）可直接用它。
///
/// [onRefresh] / [onLoad] 返回 [IndicatorResult] 控制头尾状态，抛异常视为失败。
/// [child] 必须是可滚动组件，且不要自己设置 physics（由 EasyRefresh 接管）。
class XRefresh extends StatelessWidget {
  const XRefresh({super.key, required this.child, this.onRefresh, this.onLoad, this.controller});

  final Widget child;
  final FutureOr<Object?> Function()? onRefresh;
  final FutureOr<Object?> Function()? onLoad;
  final EasyRefreshController? controller;

  @override
  Widget build(BuildContext context) {
    final c = context.xColors;
    final textStyle = TextStyle(fontSize: 13, color: c.textSecondary);
    final iconTheme = IconThemeData(color: c.textSecondary, size: 18);
    return EasyRefresh(
      controller: controller,
      onRefresh: onRefresh,
      onLoad: onLoad,
      header: ClassicHeader(
        dragText: '下拉刷新',
        armedText: '释放刷新',
        readyText: '刷新中...',
        processingText: '刷新中...',
        processedText: '刷新完成',
        failedText: '刷新失败',
        noMoreText: '没有更多了',
        showMessage: false,
        textStyle: textStyle,
        iconTheme: iconTheme,
      ),
      footer: ClassicFooter(
        dragText: '上拉加载',
        armedText: '释放加载',
        readyText: '加载中...',
        processingText: '加载中...',
        processedText: '加载完成',
        failedText: '加载失败，上拉重试',
        noMoreText: '没有更多了',
        showMessage: false,
        textStyle: textStyle,
        iconTheme: iconTheme,
      ),
      child: child,
    );
  }
}
