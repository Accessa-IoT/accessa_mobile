import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _remember = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // TODO: chamar API de login, salvar token, etc.
      Navigator.pushReplacementNamed(context, '/devices');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Entrar')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextFormField(
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
              controller: _password,
              obscureText: _obscure,
              decoration: InputDecoration(
                labelText: 'Senha',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              validator: (v) =>
                  (v == null || v.length < 6) ? 'Senha inválida' : null,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Switch(
                  value: _remember,
                  onChanged: (v) => setState(() => _remember = v),
                ),
                const Text('Lembrar de mim'),
                const Spacer(),
                TextButton(
                  onPressed: () {/* TODO: recuperar senha */},
                  child: const Text('Esqueci a senha'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              icon: const Icon(Icons.login),
              label: const Text('Entrar'),
              onPressed: _submit,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.qr_code),
              label: const Text('Usar 2FA (TOTP)'),
              onPressed: () {
                // TODO: fluxo TOTP opcional
              },
            ),
          ],
        ),
      ),
    );
  }
}
