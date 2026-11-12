# Flutter 项目模板

新项目的起点：Riverpod 3 + go_router + dio + 一套业务 UI 组件，无代码生成。

```
flutter_riverpod   状态管理 / 依赖注入
go_router          路由 + 登录守卫
dio                网络
easy_refresh       下拉刷新 / 上拉加载
shared_preferences 本地存储
intl               日期数字格式化
```

开箱即有：登录/退出与 401 自动登出、底部导航、分页列表（下拉刷新 + 上拉加载 + 空/错状态）、
详情页、表单、亮/暗主题、统一异常处理、toast/loading/弹窗/底部弹层、多环境配置、测试。

| 想做什么 | 看哪里 |
| --- | --- |
| 跑起来 | [运行](#运行) |
| 了解代码怎么组织、启动和登录怎么串起来 | [目录](#目录)、[基础能力](#基础能力) |
| 写一个新页面 / 新模块 | [新增一个业务模块](#新增一个业务模块)、[常用场景速查](#常用场景速查)、[约定](#约定) |
| 查组件和工具怎么用 | [UI 组件](#ui-组件)、[工具类](#工具类) |
| 写测试、打包、CI | [测试](#测试)、[多环境](#多环境)、[打包](#打包)、[CI](#ci) |
| 基于模板开新项目 | [用模板创建新项目](#用模板创建新项目)、[刻意没有包含的](#刻意没有包含的) |
| 从旧版 xjj_app_base 迁移 | [附：和旧版组件的对应](#附和旧版-xjj_app_base-组件的对应) |

## 运行

```bash
fvm use            # Flutter 版本见 .fvm/fvm_config.json
fvm flutter pub get
fvm flutter run --dart-define-from-file=env/dev.json
fvm flutter test
```

演示登录：任意用户名，密码 `123456`。

**IDE 必须使用项目内的 Flutter SDK**（Dart 3.11+），否则会大面积报语法错误：

- VS Code：已在 `.vscode/settings.json` 配好，重新打开项目即可。
- Android Studio：Settings → Languages & Frameworks → Flutter → SDK path 填
  `<项目目录>/.fvm/flutter_sdk`，然后 File → Invalidate Caches 重启。

## UI 组件

页面只需要一个 import：`import 'package:xjj_app_base/shared/ui/ui.dart';`
（包含组件、主题常量、`context` 扩展、格式化和输入限制）。

“示例 → UI 组件一览”可以看到全部效果，代码在 `features/demo/ui_kit_page.dart`。

| 组件 | 用途 | 示例 |
| --- | --- | --- |
| `XText` | 统一字号颜色的文本；`size` `color` `bold` `maxLines` `lineThrough` 可单独覆盖 | `XText.title('标题')` `.body` `.secondary` `.caption` `XText('自定义', size: 20, bold: true)` `XText.money(1234.5)` |
| `XButton` | 按钮；返回 Future 自动 loading、防重复点击、异常 toast；`color` `round` `width` `icon` `confirm`（二次确认） | `XButton.primary('提交', block: true, onPressed: _submit)` `.outline` `.danger` `.text` `XButton.danger('删除', confirm: '确定删除？', onPressed: _delete)` |
| `XContainer` | 容器：圆角 / 渐变 / 边框 / 阴影 / 圆形 / 点击，不用手写 BoxDecoration | `XContainer(colors: [c1, c2], radius: 8, border: true, shadow: true, onTap: ..., child: ...)` |
| `XCard` | 白底圆角卡片，可点击；`color` `radius` `border` | `XCard(onTap: ..., child: ...)` |
| `XCell` | 设置页 / 个人中心的列表行：图标 + 标题 + 值 + 箭头 | `XCell('缓存', icon: Icons.storage, value: '12 MB', onTap: _clear)` |
| `XInfoRow` | “标签：值”一行 | `XInfoRow('合同编号', no)` |
| `XTag` | 状态标签；`color` `outlined` `icon` | `XTag('待审核', type: XTagType.warning)` |
| `XBottomBar` | 页面底部操作栏，处理安全区，按钮等分 | `bottomNavigationBar: XBottomBar(children: [...])` |
| `XFormSection` / `XFormItem` | 表单分组和表单行；`picker` / `date` 自带弹层；`help` 说明文字；`XFormSection(labelWidth:)` 统一标签宽度 | `XFormItem.input` `.select` `.textarea` `.switcher` `.text` `XFormItem.radio` `XFormItem.picker` `XFormItem.date` |
| `XImage` | 图片，统一占位和失败图 | `XImage(url, width: 120, height: 80, radius: 8)`、`XImage.avatar(url, size: 40)` |
| `XBadge` | 角标：红点 / 数字 | `XBadge(count: unread, child: Icon(...))` |
| `XStepper` | 数量步进器 | `XStepper(value: n, min: 1, max: stock, onChanged: ...)` |
| `XCountdownButton` | 验证码倒计时按钮，发送成功才开始倒计时 | `XCountdownButton(onSend: () => repo.sendCode(phone))` |
| `XExpandableText` | 长文本展开 / 收起 | `XExpandableText(content, maxLines: 3)` |
| `XSkeleton` | 骨架屏占位块 | `XSkeleton(width: 120)` `XSkeleton.circle(size: 40)` |
| `XSearchField` | 搜索框，自带防抖和清除；`round` 灰底胶囊样式 | `XSearchField(onChanged: ...)` |
| `XPagedListView` | 分页列表（EasyRefresh） | 见下文 |
| `XAsyncView` | 异步数据的加载 / 失败 / 空 / 刷新 | `XAsyncView(value: ..., onRefresh: ..., isEmpty: (d) => d.isEmpty, data: ...)` |
| `XRefresh` | EasyRefresh 统一样式封装，特殊页面直接用 | `XRefresh(onRefresh: ..., child: CustomScrollView(...))` |
| `XEmptyView` / `XErrorView` / `XLoadingView` | 状态视图；空状态可带插图和按钮 | `XEmptyView(message: '还没有订单', actionText: '去逛逛', onAction: ...)` |
| `XToast` | 轻提示；默认时长 / 位置改 `XToast.duration` / `XToast.position` | `XToast.show('已复制')` `XToast.success('保存成功')` `XToast.error(e)` |
| `XLoading` | 全屏 loading，跟随 Future 关闭；也可手动 `show` / `hide` | `await XLoading.run(() => repo.save(), message: '提交中')` |
| `XDialog` | 确认框 / 提示框 / 输入框 / 自定义 | `await XDialog.confirm(content: '确定删除？', danger: true)` `XDialog.input(title: '修改昵称')` |
| `XSheet` | 底部弹层 | `XSheet.actions` `.select` `.multiSelect` `.date` `.custom` |
| `InputFormats` / `Validators` | 输入限制 / 校验 | `InputFormats.decimal(2)` `InputFormats.phone` `Validators.phone(v)` |

### 样式常量

| 要什么 | 用什么 | 示例 |
| --- | --- | --- |
| 空白 | 预设 `XGap.v8` / `XGap.h12`…（v 上下、h 左右，数字即大小：2 / 4 / 6 / 8 / 10 / 12 / 16 / 20 / 24 / 32）；自定义 `XGap.v(n)` / `XGap.h(n)` | `XGap.v8` `const XGap.v(18)` |
| 内边距 | 预设 `XPad.all16` / `XPad.h16` / `XPad.v8`…（4 / 8 / 10 / 12 / 16 / 20 / 24 / 32）、`XPad.page`；自定义 `XPad.all(n)` / `.h(n)` / `.v(n)` / `.hv(h, v)` / `.only(...)` / `.ltrb(...)` | `XPad.all16` `XPad.hv(16, 8)` |
| 圆角 | 各组件的 `radius` 参数直接填数字；全局默认圆角在 `XTheme.create(radius:)` | `XContainer(radius: 12)` |
| 字号 | `FontSizes.headline/title/body/secondary/caption/amount`（18 / 16 / 14 / 13 / 12 / 22） | |
| 字重 | `FontWeights.regular/medium/semibold/bold` | |
| 文字样式 | `context.textStyles.headline/title/body/secondary/caption`（和 `XText` 同一套） | `TextField(style: context.textStyles.body)` |
| 颜色 | `context.primary`；`context.xColors.text / textSecondary / textHint / textDisabled / divider / border / background / card / fill / mask / success / warning / danger` | |
| 屏幕 | `context.screenSize` `context.safeTop` `context.safeBottom` | |

颜色跟随深浅色主题，所以从 `context` 取；其余是固定常量。
尺寸单位是逻辑像素，750 设计稿上的 px 除以 2。

组件统一用 `X` 前缀（`XButton`、`XText`…），文件名 `x_*.dart`。间距有常用预设（名字里带数值），也可以自定义。

换品牌色、圆角、字体或个别颜色，在 `app/app.dart` 里用 `XTheme.create`：

```dart
theme: XTheme.create(primary: const Color(0xFF07C160), radius: 4),
darkTheme: XTheme.create(
  brightness: Brightness.dark,
  colors: XColors.dark.copyWith(background: Colors.black),
),
```

## 工具类

格式化、扩展方法、校验、防抖节流已由 `ui.dart` 导出，页面里不用再单独 import；
其余几个在各自的文件里，表格中标了路径。

| 工具 | 用途 | 示例 |
| --- | --- | --- |
| `Fmt` | 日期 / 数字格式化 | `Fmt.date` `.dateTime` `.time` `.timeAgo`（刚刚 / 5分钟前 / 昨天 14:05）`.money` `.number` `.percent` `.count`（1.2万）`.fileSize` `.duration` |
| 字符串扩展 | 判空、转换、脱敏 | `s.isBlank` `s.nullIfBlank` `s.toIntOrNull()` `phone.mask()` `s.ellipsis(10)` `name.orDefault()` |
| 集合扩展 | 标准库没有的常用操作 | `list.firstWhereOrNull` `.groupBy` `.distinctBy` `.sumBy` `.chunked(3)` `.separatedBy` |
| 日期扩展 | 起止时间、加减月 | `d.startOfDay` `.endOfDay` `.startOfMonth` `.endOfMonth` `.isToday` `.isSameDay` `.addMonths(1)` |
| `JsonX`（`core/utils/json.dart`） | 手写 `fromJson` 时宽松取值，类型不符返回默认值不抛异常 | `json.str('id')` `.integer` `.number` `.boolean` `.date` `.obj` `.list` `.listOf<String>` |
| `Validators` / `InputFormats` | 校验 / 输入限制 | `Validators.required` `.phone` `.email` `.url` `.length` `.idCard`；`InputFormats.decimal(2)` `.phone` `.idCard` `.digits` |
| `Debouncer` / `Throttler` | 防抖 / 节流 | `_debouncer(() => _search(v))` |
| `Log`（`core/utils/logger.dart`） | 日志，release 包不输出 | `Log.d('xxx')` `Log.e('失败', error: e, stackTrace: st)` |
| `LocalStorage` 扩展（`core/storage/local_storage.dart`） | 存取 bool / int / double / JSON / 模型 | `storage.setBool(key, true)` `storage.getObject(key, User.fromJson)` |
| `ref.cancelToken()`（`core/network/api_client.dart`） | provider 释放时取消请求 | 见 `features/article/article_providers.dart` |
| `ref.cacheFor()`（`core/utils/ref_ext.dart`） | autoDispose 的 provider 离开页面后再缓存一段时间 | `ref.cacheFor(const Duration(minutes: 5))` |

## 常用场景速查

“示例” tab 里每个场景都能直接点开看效果，代码在 `features/demo/`。

| 场景 | 用什么 | 参考代码 |
| --- | --- | --- |
| 分页列表（下拉刷新 + 上拉加载 + 空状态 + 错误重试） | `PagedNotifier` + `XPagedListView` | `features/article/article_providers.dart` |
| 带搜索 / 筛选的列表 | `AsyncNotifierProvider.family`，条件作为参数 + `XSearchField` | `features/article/presentation/article_list_page.dart` |
| 详情页（加载 / 失败重试 / 下拉刷新 / 底部按钮） | `FutureProvider.family` + `XAsyncView(onRefresh:)` + `XBottomBar` | `features/article/presentation/article_detail_page.dart` |
| 表单（输入 / 选择 / 日期 / 校验 / 提交） | `XFormSection` + `XFormItem` + `XSheet` + `XLoading` | `features/demo/form_demo_page.dart` |
| 登录类表单（按钮 loading） | `Form` + `XButton`（onPressed 返回 Future） | `features/auth/presentation/login_page.dart` |
| 二次确认 | `XButton(confirm:)` 或 `XDialog.confirm` | `features/profile/profile_page.dart` |

列表各状态的表现：

| 状态 | 表现 |
| --- | --- |
| 首屏加载中 | 居中 loading |
| 首屏失败 | 错误文案 + “重试”按钮 |
| 空数据 | `XEmptyView`（可自定义文案），仍可下拉刷新 |
| 下拉刷新失败 | 保留旧数据，toast 提示 |
| 上拉加载失败 | toast 提示，footer 显示“加载失败，上拉重试” |
| 没有更多 | 关闭上拉，列表底部显示“没有更多了” |
| 切换搜索条件 | 新条件从第 1 页加载，旧请求结果自动丢弃 |

## 目录

```
lib/
├── main.dart              启动：初始化存储、全局异常、ProviderScope
├── app/                   组装层：App、路由表、404 页（只有这里引用各 feature）
├── core/                  与业务无关的基础设施
│   ├── config/            AppConfig 环境配置
│   ├── network/           ApiClient（拆包、异常、401）、ApiException
│   ├── session/           登录会话（token）
│   ├── storage/           LocalStorage 接口 + 实现
│   ├── theme/             主题、颜色、字号、间距、主题模式
│   └── utils/             扩展方法、格式化、JSON 取值、校验、防抖节流、日志
├── shared/
│   ├── pagination.dart    PagedNotifier 分页基类
│   └── ui/                UI 组件库，ui.dart 为总入口
└── features/              按业务模块划分
    ├── article/
    │   ├── data/          模型 + Repository（接口 / 真实实现 / 假实现）
    │   ├── presentation/  页面
    │   └── article_providers.dart
    └── demo/              示例，新项目可删除
```

依赖方向：`features → shared → core`，`app` 组装所有模块。feature 之间不互相引用。

## 基础能力

模板已经串好的几条主线，改之前先知道它们在哪。

**启动**（`main.dart`）：注册全局异常兜底 → 初始化本地存储 → 通过 `ProviderScope` 的 override 注入 → `App`。
启动前还要异步准备别的东西（读配置、初始化 SDK），照 `localStorageProvider` 的写法加。

**登录与会话**（`core/session/session.dart`）：

- 登录成功调 `ref.read(sessionProvider.notifier).signIn(token)`，退出调 `signOut()`。token 存本地，下次启动自动恢复。
- 页面不用自己跳转：路由守卫监听会话，未登录一律去登录页，登录后回到原来要去的页面。
- 接口返回 401（HTTP 状态码，或 `ApiEnvelope.unauthorizedCodes` 里的业务码）自动登出。
  只认“当前 token”发出的请求，旧账号的慢请求不会把新登录的账号踢掉。
- 要缓存用户信息，在 `Session` 里加字段。

**路由**（`app/routes.dart` 定义路径，`app/router.dart` 注册页面）：

- 带底部导航的页面放在 `StatefulShellRoute` 的 branch 里，每个 tab 有独立的导航栈。
  加 tab：`router.dart` 加一个 branch，`features/home/home_shell.dart` 加一个 destination。
- tab 内的二级页面写成子路由，保留底部导航；要盖住底部导航的全屏页放在 shell 外面，
  或给子路由加 `parentNavigatorKey: rootNavigatorKey`。
- 路径没匹配上显示 `NotFoundPage`。

**网络**（`core/network/`）：`dioProvider` 负责 baseUrl、超时、带 token、debug 日志；
`ApiClient` 负责拆包和统一异常。要加公共请求头、签名、token 刷新，在 `dioProvider` 里加拦截器。

**全局 UI 行为**（`app/app.dart`）：亮 / 暗主题和主题模式（`themeModeProvider`，持久化）、
中文组件文案、系统字体缩放上限 1.3 倍、点击空白处收起键盘。

**日志与崩溃上报**：`Log.d` / `Log.e` 只在 debug / profile 输出。接入 Sentry、Bugly 等，
改 `main.dart` 里的两个全局异常回调和 `Log.e`。

## 新增一个业务模块

以 `order` 为例，照着 `features/article` 抄：

1. **模型** `features/order/data/order.dart`：手写 `fromJson`。
2. **Repository** `features/order/data/order_repository.dart`：
   ```dart
   final orderRepositoryProvider = Provider((ref) => OrderRepository(ref.watch(apiClientProvider)));

   class OrderRepository {
     OrderRepository(this._api);
     final ApiClient _api;

     Future<Order> detail(String id) =>
         _api.get('/orders/$id', decode: (d) => Order.fromJson(d! as Map<String, dynamic>));
   }
   ```
3. **Provider**：按场景选：

   | 场景 | 写法 |
   | --- | --- |
   | 只读数据（详情） | `FutureProvider.autoDispose.family<Order, String>` |
   | 分页列表 | 继承 `PagedNotifier<Order>`，实现 `fetchPage` |
   | 跨页面共享、有交互的状态 | `Notifier` / `AsyncNotifier` |
   | 只在一个页面里用的临时状态（表单字段） | `StatefulWidget` 的 `setState` 即可 |

4. **页面**：`ConsumerWidget` + `ref.watch`，异步数据用 `XAsyncView` 或 `XPagedListView`。
5. **路由**：在 `app/routes.dart` 加路径，在 `app/router.dart` 加 `GoRoute`。

## 约定

- **网络**：只通过 `ApiClient` 调接口。它负责拆 `{code, msg, data}`、把所有错误转成 `ApiException`、
  遇到 401 自动登出。后端字段名或成功码不同，改 `ApiEnvelope`。
  上传文件把 `FormData` 作为 `data` 传给 `post` 即可。
- **错误提示**：`XToast.error(e)` 或 `errorMessageOf(e)`，不要自己拼错误文案。
  非接口异常（一般是代码 bug）提示“数据异常”的同时会打日志，调试时留意控制台。
- **按钮 loading**：`XButton` 的 `onPressed` 返回 Future 就会转圈。只有“等接口”才返回 Future；
  弹确认框这类等用户操作的，写成 `() => unawaited(_confirm())`。
- **跳转**：`context.push(Routes.xxx)`，不手写路径字符串。登录态变化不需要手动跳转，路由守卫会处理。
  路径没匹配上显示 `NotFoundPage`；路径参数要做合法性判断，非法时也返回它，不要抛异常。
- **样式**：用 `XText`、`context.xColors`，不写裸色值；间距用 `XGap` / `XPad`，数值按设计稿填。
- **本地存储**：key 统一加到 `StorageKeys`。
- **测试**：Repository 都有接口，测试里用 `overrideWithValue` 换成假实现，见 `test/`。

## 测试

```bash
fvm flutter test                               # 全部
fvm flutter test test/shared/pagination_test.dart
```

```
test/
├── app_test.dart          整体流程：登录 → 首页 → 详情 → 退出，404
├── demo_list_test.dart    列表各状态在页面上的表现
├── core/                  ApiClient、会话、工具类
├── shared/                分页逻辑、UI 组件
└── features/              业务模块，目录和 lib/features 对应
```

不依赖真实后端和设备，靠 override 换掉外部依赖：

| 要换掉的 | 用什么 |
| --- | --- |
| 本地存储 | `localStorageProvider.overrideWithValue(MemoryStorage({...}))` |
| 接口数据 | Repository 的假实现：`articleRepositoryProvider.overrideWithValue(FakeArticleRepository(delay: Duration.zero))` |
| HTTP 响应（测 `ApiClient` 本身） | 自定义 `HttpClientAdapter`，见 `test/core/api_client_test.dart` |
| 当前时间 | `Fmt.timeAgo(t, now: ...)` 传入固定时间 |

纯逻辑用 `ProviderContainer.test(overrides: [...])`，页面用 `ProviderScope(overrides: [...], child: ...)`，
写法见 `test/core/session_test.dart` 和 `test/app_test.dart`。

## 多环境

`env/dev.json`、`env/prod.json` 通过 `--dart-define-from-file` 注入，在 `AppConfig`（`core/config/app_config.dart`）里读取。
加配置项：json 里加 key，`AppConfig` 里加一行 `String.fromEnvironment`。

不带 `--dart-define-from-file` 时默认是 dev 环境，打正式包不要漏掉这个参数。

## 打包

```bash
fvm flutter build apk --release --dart-define-from-file=env/prod.json
fvm flutter build ipa --release --dart-define-from-file=env/prod.json
```

Android 正式签名：把 keystore 放到 `android/` 下，新建 `android/key.properties`（已在 .gitignore，不要提交）：

```properties
storeFile=release.jks
storePassword=***
keyAlias=***
keyPassword=***
```

`storeFile` 相对 `android/` 目录。没有这个文件时 release 包用 debug 签名，只能本机调试，不能上架。

## CI

`.github/workflows/ci.yml`：push 到 main 和提 PR 时检查格式、静态分析、跑测试。
Flutter 版本读 `.fvm/fvm_config.json`。提交前本地可以先跑：

```bash
fvm dart format lib test && fvm flutter analyze && fvm flutter test
```

## 用模板创建新项目

1. **复制仓库**，删除 `.git` 后重新 `git init`。
2. **改包名**：`pubspec.yaml` 的 `name` 和 `description`，然后全局替换 `package:xjj_app_base/` 为新名字
   （`lib/` 和 `test/` 都要换）。
3. **改应用名称**：
   - `lib/app/app.dart` 的 `title`
   - Android：`android/app/src/main/AndroidManifest.xml` 的 `android:label`
   - iOS：`ios/Runner/Info.plist` 的 `CFBundleDisplayName`、`CFBundleName`
4. **改应用 ID**：
   - Android：`android/app/build.gradle.kts` 的 `applicationId`、`namespace`；
     `MainActivity.kt` 的 `package` 和它所在的目录要跟 `namespace` 一致
   - iOS：Xcode 里 Runner 和 RunnerTests 的 Bundle Identifier（现在是 `com.xjjchain.xjjAppBase`）
5. **换图标和启动图**：Android 的 `res/mipmap-*`、`res/drawable*/launch_background.xml`，
   iOS 的 `Assets.xcassets`。
6. **配后端**：`env/dev.json`、`env/prod.json` 填接口地址；响应格式或成功码不是
   `{code: 0, msg, data}` 的改 `ApiEnvelope`。
7. **接真实接口**：把 `authRepositoryProvider`、`articleRepositoryProvider` 换成真实实现。
8. **删示例**：`features/demo/` 目录，以及 `routes.dart`、`router.dart`、`home_shell.dart` 里对应的
   demo 路由和 tab，`test/demo_list_test.dart`。`features/article/` 留着当参考，有了自己的模块再删。
9. **配签名**：见[打包](#打包)。
10. **清理文档**：README 里“附：和旧版组件的对应”一节，按需更新 `LICENSE`。

改完跑一遍 `fvm flutter analyze && fvm flutter test` 确认没有漏改的地方。

## 刻意没有包含的

按需再加，避免模板变重：

- **代码生成**（freezed / json_serializable / riverpod_generator）：模型多、字段复杂时再引入。
- **屏幕适配**（flutter_screenutil）：优先用弹性布局；设计稿必须等比还原时再加。
- **网络图片磁盘缓存**（cached_network_image）：只需改 `XImage` 一个文件。
- **图片选择**、**WebView**、**视频**、**微信 SDK** 等：项目用到时再加。
- **token 刷新**：现在是 401 直接登出。后端有 refresh token 时，在 `dioProvider` 里加拦截器（推荐 `QueuedInterceptor`，并发 401 只刷新一次）。
- **横竖屏**：没有锁定方向。只支持竖屏的话，在 `main()` 里调 `SystemChrome.setPreferredOrientations`，并删掉 `Info.plist` 里的横屏项。
- **http 明文请求**：Android 9+ / iOS 默认禁止。测试环境只有 http 时再按平台单独放开，不要带到正式包。
- **安全存储**：token 目前存在 SharedPreferences。安全要求高时把 `PrefsStorage` 换成 flutter_secure_storage 实现，接口不变。
- **国际化**：已接入 Flutter 自带的中文组件文案。需要多语言时启用 `flutter gen-l10n`。

## 附：和旧版 xjj_app_base 组件的对应

新项目用不到这一节，可以删掉。

| 旧 | 新 |
| --- | --- |
| `ScreenText.title / subTitle / content / weak` | `XText.title / body / secondary / caption` |
| `context.colorStyle.textBiz / textSubBiz / dividerLine` | `context.xColors.text / textHint / divider` |
| `context.sizeStyle.hSpacingStandard`、`ScreenSpacer`、`ScreenPadding` | `XGap.v16` / `XGap.h16`、`XPad.all16` |
| `ScreenButton.text / ScreenOutlineButton.text` | `XButton.primary / XButton.outline` |
| `ScreenBottomBar` + `ScreenBottomButton` | `XBottomBar` + `XButton` |
| `ScreenSettingItem.choose / inputText / inputMultiLine / operateSwitch / radio / view` | `XFormItem.select / input / textarea / switcher / radio / text` |
| `ScreenSettingItem.inputRMB / inputDouble` | `XFormItem.input(inputFormatters: [InputFormats.decimal(2)], suffix: '元')` |
| `ScreenSettingContainer`、`ScreenSettingTitle` | `XFormSection(title: ...)` |
| `ItemTextRow` | `XInfoRow` |
| `ScreenContainer.round`、`ScreenInkWellContainer` | `XCard` |
| `ScreenNetImage / ScreenNormalImage` | `XImage`（网络图和 asset 同一个入口） |
| `MyEasyRefresh` | `XPagedListView` / `XRefresh` |
| `MyNoDataWidget`、`MyErrorWidget` | `XEmptyView`、`XErrorView` |
| `MyToastUtil.showToast / showLoading / showSuccess` | `XToast.show / XLoading.run / XToast.success` |
| `MyDialogUtil.showConfirm / showTip` | `XDialog.confirm / alert` |
| `MyDrawerUtil.showBottomOption / showBottomRadioList / showBottomWheel` | `XSheet.actions / select / custom` |
| 日期选择相关 widget | `XSheet.date` |
| `MySearchBar` | `XSearchField` |
| `MyBaseState`、`MyBaseBody`、`MyOriginBody` | `Scaffold` + `XAsyncView`（加载 / 失败 / 重试由 Riverpod 状态驱动） |

没有迁移的：日历、锚点、气泡菜单、截图分享、图片预览、WebView、视频、微信。
这些依赖重或使用面窄，项目用到时再加，可以参考 `.legacy-backup/`（本地备份，不入库）或 git 历史。
