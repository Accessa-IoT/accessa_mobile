import 'package:accessa_mobile/services/storage.dart';

class AuthService {
  static const _kLogged = 'auth.logged';
  static const _kEmail = 'auth.email';

  static bool isLoggedIn() => Storage.getBool(_kLogged);
  static String? currentEmail() => Storage.getJsonMap(_kEmail)?['email'];

  static Future<void> login(String email, String password, {bool remember = true}) async {
    if (email.isEmpty || password.length < 3) {
      throw Exception('Credenciais inválidas');
    }
    await Storage.setBool(_kLogged, true);
    if (remember) {
      await Storage.setJson(_kEmail, {'email': email});
    }
  }

  static Future<void> logout() async {
    await Storage.setBool(_kLogged, false);
  }

  static Future<void> forgotPassword(String email) async {
    // mock: simula envio de e-mail
    await Future.delayed(const Duration(milliseconds: 600));
  }
}
