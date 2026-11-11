import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xjj_app_base/core/storage/local_storage.dart';
import 'package:xjj_app_base/core/utils/debounce.dart';
import 'package:xjj_app_base/core/utils/extensions.dart';
import 'package:xjj_app_base/core/utils/formatters.dart';
import 'package:xjj_app_base/core/utils/input_formatters.dart';
import 'package:xjj_app_base/core/utils/json.dart';
import 'package:xjj_app_base/core/utils/ref_ext.dart';

void main() {
  group('扩展方法', () {
    test('String', () {
      expect('  '.isBlank, isTrue);
      expect(' a '.nullIfBlank, ' a ');
      expect(''.nullIfBlank, isNull);
      expect(' 12 '.toIntOrNull(), 12);
      expect('x'.toDoubleOrNull(), isNull);
      expect('13812345678'.mask(), '138****5678');
      expect('1234567'.mask(), '1234567', reason: '长度不够不脱敏');
      expect('你好世界啊'.ellipsis(3), '你好世…');
      expect('你好'.ellipsis(3), '你好');
      expect('😀😀😀'.ellipsis(2), '😀😀…', reason: '不能把 emoji 截成两半');
      expect(null.orDefault(), '--');
      expect(' '.isNullOrBlank, isTrue);
    });

    test('Iterable', () {
      expect([1, 2, 3].firstWhereOrNull((e) => e > 5), isNull);
      expect([1, 2, 3, 4].groupBy((e) => e.isEven), {
        false: [1, 3],
        true: [2, 4],
      });
      expect(['a', 'bb', 'c'].distinctBy((e) => e.length), ['a', 'bb']);
      expect([1, 2, 3].sumBy((e) => e), 6);
      expect(<int>[].sumBy((e) => e), 0);
      expect([1, 2, 3, 4, 5].chunked(2), [
        [1, 2],
        [3, 4],
        [5],
      ]);
      expect([1, 2, 3].separatedBy(0), [1, 0, 2, 0, 3]);
      expect(<int>[].separatedBy(0), isEmpty);
    });

    test('DateTime', () {
      final d = DateTime(2024, 1, 31, 10, 30);
      expect(d.startOfDay, DateTime(2024, 1, 31));
      expect(d.endOfDay, DateTime(2024, 1, 31, 23, 59, 59, 999));
      expect(d.startOfMonth, DateTime(2024, 1, 1));
      expect(DateTime(2024, 2, 10).endOfMonth, DateTime(2024, 2, 29, 23, 59, 59, 999));
      expect(DateTime(2023, 12, 5).endOfMonth.day, 31);
      expect(d.addMonths(1), DateTime(2024, 2, 29, 10, 30), reason: '闰年 2 月取月末');
      expect(d.addMonths(13), DateTime(2025, 2, 28, 10, 30));
      expect(d.addMonths(-2), DateTime(2023, 11, 30, 10, 30));
      expect(DateTime(2024, 3, 15).addMonths(-3), DateTime(2023, 12, 15));
      expect(d.isSameDay(DateTime(2024, 1, 31, 23)), isTrue);
      expect(DateTime.utc(2024, 1, 31, 5).startOfDay.isUtc, isTrue);
    });
  });

  group('Fmt', () {
    test('number / percent / count / fileSize / duration', () {
      expect(Fmt.number(1.50), '1.5');
      expect(Fmt.number(2.00), '2');
      expect(Fmt.number(10), '10');
      expect(Fmt.number(100.0), '100');
      expect(Fmt.number(1.005, digits: 1), '1');
      expect(Fmt.number(null), '');
      expect(Fmt.percent(0.256), '26%');
      expect(Fmt.percent(0.256, digits: 1), '25.6%');
      expect(Fmt.count(9999), '9999');
      expect(Fmt.count(12345), '1.2万');
      expect(Fmt.count(100000), '10万');
      expect(Fmt.count(123456789), '1.2亿');
      expect(Fmt.fileSize(512), '512 B');
      expect(Fmt.fileSize(1536), '1.5 KB');
      expect(Fmt.fileSize(5 * 1024 * 1024), '5 MB');
      expect(Fmt.duration(const Duration(seconds: 65)), '01:05');
      expect(Fmt.duration(const Duration(hours: 1, minutes: 1, seconds: 5)), '1:01:05');
    });

    test('timeAgo', () {
      final now = DateTime(2024, 3, 10, 12);
      String ago(DateTime t) => Fmt.timeAgo(t, now: now);
      expect(ago(DateTime(2024, 3, 10, 11, 59, 30)), '刚刚');
      expect(ago(DateTime(2024, 3, 10, 11, 55)), '5分钟前');
      expect(ago(DateTime(2024, 3, 10, 9)), '3小时前');
      expect(ago(DateTime(2024, 3, 9, 23, 5)), '昨天 23:05');
      expect(ago(DateTime(2024, 3, 9, 8)), '昨天 08:00');
      expect(ago(DateTime(2024, 3, 8, 8)), '03-08');
      expect(ago(DateTime(2023, 3, 8, 8)), '2023-03-08');
      expect(ago(DateTime(2024, 3, 11, 8)), '2024-03-11 08:00', reason: '未来时间显示完整日期');
      expect(Fmt.timeAgo(null), '');
    });
  });

  group('JsonX', () {
    final json = <String, dynamic>{
      'id': 123,
      'name': 'a',
      'price': '12.5',
      'count': '7',
      'ratio': 1.9,
      'paid': 1,
      'flag': 'TRUE',
      'nil': null,
      'at': '2024-03-10 12:00:00',
      'sec': 1710000000,
      'ms': '1710000000000',
      'user': {'name': 'u'},
      'items': [
        {'name': 'x'},
        'bad',
        {'name': 'y'},
      ],
      'tags': ['a', 1, 'b'],
    };

    test('基础类型：类型不符时返回默认值，不抛异常', () {
      expect(json.str('id'), '123');
      expect(json.str('nil'), '');
      expect(json.str('missing', '-'), '-');
      expect(json.strOrNull('user'), isNull);
      expect(json.integer('count'), 7);
      expect(json.integer('ratio'), 1);
      expect(json.integer('price'), 12);
      expect(json.integer('name', -1), -1);
      expect(json.intOrNull('nil'), isNull);
      expect(json.number('price'), 12.5);
      expect(json.number('id'), 123.0);
      expect(json.boolean('paid'), isTrue);
      expect(json.boolean('flag'), isTrue);
      expect(json.boolean('name'), isFalse);
      expect(json.boolean('missing', true), isTrue);
    });

    test('日期：字符串、秒、毫秒时间戳', () {
      expect(json.date('at'), DateTime(2024, 3, 10, 12));
      expect(json.date('sec'), DateTime.fromMillisecondsSinceEpoch(1710000000000));
      expect(json.date('ms'), DateTime.fromMillisecondsSinceEpoch(1710000000000));
      expect(json.date('name'), isNull);
      expect(json.date('nil'), isNull);
    });

    test('嵌套对象和数组', () {
      String nameOf(Map<String, dynamic> j) => j.str('name');
      expect(json.obj('user', nameOf), 'u');
      expect(json.obj('name', nameOf), isNull);
      expect(json.list('items', nameOf), ['x', 'y']);
      expect(json.list('missing', nameOf), isEmpty);
      expect(json.listOf<String>('tags'), ['a', 'b']);
      expect(json.listOf<String>('name'), isEmpty);
    });
  });

  group('Validators', () {
    test('email / url / length', () {
      expect(Validators.email('a.b+c@x-y.com.cn'), isNull);
      expect(Validators.email('a@b'), isNotNull);
      expect(Validators.email('a b@c.com'), isNotNull);
      expect(Validators.url('https://example.com/a?b=1'), isNull);
      expect(Validators.url('ftp://example.com'), isNotNull);
      expect(Validators.url('example.com'), isNotNull);
      expect(Validators.length('12345', '密码', min: 6), '密码至少 6 位');
      expect(Validators.length('1234567', '密码', min: 6, max: 6), '密码最多 6 位');
      expect(Validators.length('123456', '密码', min: 6, max: 20), isNull);
    });

    test('idCard：校验码和出生日期', () {
      expect(Validators.idCard('11010519491231002X'), isNull);
      expect(Validators.idCard('11010519491231002x'), isNull);
      expect(Validators.idCard('440301199003071230'), isNull);
      expect(Validators.idCard('440301199003071231'), isNotNull, reason: '校验码错误');
      expect(Validators.idCard('110105194913310021'), isNotNull, reason: '13 月');
      expect(Validators.idCard('1101051949123100'), isNotNull);
      expect(Validators.idCard(null), isNotNull);
    });
  });

  group('Debouncer / Throttler', () {
    testWidgets('Debouncer 只执行最后一次，cancel 后不执行', (tester) async {
      final debouncer = Debouncer(const Duration(milliseconds: 300));
      final calls = <int>[];
      debouncer(() => calls.add(1));
      await tester.pump(const Duration(milliseconds: 200));
      debouncer(() => calls.add(2));
      expect(debouncer.isPending, isTrue);
      await tester.pump(const Duration(milliseconds: 300));
      expect(calls, [2]);

      debouncer(() => calls.add(3));
      debouncer.cancel();
      await tester.pump(const Duration(seconds: 1));
      expect(calls, [2]);
    });

    testWidgets('Throttler 间隔内只执行第一次', (tester) async {
      final throttler = Throttler(const Duration(seconds: 1));
      var calls = 0;
      expect(throttler(() => calls++), isTrue);
      expect(throttler(() => calls++), isFalse);
      await tester.pump(const Duration(seconds: 1));
      expect(throttler(() => calls++), isTrue);
      expect(calls, 2);
      await tester.pump(const Duration(seconds: 1));
    });
  });

  test('LocalStorage 扩展：bool / int / double / json，内容损坏返回 null', () async {
    final storage = MemoryStorage({'broken': '{oops', 'text': 'abc'});
    await storage.setBool('b', true);
    await storage.setInt('i', 42);
    await storage.setDouble('d', 1.5);
    await storage.setJson('j', {'name': 'wells'});

    expect(storage.getBool('b'), isTrue);
    expect(storage.getInt('i'), 42);
    expect(storage.getDouble('d'), 1.5);
    expect(storage.getJson('j'), {'name': 'wells'});
    expect(storage.getObject('j', (j) => j['name'] as String), 'wells');

    expect(storage.getBool('missing'), isNull);
    expect(storage.getInt('text'), isNull);
    expect(storage.getJson('broken'), isNull);
    expect(storage.getJson('i'), isNull, reason: '不是对象');
    expect(storage.getObject('j', (j) => j['age'] as int), isNull, reason: 'fromJson 抛异常');
  });

  testWidgets('ref.cacheFor：没人监听后保留一段时间再释放', (tester) async {
    var builds = 0;
    final provider = Provider.autoDispose((ref) {
      ref.cacheFor(const Duration(minutes: 1));
      return ++builds;
    });
    final container = ProviderContainer();

    container.listen(provider, (_, _) {}).close();
    await tester.pump(const Duration(seconds: 30));
    expect(container.read(provider), 1, reason: '缓存期内不重建');

    await tester.pump(const Duration(minutes: 2));
    expect(container.read(provider), 2, reason: '超时后已释放，重新创建');
    container.dispose(); // 释放时取消缓存定时器
  });
}
