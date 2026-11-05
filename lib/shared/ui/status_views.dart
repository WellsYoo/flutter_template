import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xjj_app_base/core/network/api_exception.dart';
import 'package:xjj_app_base/core/theme/app_theme.dart';
import 'package:xjj_app_base/core/utils/context_ext.dart';
import 'package:xjj_app_base/shared/ui/app_button.dart';
import 'package:xjj_app_base/shared/ui/app_refresh.dart';
import 'package:xjj_app_base/shared/ui/feedback.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) => const Center(child: CircularProgressIndicator());
}

class EmptyView extends StatelessWidget {
  const EmptyView({super.key, this.message = '暂无数据', this.icon = Icons.inbox_outlined});

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final hint = context.appColors.textHint;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: hint.withValues(alpha: 0.5)),
          const SizedBox(height: Insets.md),
          Text(
            message,
            style: TextStyle(fontSize: FontSizes.body, color: hint),
          ),
        ],
      ),
    );
  }
}

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.error, this.onRetry});

  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final offline = ApiException.from(error).type == ApiErrorType.network;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Insets.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              offline ? Icons.wifi_off_rounded : Icons.error_outline,
              size: 64,
              color: c.textHint.withValues(alpha: 0.5),
            ),
            const SizedBox(height: Insets.md),
            Text(
              errorMessageOf(error),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: FontSizes.body, color: c.textSecondary),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: Insets.lg),
              SizedBox(
                width: 120,
                child: AppButton.outline('重试', size: ButtonSize.medium, onPressed: onRetry),
              ),
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
/// AsyncValueView(
///   value: ref.watch(provider),
///   onRetry: () => ref.invalidate(provider),
///   onRefresh: () => ref.refresh(provider.future),
///   data: (user) => ListView(children: [...]),
/// )
/// ```
///
/// 传了 [onRefresh] 时：data 返回的滚动组件（ListView 等，不要设置 physics）会包上下拉刷新；
/// 刷新失败保留旧数据并 toast。
class AsyncValueView<T> extends StatelessWidget {
  const AsyncValueView({
    super.key,
    required this.value,
    required this.data,
    this.onRetry,
    this.onRefresh,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final VoidCallback? onRetry;
  final Future<Object?> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    final refresh = onRefresh;
    return value.when(
      // 已有数据时刷新失败，继续显示旧数据（错误已 toast）
      skipError: refresh != null && value.hasValue,
      data: (v) {
        final child = data(v);
        if (refresh == null) return child;
        return AppRefresh(
          onRefresh: () async {
            try {
              await refresh();
              return IndicatorResult.success;
            } catch (e) {
              Toast.error(e);
              return IndicatorResult.fail;
            }
          },
          child: child,
        );
      },
      loading: () => const LoadingView(),
      error: (e, _) => ErrorView(error: e, onRetry: onRetry),
    );
  }
}
