import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xjj_app_base/core/storage/local_storage.dart';

/// 登录会话。需要缓存用户信息时在这里加字段。
class Session {
  const Session({this.token});

  final String? token;

  bool get isLoggedIn => token != null && token!.isNotEmpty;

  /// 演示用：假 token 里带着用户名。接真实后端后，把用户信息作为字段存进来。
  String get displayName => token?.replaceFirst('fake-token-', '') ?? '';
}

/// 全局会话状态。路由守卫、网络层 token 注入都依赖它。
final sessionProvider = NotifierProvider<SessionNotifier, Session>(SessionNotifier.new);

class SessionNotifier extends Notifier<Session> {
  LocalStorage get _storage => ref.read(localStorageProvider);

  @override
  Session build() => Session(token: _storage.getString(StorageKeys.token));

  Future<void> signIn(String token) async {
    await _storage.setString(StorageKeys.token, token);
    state = Session(token: token);
  }

  /// 主动退出，或 token 失效（401）时调用。
  Future<void> signOut() async {
    if (!state.isLoggedIn) return;
    // 先清状态（路由守卫立即跳登录页），再清存储：存储写失败也不该让用户停在已登录状态
    state = const Session();
    await _storage.remove(StorageKeys.token);
  }
}
