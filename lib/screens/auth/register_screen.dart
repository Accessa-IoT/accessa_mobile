import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // TODO: chamar API de cadastro
      Navigator.pop(context); // volta pro login/home
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar conta')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'Nome completo',
                prefixIcon: Icon(Icons.person),
              ),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Informe seu nome' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _email,
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
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Senha',
                prefixIcon: Icon(Icons.lock),
              ),
              validator: (v) =>
                  (v == null || v.length < 6) ? 'Mínimo 6 caracteres' : null,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              icon: const Icon(Icons.check),
              label: const Text('Cadastrar'),
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
