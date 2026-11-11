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

样式常量：颜色 `context.xColors.text / textSecondary / textHint / divider / background / card / success / warning / danger`，
主色 `context.colors.primary`；字号 `FontSizes`；间距 `Insets`；圆角 `Radii`。
尺寸单位是逻辑像素，750 设计稿上的 px 除以 2。

组件统一用 `X` 前缀（`XButton`、`XText`…），文件名 `x_*.dart`；主题常量 `Insets` / `Radii` / `FontSizes` 不带前缀。

换品牌色、圆角、字体或个别颜色，在 `app/app.dart` 里用 `XTheme.create`：

```dart
theme: XTheme.create(primary: const Color(0xFF07C160), radius: 4),
darkTheme: XTheme.create(
  brightness: Brightness.dark,
  colors: XColors.dark.copyWith(background: Colors.black),
),
```

### 和旧版 xjj_app_base 组件的对应

| 旧 | 新 |
| --- | --- |
| `ScreenText.title / subTitle / content / weak` | `XText.title / body / secondary / caption` |
| `context.colorStyle.textBiz / textSubBiz / dividerLine` | `context.xColors.text / textHint / divider` |
| `context.sizeStyle.hSpacingStandard`、`ScreenSpacer`、`ScreenPadding` | `Insets.lg`、`SizedBox`、`Padding` |
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

没有迁移的：日历、步进器、锚点、气泡菜单、截图分享、图片预览、WebView、视频、微信。
这些依赖重或使用面窄，项目用到时再加，可以参考 `.legacy-backup/`（本地备份，不入库）或 git 历史。

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
├── app/                   组装层：App、路由表、环境配置（只有这里引用各 feature）
├── core/                  与业务无关的基础设施
│   ├── network/           ApiClient（拆包、异常、401）、ApiException
│   ├── session/           登录会话（token）
│   ├── storage/           LocalStorage 接口 + 实现
│   ├── theme/             主题、颜色、字号、间距、主题模式
│   └── utils/             context 扩展、格式化、输入限制、日志
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
- **错误提示**：`XToast.error(e)` 或 `errorMessageOf(e)`，不要自己拼错误文案。
- **按钮 loading**：`XButton` 的 `onPressed` 返回 Future 就会转圈。只有“等接口”才返回 Future；
  弹确认框这类等用户操作的，写成 `() => unawaited(_confirm())`。
- **跳转**：`context.push(Routes.xxx)`，不手写路径字符串。登录态变化不需要手动跳转，路由守卫会处理。
- **样式**：用 `XText`、`context.xColors`、`Insets`、`Radii`，不写裸色值和数字。
- **本地存储**：key 统一加到 `StorageKeys`。
- **测试**：Repository 都有接口，测试里用 `overrideWithValue` 换成假实现，见 `test/`。

## 多环境

`env/dev.json`、`env/prod.json` 通过 `--dart-define-from-file` 注入，在 `AppConfig` 里读取。
加配置项：json 里加 key，`AppConfig` 里加一行 `String.fromEnvironment`。

```bash
fvm flutter build apk --release --dart-define-from-file=env/prod.json
```

## 用模板创建新项目

1. 复制仓库，删除 `.git`。
2. 改包名：`pubspec.yaml` 的 `name`，然后全局替换 `package:xjj_app_base/` 为新名字。
3. 改应用 ID / 名称：
   - Android：`android/app/build.gradle.kts` 的 `applicationId`、`namespace`，`AndroidManifest.xml` 的 `android:label`
   - iOS：Xcode 里的 Bundle Identifier，`Info.plist` 的 `CFBundleDisplayName`
4. 把 `authRepositoryProvider`、`articleRepositoryProvider` 换成真实实现。
5. 删掉示例：`features/demo/` 目录，以及 `routes.dart`、`router.dart`、`home_shell.dart` 里对应的 demo 路由和 tab。

## 刻意没有包含的

按需再加，避免模板变重：

- **代码生成**（freezed / json_serializable / riverpod_generator）：模型多、字段复杂时再引入。
- **屏幕适配**（flutter_screenutil）：优先用弹性布局；设计稿必须等比还原时再加。
- **网络图片磁盘缓存**（cached_network_image）：只需改 `XImage` 一个文件。
- **图片选择**、**WebView**、**视频**、**微信 SDK** 等：项目用到时再加。
- **安全存储**：token 目前存在 SharedPreferences。安全要求高时把 `PrefsStorage` 换成 flutter_secure_storage 实现，接口不变。
- **国际化**：已接入 Flutter 自带的中文组件文案。需要多语言时启用 `flutter gen-l10n`。
