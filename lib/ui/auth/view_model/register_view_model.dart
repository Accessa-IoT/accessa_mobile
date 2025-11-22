import 'package:flutter/material.dart';
import 'package:accessa_mobile/data/services/auth_service.dart';

class RegisterViewModel extends ChangeNotifier {
  bool _loading = false;

  bool get loading => _loading;

  Future<void> register(String name, String email, String password, {required VoidCallback onSuccess, required Function(String) onError}) async {
    _loading = true;
    notifyListeners();

    try {
      await AuthService.register(name, email, password);
      onSuccess();
    } catch (e) {
      onError(e.toString());
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
