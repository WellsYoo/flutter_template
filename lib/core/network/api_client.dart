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
        options.extra[_tokenKey] = token; // 记下这次请求用的登录身份，见 onUnauthorized
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
    // 只有“当前登录身份”的请求返回登录失效才登出：
    // 旧账号或登录前发出的慢请求，在重新登录后才返回 401，不能把新账号踢掉。
    onUnauthorized: (token) {
      if (token == ref.read(sessionProvider).token) ref.read(sessionProvider.notifier).signOut();
    },
  ),
);

const _tokenKey = 'authToken';

extension RefCancelToken on Ref {
  /// 创建随 provider 释放（离开页面、invalidate、参数变化）自动取消的 [CancelToken]：
  ///
  /// ```dart
  /// final detailProvider = FutureProvider.autoDispose.family<Article, String>(
  ///   (ref, id) => ref.watch(repoProvider).fetchDetail(id, cancelToken: ref.cancelToken()),
  /// );
  /// ```
  CancelToken cancelToken() {
    final token = CancelToken();
    onDispose(token.cancel);
    return token;
  }
}

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

/// 业务代码调用接口的唯一入口：负责拆包、统一异常、登录失效自动登出。
///
/// ```dart
/// final user = await api.get('/user/me', decode: (d) => User.fromJson(d! as Map<String, dynamic>));
/// ```
///
/// 失败一律抛 [ApiException]。传 [CancelToken]（一般用 `ref.cancelToken()`）可以中途取消，
/// 取消时抛出 type 为 [ApiErrorType.cancel] 的异常，`XToast.error` 不会提示它。
class ApiClient {
  ApiClient(this._dio, {this.onUnauthorized});

  final Dio _dio;

  /// 登录失效时回调，参数是这次请求发出时带的 token（未登录时为 null）。
  final void Function(String? requestToken)? onUnauthorized;

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? query,
    CancelToken? cancelToken,
    Decoder<T>? decode,
  }) => _request(path, method: 'GET', query: query, cancelToken: cancelToken, decode: decode);

  Future<T> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    CancelToken? cancelToken,
    Decoder<T>? decode,
  }) => _request(
    path,
    method: 'POST',
    data: data,
    query: query,
    cancelToken: cancelToken,
    decode: decode,
  );

  Future<T> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    CancelToken? cancelToken,
    Decoder<T>? decode,
  }) => _request(
    path,
    method: 'PUT',
    data: data,
    query: query,
    cancelToken: cancelToken,
    decode: decode,
  );

  Future<T> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    CancelToken? cancelToken,
    Decoder<T>? decode,
  }) => _request(
    path,
    method: 'DELETE',
    data: data,
    query: query,
    cancelToken: cancelToken,
    decode: decode,
  );

  Future<T> _request<T>(
    String path, {
    required String method,
    Object? data,
    Map<String, dynamic>? query,
    CancelToken? cancelToken,
    Decoder<T>? decode,
  }) async {
    RequestOptions? request;
    try {
      final res = await _dio.request<Object?>(
        path,
        data: data,
        queryParameters: query,
        cancelToken: cancelToken,
        options: Options(method: method),
      );
      request = res.requestOptions;
      final body = _unwrap(res.data);
      return decode != null ? decode(body) : body as T;
    } catch (e, st) {
      var error = ApiException.from(e);
      if (e is DioException) {
        request = e.requestOptions;
        // HTTP 非 2xx 时，后端在响应体里给了文案就用后端的
        final message = _messageOf(e.response?.data);
        if (error.type == ApiErrorType.server && message != null) {
          error = ApiException(error.type, message, code: error.code);
        }
      }
      if (error.type == ApiErrorType.unauthorized) {
        onUnauthorized?.call(request?.extra[_tokenKey] as String?);
      }
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

    final message = _messageOf(body) ?? '请求失败';
    final intCode = code is int ? code : int.tryParse('$code');
    final type = ApiEnvelope.unauthorizedCodes.contains(intCode)
        ? ApiErrorType.unauthorized
        : ApiErrorType.business;
    throw ApiException(type, message, code: intCode);
  }

  String? _messageOf(Object? body) {
    if (body is! Map) return null;
    final message = body[ApiEnvelope.messageKey]?.toString().trim();
    return message == null || message.isEmpty ? null : message;
  }
}
