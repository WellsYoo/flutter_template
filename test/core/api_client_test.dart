import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xjj_app_base/core/network/api_client.dart';
import 'package:xjj_app_base/core/network/api_exception.dart';

/// 返回固定响应的 Dio 适配器
class _StubAdapter implements HttpClientAdapter {
  _StubAdapter(this.status, this.body);
  final int status;
  final Object body;

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? _, Future<void>? _) async {
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
    return ApiClient(dio, onUnauthorized: () => unauthorizedCalls++);
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

  test('HTTP 500 抛出 server 异常', () async {
    final api = client(500, {'msg': 'oops'});
    await expectLater(
      api.get<void>('/x'),
      throwsA(isA<ApiException>().having((e) => e.code, 'code', 500)),
    );
  });
}
