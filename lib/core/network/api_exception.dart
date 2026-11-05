import 'package:dio/dio.dart';

enum ApiErrorType {
  /// 无网络 / 连接失败
  network,

  /// 超时
  timeout,

  /// 401，登录失效
  unauthorized,

  /// HTTP 非 2xx
  server,

  /// HTTP 200，但业务 code 不是成功
  business,

  /// 主动取消
  cancel,

  /// 解析失败等其他错误
  unknown,
}

/// 统一的接口异常。UI 层只需要关心 [message]，需要分支处理时看 [type]/[code]。
class ApiException implements Exception {
  const ApiException(this.type, this.message, {this.code});

  final ApiErrorType type;
  final String message;

  /// HTTP 状态码或业务 code
  final int? code;

  factory ApiException.from(Object error) {
    if (error is ApiException) return error;
    if (error is DioException) return _fromDio(error);
    return const ApiException(ApiErrorType.unknown, '数据异常，请稍后重试');
  }

  static ApiException _fromDio(DioException e) {
    // 拦截器或解析阶段抛出的 ApiException 会被 dio 包一层
    if (e.error is ApiException) return e.error! as ApiException;

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const ApiException(ApiErrorType.timeout, '网络超时，请稍后重试');
      case DioExceptionType.connectionError:
        return const ApiException(ApiErrorType.network, '网络连接失败，请检查网络');
      case DioExceptionType.cancel:
        return const ApiException(ApiErrorType.cancel, '请求已取消');
      case DioExceptionType.badResponse:
        final status = e.response?.statusCode;
        if (status == 401) {
          return ApiException(ApiErrorType.unauthorized, '登录已失效，请重新登录', code: status);
        }
        return ApiException(ApiErrorType.server, '服务异常（$status）', code: status);
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return const ApiException(ApiErrorType.unknown, '网络异常，请稍后重试');
    }
  }

  @override
  String toString() => 'ApiException($type, $code, $message)';
}

/// 把任意异常转成可展示的文案，UI 层统一用这个。
String errorMessageOf(Object error) => ApiException.from(error).message;
