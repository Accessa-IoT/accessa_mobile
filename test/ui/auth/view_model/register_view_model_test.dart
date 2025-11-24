import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:accessa_mobile/data/services/storage.dart';
import 'package:accessa_mobile/ui/auth/view_model/register_view_model.dart';

void main() {
  group('RegisterViewModel', () {
    late RegisterViewModel vm;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await Storage.init();
      vm = RegisterViewModel();
    });

    test('initial state is correct', () {
      expect(vm.loading, isFalse);
    });

    test('register success calls onSuccess', () async {
      bool successCalled = false;

      // Act
      await vm.register(
        'New User',
        'new@example.com',
        'password123',
        onSuccess: () => successCalled = true,
        onError: (_) {},
      );

      // Assert
      expect(successCalled, isTrue);
      expect(vm.loading, isFalse);

      // Verify user was created
      final users = Storage.getJsonList('auth.users');
      expect(users, isNotNull);
      expect(users!.length, 1);
      expect(users[0]['email'], 'new@example.com');
    });

    test('register failure calls onError', () async {
      // Arrange: Create existing user
      final users = [
        {
          'name': 'Existing',
          'email': 'existing@example.com',
          'password': 'pass',
        },
      ];
      SharedPreferences.setMockInitialValues({'auth.users': jsonEncode(users)});
      await Storage.init();

      bool errorCalled = false;
      String? errorMessage;

      // Act
      await vm.register(
        'Another',
        'existing@example.com', // Duplicate email
        'password123',
        onSuccess: () {},
        onError: (msg) {
          errorCalled = true;
          errorMessage = msg;
        },
      );

      // Assert
      expect(errorCalled, isTrue);
      expect(errorMessage, contains('já cadastrado'));
      expect(vm.loading, isFalse);
    });
  });
}
