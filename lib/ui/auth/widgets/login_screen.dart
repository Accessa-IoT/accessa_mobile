import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:accessa_mobile/ui/auth/view_model/login_view_model.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(),
      child: const _LoginContent(),
    );
  }
}

class _LoginContent extends StatefulWidget {
  const _LoginContent();

  @override
  State<_LoginContent> createState() => _LoginContentState();
}

class _LoginContentState extends State<_LoginContent> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    final vm = context.read<LoginViewModel>();
    vm.login(
      _email.text.trim(),
      _password.text,
      onSuccess: () {
        if (!mounted) return;
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/devices', (route) => false);
      },
      onError: (msg) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      },
    );
  }

  Future<void> _forgot(BuildContext context) async {
    final ctrl = TextEditingController(text: _email.text.trim());
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Recuperar senha'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: 'E-mail'),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Enviar'),
          ),
        ],
      ),
    );

    if (ok == true && mounted) {
      final vm = context.read<LoginViewModel>();
      vm.forgotPassword(
        ctrl.text,
        onSuccess: () {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Link de recuperação enviado (demo)')),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LoginViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Entrar')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextFormField(
              key: const Key('email_field'),
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'E-mail',
                prefixIcon: Icon(Icons.email),
              ),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Informe seu e-mail' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('password_field'),
              controller: _password,
              obscureText: vm.obscure,
              decoration: InputDecoration(
                labelText: 'Senha',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    vm.obscure ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: vm.toggleObscure,
                ),
              ),
              validator: (v) =>
                  (v == null || v.length < 6) ? 'Senha inválida' : null,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Switch(
                  key: const Key('remember_switch'),
                  value: vm.remember,
                  onChanged: vm.setRemember,
                ),
                const Text('Lembrar de mim'),
                const Spacer(),
                TextButton(
                  key: const Key('forgot_password_button'),
                  onPressed: () => _forgot(context),
                  child: const Text('Esqueci a senha'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              key: const Key('login_button'),
              icon: vm.loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.login),
              label: Text(vm.loading ? 'Entrando...' : 'Entrar'),
              onPressed: vm.loading ? null : () => _submit(context),
            ),
          ],
        ),
      ),
    );
  }
}
