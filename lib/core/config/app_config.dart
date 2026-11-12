/// 运行环境配置，编译期通过 `--dart-define-from-file=env/xxx.json` 注入。
///
/// 新增配置项：在 env/*.json 里加 key，再在这里加一个 `String.fromEnvironment`。
class AppConfig {
  const AppConfig._();

  static const String env = String.fromEnvironment('APP_ENV', defaultValue: 'dev');

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://dev-api.example.com',
  );

  static bool get isProd => env == 'prod';

  /// 网络超时
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
