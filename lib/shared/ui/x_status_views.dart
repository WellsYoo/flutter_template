import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xjj_app_base/core/network/api_exception.dart';
import 'package:xjj_app_base/core/theme/x_theme.dart';
import 'package:xjj_app_base/core/utils/context_ext.dart';
import 'package:xjj_app_base/shared/ui/x_button.dart';
import 'package:xjj_app_base/shared/ui/x_feedback.dart';
import 'package:xjj_app_base/shared/ui/x_refresh.dart';

class XLoadingView extends StatelessWidget {
  const XLoadingView({super.key});

  @override
  Widget build(BuildContext context) => const Center(child: CircularProgressIndicator());
}

/// 空状态。
///
/// ```dart
/// XEmptyView(message: '还没有订单', actionText: '去逛逛', onAction: _goShop)
/// XEmptyView(image: XImage('assets/images/empty.png', size: 120))
/// ```
class XEmptyView extends StatelessWidget {
  const XEmptyView({
    super.key,
    this.message = '暂无数据',
    this.icon = Icons.inbox_outlined,
    this.image,
    this.actionText,
    this.onAction,
  });

  final String message;
  final IconData icon;

  /// 自定义插图，传了就不显示 [icon]
  final Widget? image;

  /// 文案下方的按钮，和 [onAction] 一起传
  final String? actionText;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final hint = context.xColors.textHint;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          image ?? Icon(icon, size: 64, color: hint.withValues(alpha: 0.5)),
          XGap.v12,
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: FontSizes.body, color: hint),
          ),
          if (actionText != null && onAction != null) ...[
            XGap.v16,
            XButton.outline(actionText!, size: XButtonSize.medium, width: 120, onPressed: onAction),
          ],
        ],
      ),
    );
  }
}

class XErrorView extends StatelessWidget {
  const XErrorView({super.key, required this.error, this.onRetry});

  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final c = context.xColors;
    final offline = ApiException.from(error).type == ApiErrorType.network;
    return Center(
      child: Padding(
        padding: XPad.all24,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              offline ? Icons.wifi_off_rounded : Icons.error_outline,
              size: 64,
              color: c.textHint.withValues(alpha: 0.5),
            ),
            XGap.v12,
            Text(
              errorMessageOf(error),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: FontSizes.body, color: c.textSecondary),
            ),
            if (onRetry != null) ...[
              XGap.v16,
              XButton.outline('重试', size: XButtonSize.medium, width: 120, onPressed: onRetry),
            ],
          ],
        ),
      ),
    );
  }
}

/// AsyncValue 的标准渲染：加载中 / 失败可重试 / 有数据（可选下拉刷新）。
///
/// ```dart
/// final provider = userProvider(id);
/// XAsyncView(
///   value: ref.watch(provider),
///   onRetry: () => ref.invalidate(provider),
///   onRefresh: () => ref.refresh(provider.future),
///   data: (user) => ListView(children: [...]),
/// )
/// ```
///
/// 传了 [onRefresh] 时：data 返回的滚动组件（ListView 等，不要设置 physics）会包上下拉刷新；
/// 刷新失败保留旧数据并 toast。
///
/// 数据可能为空时传 [isEmpty]，为空显示 [empty]（默认 XEmptyView）：
///
/// ```dart
/// XAsyncView(value: ref.watch(ordersProvider), isEmpty: (list) => list.isEmpty, data: ...)
/// ```
class XAsyncView<T> extends StatelessWidget {
  const XAsyncView({
    super.key,
    required this.value,
    required this.data,
    this.onRetry,
    this.onRefresh,
    this.isEmpty,
    this.empty = const XEmptyView(),
    this.loading = const XLoadingView(),
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final VoidCallback? onRetry;
  final Future<Object?> Function()? onRefresh;

  /// 判断数据是否为空
  final bool Function(T data)? isEmpty;
  final Widget empty;
  final Widget loading;

  @override
  Widget build(BuildContext context) {
    final refresh = onRefresh;
    return value.when(
      // 已有数据时刷新失败，继续显示旧数据（错误已 toast）
      skipError: refresh != null && value.hasValue,
      data: (v) {
        final isEmpty = this.isEmpty?.call(v) ?? false;
        if (refresh == null) return isEmpty ? empty : data(v);
        // 空状态也要能下拉刷新
        final child = isEmpty
            ? CustomScrollView(slivers: [SliverFillRemaining(hasScrollBody: false, child: empty)])
            : data(v);
        return XRefresh(
          onRefresh: () async {
            try {
              await refresh();
              return IndicatorResult.success;
            } catch (e) {
              XToast.error(e);
              return IndicatorResult.fail;
            }
          },
          child: child,
        );
      },
      loading: () => loading,
      error: (e, _) => XErrorView(error: e, onRetry: onRetry),
    );
  }
}
