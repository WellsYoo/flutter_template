import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xjj_app_base/shared/pagination.dart';

/// 可控的假数据源：共 [total] 条，[failNext] 为 true 时下一次请求失败
class _Source {
  _Source(this.total);
  final int total;
  bool failNext = false;
  final requestedPages = <int>[];

  /// 设置后，下一次请求会等它 complete 才返回（模拟慢请求）
  Completer<void>? gate;

  Future<PageResult<int>> fetch(int page, int size) async {
    requestedPages.add(page);
    final g = gate;
    gate = null;
    if (g != null) await g.future;
    if (failNext) {
      failNext = false;
      throw Exception('boom');
    }
    final start = (page - 1) * size;
    final end = (start + size).clamp(0, total);
    return PageResult(items: [for (var i = start; i < end; i++) i], hasMore: end < total);
  }
}

final _sourceProvider = Provider<_Source>((ref) => throw UnimplementedError());

class _Notifier extends PagedNotifier<int> {
  @override
  int get pageSize => 10;

  @override
  Future<PageResult<int>> fetchPage(int page) => ref.read(_sourceProvider).fetch(page, pageSize);
}

final _provider = AsyncNotifierProvider<_Notifier, PagedState<int>>(_Notifier.new);

void main() {
  late _Source source;
  late ProviderContainer container;

  setUp(() {
    source = _Source(25);
    container = ProviderContainer.test(
      overrides: [_sourceProvider.overrideWithValue(source)],
      retry: (_, _) => null,
    );
  });

  PagedState<int> current() => container.read(_provider).requireValue;

  test('首屏加载第一页', () async {
    final state = await container.read(_provider.future);
    expect(state.items, List.generate(10, (i) => i));
    expect(state.hasMore, isTrue);
  });

  test('loadMore 追加数据，到底后不再请求', () async {
    await container.read(_provider.future);
    final notifier = container.read(_provider.notifier);

    await notifier.loadMore();
    await notifier.loadMore();
    expect(current().items.length, 25);
    expect(current().hasMore, isFalse);

    await notifier.loadMore();
    expect(source.requestedPages, [1, 2, 3]);
  });

  test('并发 loadMore 只发一次请求', () async {
    await container.read(_provider.future);
    final notifier = container.read(_provider.notifier);

    await Future.wait([notifier.loadMore(), notifier.loadMore()]);
    expect(source.requestedPages, [1, 2]);
  });

  test('loadMore 失败保留已有数据，重试成功', () async {
    await container.read(_provider.future);
    final notifier = container.read(_provider.notifier);

    source.failNext = true;
    await notifier.loadMore();
    expect(current().items.length, 10);
    expect(current().loadMoreError, isNotNull);

    await notifier.loadMore();
    expect(current().items.length, 20);
    expect(current().loadMoreError, isNull);
  });

  test('refresh 回到第一页；有数据时失败则保留旧数据并抛出', () async {
    await container.read(_provider.future);
    final notifier = container.read(_provider.notifier);
    await notifier.loadMore();

    await notifier.refresh();
    expect(current().items.length, 10);

    source.failNext = true;
    await expectLater(notifier.refresh(), throwsException);
    expect(current().items.length, 10);
  });

  test('加载更多期间 provider 重建，过期结果不会覆盖新列表', () async {
    container.listen(_provider, (_, _) {}); // 保持订阅，invalidate 后会立即重建
    await container.read(_provider.future);
    final notifier = container.read(_provider.notifier);

    final slow = source.gate = Completer<void>();
    final pending = notifier.loadMore(); // 请求第 2 页，卡住

    container.invalidate(_provider); // 例如筛选条件变化
    await container.read(_provider.future); // 重建完成：第 1 页
    expect(current().items.length, 10);

    slow.complete(); // 旧的第 2 页回来了
    await pending;
    expect(current().items.length, 10, reason: '过期的加载更多结果应被丢弃');
    expect(current().loadingMore, isFalse);
  });

  test('loadMore 返回结果：loaded / noMore / failed', () async {
    await container.read(_provider.future);
    final notifier = container.read(_provider.notifier);

    expect(await notifier.loadMore(), LoadMoreResult.loaded);
    source.failNext = true;
    expect(await notifier.loadMore(), LoadMoreResult.failed);
    expect(await notifier.loadMore(), LoadMoreResult.noMore); // 第 3 页是最后一页
    expect(await notifier.loadMore(), LoadMoreResult.noMore);
    expect(source.requestedPages, [1, 2, 3, 3]);
  });

  test('加载更多期间刷新成功，旧的下一页结果不会追加到新列表', () async {
    await container.read(_provider.future);
    final notifier = container.read(_provider.notifier);

    final slow = source.gate = Completer<void>();
    final pending = notifier.loadMore(); // 请求第 2 页，卡住
    await notifier.refresh();
    expect(current().loadingMore, isFalse);

    slow.complete(); // 旧的第 2 页回来了
    expect(await pending, LoadMoreResult.skipped);
    expect(current().items.length, 10);
    expect(current().page, 1);

    expect(await notifier.loadMore(), LoadMoreResult.loaded);
    expect(current().items, List.generate(20, (i) => i));
  });

  test('加载更多期间刷新失败，加载更多照常生效', () async {
    await container.read(_provider.future);
    final notifier = container.read(_provider.notifier);

    final slow = source.gate = Completer<void>();
    final pending = notifier.loadMore();
    source.failNext = true;
    await expectLater(notifier.refresh(), throwsException);

    slow.complete();
    expect(await pending, LoadMoreResult.loaded);
    expect(current().items.length, 20);
  });

  test('刷新期间不加载更多，重复刷新只发一次请求', () async {
    await container.read(_provider.future);
    final notifier = container.read(_provider.notifier);

    final slow = source.gate = Completer<void>();
    final first = notifier.refresh();
    final second = notifier.refresh();
    expect(await notifier.loadMore(), LoadMoreResult.skipped);

    slow.complete();
    await Future.wait([first, second]);
    expect(source.requestedPages, [1, 1]);
    expect(current().items.length, 10);
  });

  test('加载更多期间 updateItems 的修改不会丢', () async {
    await container.read(_provider.future);
    final notifier = container.read(_provider.notifier);

    final slow = source.gate = Completer<void>();
    final pending = notifier.loadMore();
    notifier.updateItems((items) => items.sublist(1)); // 删掉第一条
    expect(current().loadingMore, isTrue);

    slow.complete();
    await pending;
    expect(current().items, List.generate(19, (i) => i + 1));
    expect(current().loadingMore, isFalse);
  });

  test('首屏失败进入 error 状态', () async {
    source.failNext = true;
    await expectLater(container.read(_provider.future), throwsException);
    expect(container.read(_provider).hasError, isTrue);
  });
}
