import 'package:flutter/material.dart';
import 'package:accessa_mobile/data/services/auth_service.dart';

class LoginViewModel extends ChangeNotifier {
  bool _loading = false;
  bool _obscure = true;
  bool _remember = true;

  bool get loading => _loading;
  bool get obscure => _obscure;
  bool get remember => _remember;

  void toggleObscure() {
    _obscure = !_obscure;
    notifyListeners();
  }

  void setRemember(bool value) {
    _remember = value;
    notifyListeners();
  }

  Future<void> login(String email, String password, {required VoidCallback onSuccess, required Function(String) onError}) async {
    _loading = true;
    notifyListeners();

    try {
      await AuthService.login(email, password, remember: _remember);
      onSuccess();
    } catch (e) {
      onError(e.toString());
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
  
  Future<void> forgotPassword(String email, {required VoidCallback onSuccess}) async {
     try {
      await AuthService.forgotPassword(email);
      onSuccess();
    } catch (e) {

    }
  }
}
