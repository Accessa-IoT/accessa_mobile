import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:accessa_mobile/data/services/storage.dart';
import 'package:accessa_mobile/ui/auth/view_model/login_view_model.dart';

void main() {
  group('LoginViewModel', () {
    late LoginViewModel vm;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await Storage.init();
      vm = LoginViewModel();
    });

    test('initial state is correct', () {
      expect(vm.loading, isFalse);
      expect(vm.obscure, isTrue);
      expect(vm.remember, isTrue);
    });

    test('toggleObscure toggles the obscure flag', () {
      vm.toggleObscure();
      expect(vm.obscure, isFalse);
      vm.toggleObscure();
      expect(vm.obscure, isTrue);
    });

    test('setRemember updates the remember flag', () {
      vm.setRemember(false);
      expect(vm.remember, isFalse);
      vm.setRemember(true);
      expect(vm.remember, isTrue);
    });

    test('login success calls onSuccess', () async {
      // Arrange: Create a user in storage
      final users = [
        {'name': 'Test', 'email': 'test@example.com', 'password': 'password'},
      ];
      SharedPreferences.setMockInitialValues({'auth.users': jsonEncode(users)});
      await Storage.init();

      bool successCalled = false;

      // Act
      await vm.login(
        'test@example.com',
        'password',
        onSuccess: () => successCalled = true,
        onError: (_) {},
      );

      // Assert
      expect(successCalled, isTrue);
      expect(vm.loading, isFalse);
    });

    test('login failure calls onError', () async {
      bool errorCalled = false;
      String? errorMessage;

      // Act
      await vm.login(
        'wrong@example.com',
        'password',
        onSuccess: () {},
        onError: (msg) {
          errorCalled = true;
          errorMessage = msg;
        },
      );

      // Assert
      expect(errorCalled, isTrue);
      expect(errorMessage, contains('Usuário não encontrado'));
      expect(vm.loading, isFalse);
    });

    test('forgotPassword calls onSuccess', () async {
      bool successCalled = false;
      await vm.forgotPassword(
        'test@example.com',
        onSuccess: () => successCalled = true,
      );
      expect(successCalled, isTrue);
    });
  });
}
