import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xjj_app_base/core/network/api_exception.dart';
import 'package:xjj_app_base/core/session/session.dart';
import 'package:xjj_app_base/features/auth/data/auth_repository.dart';
import 'package:xjj_app_base/shared/ui/ui.dart';

enum _LoginMode { password, sms }

/// 登录页：密码登录 / 验证码登录两种方式，共用一个 Form 做校验。
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _phone = TextEditingController();
  final _code = TextEditingController();

  var _mode = _LoginMode.password;
  var _obscure = true;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    _phone.dispose();
    _code.dispose();
    super.dispose();
  }

  /// XButton 会在 Future 执行期间显示 loading，异常自动 toast
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    context.hideKeyboard();
    final auth = ref.read(authRepositoryProvider);
    final token = switch (_mode) {
      _LoginMode.password => await auth.login(
        username: _username.text.trim(),
        password: _password.text,
      ),
      _LoginMode.sms => await auth.loginWithCode(phone: _phone.text, code: _code.text),
    };
    // 会话变化后，路由守卫会自动跳转，这里不需要手动 go
    await ref.read(sessionProvider.notifier).signIn(token);
  }

  /// 手机号不对时抛异常：XCountdownButton 会 toast，并且不开始倒计时
  Future<void> _sendCode() async {
    final error = Validators.phone(_phone.text);
    if (error != null) throw ApiException(ApiErrorType.business, error);
    await ref.read(authRepositoryProvider).sendCode(_phone.text);
    XToast.show('验证码已发送（演示：123456）');
  }

  @override
  Widget build(BuildContext context) {
    final c = context.xColors;
    return Scaffold(
      backgroundColor: c.card,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const XPad.hv(28, 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  XContainer(
                    size: 60,
                    radius: 18,
                    colors: brandGradient(context.primary),
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    alignment: Alignment.center,
                    child: const Icon(Icons.layers_rounded, size: 30, color: Colors.white),
                  ),
                  XGap.v24,
                  const XText('欢迎登录', size: 26, bold: true),
                  XGap.v6,
                  const XText.secondary('合同审批工作台 · Flutter 项目模板示例'),
                  XGap.v32,
                  _ModeSwitch(mode: _mode, onChanged: (mode) => setState(() => _mode = mode)),
                  XGap.v20,
                  if (_mode == _LoginMode.password) ..._passwordFields() else ..._smsFields(),
                  XGap.v24,
                  XButton.primary('登录', block: true, onPressed: _submit),
                  XGap.v16,
                  Center(
                    child: XText.caption(
                      _mode == _LoginMode.password
                          ? '演示账号：任意用户名，密码 123456'
                          : '演示账号：任意手机号，验证码 123456',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _passwordFields() => [
    TextFormField(
      key: const ValueKey('username'),
      controller: _username,
      decoration: const InputDecoration(
        hintText: '用户名',
        prefixIcon: Icon(Icons.person_outline_rounded),
      ),
      textInputAction: TextInputAction.next,
      validator: (v) => Validators.required(v, '用户名'),
    ),
    XGap.v16,
    TextFormField(
      key: const ValueKey('password'),
      controller: _password,
      decoration: InputDecoration(
        hintText: '密码',
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: IconButton(
          tooltip: _obscure ? '显示密码' : '隐藏密码',
          icon: Icon(
            _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            size: 20,
          ),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
      obscureText: _obscure,
      onFieldSubmitted: (_) => _submit(),
      validator: (v) => Validators.required(v, '密码'),
    ),
  ];

  List<Widget> _smsFields() => [
    TextFormField(
      key: const ValueKey('phone'),
      controller: _phone,
      decoration: const InputDecoration(
        hintText: '手机号',
        prefixIcon: Icon(Icons.phone_iphone_rounded),
      ),
      keyboardType: TextInputType.phone,
      inputFormatters: InputFormats.phone,
      textInputAction: TextInputAction.next,
      validator: Validators.phone,
    ),
    XGap.v16,
    TextFormField(
      key: const ValueKey('code'),
      controller: _code,
      decoration: InputDecoration(
        hintText: '验证码',
        prefixIcon: const Icon(Icons.verified_user_outlined),
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 4),
          child: XCountdownButton(onSend: _sendCode),
        ),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [InputFormats.digits, LengthLimitingTextInputFormatter(6)],
      onFieldSubmitted: (_) => _submit(),
      validator: (v) => Validators.required(v, '验证码'),
    ),
  ];
}

/// 登录方式切换：灰底胶囊里两个选项，选中的那个是白色滑块。
class _ModeSwitch extends StatelessWidget {
  const _ModeSwitch({required this.mode, required this.onChanged});

  final _LoginMode mode;
  final ValueChanged<_LoginMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.xColors;
    Widget segment(_LoginMode value, String label) {
      final selected = value == mode;
      return Expanded(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onChanged(value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? c.card : Colors.transparent,
              borderRadius: BorderRadius.circular(9),
              boxShadow: selected
                  ? const [BoxShadow(color: Color(0x14000000), blurRadius: 6, offset: Offset(0, 1))]
                  : null,
            ),
            child: XText.body(
              label,
              weight: selected ? FontWeights.semibold : FontWeights.regular,
              color: selected ? c.text : c.textSecondary,
            ),
          ),
        ),
      );
    }

    return XContainer(
      padding: const XPad.all(3),
      radius: 12,
      color: c.fill,
      child: Row(
        children: [segment(_LoginMode.password, '密码登录'), segment(_LoginMode.sms, '验证码登录')],
      ),
    );
  }
}
