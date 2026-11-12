import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xjj_app_base/core/session/session.dart';
import 'package:xjj_app_base/core/storage/local_storage.dart';

void main() {
  test('启动时从本地恢复 token', () {
    final container = ProviderContainer.test(
      overrides: [
        localStorageProvider.overrideWithValue(MemoryStorage({StorageKeys.token: 'abc'})),
      ],
    );
    expect(container.read(sessionProvider).token, 'abc');
  });

  test('signIn / signOut 同步到本地存储', () async {
    final storage = MemoryStorage();
    final container = ProviderContainer.test(
      overrides: [localStorageProvider.overrideWithValue(storage)],
    );
    final notifier = container.read(sessionProvider.notifier);

    await notifier.signIn('t1');
    expect(container.read(sessionProvider).isLoggedIn, isTrue);
    expect(storage.getString(StorageKeys.token), 't1');

    await notifier.signOut();
    expect(container.read(sessionProvider).isLoggedIn, isFalse);
    expect(storage.getString(StorageKeys.token), isNull);
  });

  test('signOut：存储写失败也会退出登录', () async {
    final container = ProviderContainer.test(
      overrides: [localStorageProvider.overrideWithValue(_BrokenStorage())],
    );
    expect(container.read(sessionProvider).isLoggedIn, isTrue);

    await expectLater(container.read(sessionProvider.notifier).signOut(), throwsStateError);
    expect(container.read(sessionProvider).isLoggedIn, isFalse);
  });
}

/// 读得到 token，但写入 / 删除都失败
class _BrokenStorage implements LocalStorage {
  @override
  String? getString(String key) => 'abc';

  @override
  Future<void> setString(String key, String value) async => throw StateError('disk full');

  @override
  Future<void> remove(String key) async => throw StateError('disk full');
}
