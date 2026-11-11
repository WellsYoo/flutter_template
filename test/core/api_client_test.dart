import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xjj_app_base/core/network/api_client.dart';
import 'package:xjj_app_base/core/network/api_exception.dart';
import 'package:xjj_app_base/core/session/session.dart';
import 'package:xjj_app_base/core/storage/local_storage.dart';

/// 返回固定响应的 Dio 适配器
class _StubAdapter implements HttpClientAdapter {
  _StubAdapter(this.status, this.body, {this.gate});
  final int status;
  final Object body;

  /// 设置后，请求会等它 complete 或被取消才返回（模拟慢请求）
  final Completer<void>? gate;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? _,
    Future<void>? cancelFuture,
  ) async {
    if (gate != null) await Future.any([gate!.future, ?cancelFuture]);
    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late int unauthorizedCalls;

  ApiClient client(int status, Object body) {
    final dio = Dio()..httpClientAdapter = _StubAdapter(status, body);
    return ApiClient(dio, onUnauthorized: (_) => unauthorizedCalls++);
  }

  setUp(() => unauthorizedCalls = 0);

  test('成功时拆包并 decode data', () async {
    final api = client(200, {
      'code': 0,
      'msg': 'ok',
      'data': {'name': 'wells'},
    });
    final name = await api.get(
      '/me',
      decode: (d) => (d! as Map<String, dynamic>)['name'] as String,
    );
    expect(name, 'wells');
  });

  test('业务 code 非 0 抛出 business 异常，带后端文案', () async {
    final api = client(200, {'code': 1001, 'msg': '库存不足'});
    await expectLater(
      api.get<void>('/x'),
      throwsA(
        isA<ApiException>()
            .having((e) => e.type, 'type', ApiErrorType.business)
            .having((e) => e.message, 'message', '库存不足')
            .having((e) => e.code, 'code', 1001),
      ),
    );
    expect(unauthorizedCalls, 0);
  });

  test('HTTP 401 触发 onUnauthorized', () async {
    final api = client(401, {'msg': 'unauthorized'});
    await expectLater(
      api.get<void>('/x'),
      throwsA(isA<ApiException>().having((e) => e.type, 'type', ApiErrorType.unauthorized)),
    );
    expect(unauthorizedCalls, 1);
  });

  test('HTTP 500 抛出 server 异常，优先用响应体里的文案', () async {
    await expectLater(
      client(500, {'msg': 'oops'}).get<void>('/x'),
      throwsA(
        isA<ApiException>()
            .having((e) => e.type, 'type', ApiErrorType.server)
            .having((e) => e.code, 'code', 500)
            .having((e) => e.message, 'message', 'oops'),
      ),
    );
    await expectLater(
      client(500, {'detail': 'x'}).get<void>('/x'),
      throwsA(isA<ApiException>().having((e) => e.message, 'message', '服务异常（500）')),
    );
  });

  test('cancelToken 取消后抛出 cancel 异常', () async {
    final dio = Dio()..httpClientAdapter = _StubAdapter(200, {'code': 0}, gate: Completer());
    final token = CancelToken();
    final pending = ApiClient(dio).get<void>('/slow', cancelToken: token);
    token.cancel();
    await expectLater(
      pending,
      throwsA(isA<ApiException>().having((e) => e.type, 'type', ApiErrorType.cancel)),
    );
  });

  test('ref.cancelToken() 在 provider 释放时取消', () async {
    final container = ProviderContainer.test();
    late CancelToken token;
    final provider = Provider.autoDispose((ref) => token = ref.cancelToken());
    final sub = container.listen(provider, (_, _) {});
    expect(token.isCancelled, isFalse);
    sub.close();
    await container.pump();
    expect(token.isCancelled, isTrue);
  });

  group('登录失效', () {
    late ProviderContainer container;
    late Completer<void> gate;

    setUp(() {
      gate = Completer();
      container = ProviderContainer.test(
        overrides: [localStorageProvider.overrideWithValue(MemoryStorage())],
      );
      // 用真实的 dioProvider（带 token 拦截器），只把网络换成假的
      container.read(dioProvider).httpClientAdapter = _StubAdapter(401, {'msg': 'x'}, gate: gate);
    });

    test('当前账号的请求返回 401：登出', () async {
      await container.read(sessionProvider.notifier).signIn('token-a');
      final pending = container.read(apiClientProvider).get<void>('/x');
      gate.complete();
      await expectLater(pending, throwsA(isA<ApiException>()));
      await pumpEventQueue();
      expect(container.read(sessionProvider).token, isNull);
    });

    test('旧账号的慢请求在重新登录后才返回 401：不登出新账号', () async {
      await container.read(sessionProvider.notifier).signIn('token-a');
      final pending = container.read(apiClientProvider).get<void>('/x');
      await pumpEventQueue(); // 请求已带着 token-a 发出，卡在网络上
      await container.read(sessionProvider.notifier).signIn('token-b');
      gate.complete();
      await expectLater(pending, throwsA(isA<ApiException>()));
      await pumpEventQueue();
      expect(container.read(sessionProvider).token, 'token-b');
    });
  });
}
