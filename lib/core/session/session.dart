import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xjj_app_base/core/storage/local_storage.dart';

/// 登录会话。需要缓存用户信息时在这里加字段。
class Session {
  const Session({this.token});

  final String? token;

  bool get isLoggedIn => token != null && token!.isNotEmpty;
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
    await _storage.remove(StorageKeys.token);
    state = const Session();
  }
}
