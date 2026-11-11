import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xjj_app_base/core/session/session.dart';
import 'package:xjj_app_base/features/auth/data/auth_repository.dart';
import 'package:xjj_app_base/shared/ui/ui.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  /// XButton 会在 Future 执行期间显示 loading，异常自动 toast
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    context.hideKeyboard();
    final token = await ref
        .read(authRepositoryProvider)
        .login(username: _username.text.trim(), password: _password.text);
    // 会话变化后，路由守卫会自动跳转，这里不需要手动 go
    await ref.read(sessionProvider.notifier).signIn(token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.xColors.card,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: XPad.all24,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const XText.headline('欢迎登录'),
                  XGap.v4,
                  const XText.caption('演示账号：任意用户名，密码 123456'),
                  XGap.v24,
                  TextFormField(
                    controller: _username,
                    decoration: const InputDecoration(
                      labelText: '用户名',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (v) => Validators.required(v, '用户名'),
                  ),
                  XGap.v16,
                  TextFormField(
                    controller: _password,
                    decoration: const InputDecoration(
                      labelText: '密码',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    obscureText: true,
                    onFieldSubmitted: (_) => _submit(),
                    validator: (v) => Validators.required(v, '密码'),
                  ),
                  XGap.v24,
                  XButton.primary('登录', block: true, onPressed: _submit),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
