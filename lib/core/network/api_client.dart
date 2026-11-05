import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xjj_app_base/app/app_config.dart';
import 'package:xjj_app_base/core/network/api_exception.dart';
import 'package:xjj_app_base/core/session/session.dart';
import 'package:xjj_app_base/core/utils/logger.dart';

/// 把 JSON 里的 data 字段转换成业务模型。
typedef Decoder<T> = T Function(Object? data);

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = ref.read(sessionProvider).token;
        if (token != null) options.headers['Authorization'] = 'Bearer $token';
        handler.next(options);
      },
    ),
  );

  if (kDebugMode) {
    dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true, logPrint: (o) => Log.d(o, tag: 'HTTP')),
    );
  }

  ref.onDispose(dio.close);
  return dio;
});

final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(
    ref.watch(dioProvider),
    onUnauthorized: () => ref.read(sessionProvider.notifier).signOut(),
  ),
);

/// 后端统一响应格式：`{"code": 0, "msg": "...", "data": ...}`。
/// 字段名或成功码不一样时，只改这里。
abstract final class ApiEnvelope {
  static const codeKey = 'code';
  static const messageKey = 'msg';
  static const dataKey = 'data';
  static const successCode = 0;

  /// 业务层面的“登录失效”码，没有可以留空
  static const unauthorizedCodes = <int>{401};
}

/// 业务代码调用接口的唯一入口：负责拆包、统一异常、401 自动登出。
///
/// ```dart
/// final user = await api.get('/user/me', decode: (d) => User.fromJson(d! as Map<String, dynamic>));
/// ```
class ApiClient {
  ApiClient(this._dio, {this.onUnauthorized});

  final Dio _dio;
  final void Function()? onUnauthorized;

  Future<T> get<T>(String path, {Map<String, dynamic>? query, Decoder<T>? decode}) =>
      _request(path, method: 'GET', query: query, decode: decode);

  Future<T> post<T>(String path, {Object? data, Map<String, dynamic>? query, Decoder<T>? decode}) =>
      _request(path, method: 'POST', data: data, query: query, decode: decode);

  Future<T> put<T>(String path, {Object? data, Decoder<T>? decode}) =>
      _request(path, method: 'PUT', data: data, decode: decode);

  Future<T> delete<T>(String path, {Object? data, Decoder<T>? decode}) =>
      _request(path, method: 'DELETE', data: data, decode: decode);

  Future<T> _request<T>(
    String path, {
    required String method,
    Object? data,
    Map<String, dynamic>? query,
    Decoder<T>? decode,
  }) async {
    try {
      final res = await _dio.request<Object?>(
        path,
        data: data,
        queryParameters: query,
        options: Options(method: method),
      );
      final body = _unwrap(res.data);
      return decode != null ? decode(body) : body as T;
    } catch (e, st) {
      final error = ApiException.from(e);
      if (error.type == ApiErrorType.unauthorized) onUnauthorized?.call();
      if (error.type == ApiErrorType.unknown) Log.e('请求失败 $path', error: e, stackTrace: st);
      throw error;
    }
  }

  Object? _unwrap(Object? body) {
    if (body is! Map<String, dynamic>) {
      throw const ApiException(ApiErrorType.unknown, '数据格式错误');
    }
    final code = body[ApiEnvelope.codeKey];
    if (code == ApiEnvelope.successCode) return body[ApiEnvelope.dataKey];

    final message = body[ApiEnvelope.messageKey]?.toString() ?? '请求失败';
    final intCode = code is int ? code : int.tryParse('$code');
    final type = ApiEnvelope.unauthorizedCodes.contains(intCode)
        ? ApiErrorType.unauthorized
        : ApiErrorType.business;
    throw ApiException(type, message, code: intCode);
  }
}
