import 'package:accessa_mobile/data/services/storage.dart';

class AuthService {
  static const _kLogged = 'auth.logged';
  static const _kEmail = 'auth.email'; // guarda {'email': '...'}
  static const _kUsers = 'auth.users'; // lista: [{name, email, password}]

  static String _normalizeEmail(String email) => email.trim().toLowerCase();

  // Sessão atual
  static bool isLoggedIn() => Storage.getBool(_kLogged);

  static String? currentEmail() {
    final m = Storage.getJsonMap(_kEmail);
    return m == null ? null : (m['email'] as String?);
  }

  // Usuários
  static List<Map<String, dynamic>> _loadUsers() {
    final raw = Storage.getJsonList(_kUsers) ?? [];
    return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  static Future<void> _saveUsers(List<Map<String, dynamic>> users) async {
    await Storage.setJson(_kUsers, users);
  }

  // Cadastro (com verificação de duplicidade de e-mail)
  static Future<void> register(
    String name,
    String email,
    String password,
  ) async {
    final e = _normalizeEmail(email);
    if (name.trim().isEmpty) {
      throw Exception('Informe seu nome.');
    }
    if (!e.contains('@') || !e.contains('.')) {
      throw Exception('E-mail inválido.');
    }
    if (password.length < 6) {
      throw Exception('A senha deve ter pelo menos 6 caracteres.');
    }

    final users = _loadUsers();
    final exists = users.any((u) => (u['email'] as String).toLowerCase() == e);
    if (exists) {
      throw Exception('E-mail já cadastrado.');
    }

    users.add({
      'name': name.trim(),
      'email': e,
      'password': password,
    }); // DEMO: senha em claro
    await _saveUsers(users);

    // auto-login
    await Storage.setBool(_kLogged, true);
    await Storage.setJson(_kEmail, {'email': e});
  }

  // Login
  static Future<void> login(
    String email,
    String password, {
    bool remember = true,
  }) async {
    final e = _normalizeEmail(email);
    final users = _loadUsers();

    Map<String, dynamic>? user;
    for (final u in users) {
      if ((u['email'] as String).toLowerCase() == e) {
        user = u;
        break;
      }
    }

    if (user == null) {
      throw Exception('Usuário não encontrado. Crie uma conta.');
    }
    if ((user['password'] as String) != password) {
      throw Exception('Senha incorreta.');
    }

    await Storage.setBool(_kLogged, true);
    if (remember) {
      await Storage.setJson(_kEmail, {'email': e});
    }
  }

  static Future<void> logout() async {
    await Storage.setBool(_kLogged, false);
  }

  static Future<void> forgotPassword(String email) async {
    // Mock: simula envio de e-mail de recuperação
    await Future.delayed(const Duration(milliseconds: 600));
  }
}
