import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xjj_app_base/core/network/api_client.dart';
import 'package:xjj_app_base/core/network/api_exception.dart';
import 'package:xjj_app_base/core/utils/extensions.dart';

abstract interface class AuthRepository {
  /// 登录成功返回 token
  Future<String> login({required String username, required String password});

  /// 发送短信验证码
  Future<void> sendCode(String phone);

  /// 验证码登录，成功返回 token
  Future<String> loginWithCode({required String phone, required String code});
}

/// 接入真实后端时把这里换成 [ApiAuthRepository]。
final authRepositoryProvider = Provider<AuthRepository>((ref) => FakeAuthRepository());

class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository(this._api);

  final ApiClient _api;

  @override
  Future<String> login({required String username, required String password}) {
    return _api.post(
      '/auth/login',
      data: {'username': username, 'password': password},
      decode: (data) => (data! as Map<String, dynamic>)['token'] as String,
    );
  }

  @override
  Future<void> sendCode(String phone) => _api.post('/auth/sms-code', data: {'phone': phone});

  @override
  Future<String> loginWithCode({required String phone, required String code}) {
    return _api.post(
      '/auth/login/sms',
      data: {'phone': phone, 'code': code},
      decode: (data) => (data! as Map<String, dynamic>)['token'] as String,
    );
  }
}

/// 演示用：任意账号 + 密码 123456，或任意手机号 + 验证码 123456 可登录
class FakeAuthRepository implements AuthRepository {
  @override
  Future<String> login({required String username, required String password}) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (password != '123456') {
      throw const ApiException(ApiErrorType.business, '账号或密码错误');
    }
    return 'fake-token-$username';
  }

  @override
  Future<void> sendCode(String phone) => Future<void>.delayed(const Duration(milliseconds: 600));

  @override
  Future<String> loginWithCode({required String phone, required String code}) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (code != '123456') {
      throw const ApiException(ApiErrorType.business, '验证码错误');
    }
    return 'fake-token-${phone.mask()}';
  }
}
