import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:accessa_mobile/data/services/storage.dart';
import 'package:accessa_mobile/data/services/auth_service.dart';

void main() {
  group('AuthService', () {
    setUp(() async {
      // start each test with a fresh mocked SharedPreferences
      SharedPreferences.setMockInitialValues(<String, Object>{});
      await Storage.init();
    });

    test('register succeeds and sets logged/email', () async {
      await AuthService.register('Alice', 'alice@example.com', 'secret');

      final users = Storage.getJsonList('auth.users');
      expect(users, isNotNull);
      expect(users!.length, 1);
      final u = Map<String, dynamic>.from(users[0] as Map);
      expect(u['email'], 'alice@example.com');

      expect(AuthService.isLoggedIn(), isTrue);
      expect(AuthService.currentEmail(), 'alice@example.com');
    });

    test('register throws on duplicate email', () async {
      final existing = [
        {'name': 'Bob', 'email': 'bob@example.com', 'password': 'pass123'}
      ];
      SharedPreferences.setMockInitialValues(
          {'auth.users': jsonEncode(existing)});
      await Storage.init();

      expect(() async {
        await AuthService.register('Bobby', 'bob@example.com', 'another');
      }, throwsA(isA<Exception>()));
    });

    test('register validations: empty name / invalid email / short password', () async {
      expect(() async {
        await AuthService.register('', 'a@b.com', 'secret');
      }, throwsA(isA<Exception>()));

      expect(() async {
        await AuthService.register('Name', 'invalid-email', 'secret');
      }, throwsA(isA<Exception>()));

      expect(() async {
        await AuthService.register('Name', 'n@example.com', '123');
      }, throwsA(isA<Exception>()));
    });

    test('login success stores logged and email when remember=true', () async {
      final users = [
        {'name': 'Carol', 'email': 'carol@example.com', 'password': 'pwd1234'}
      ];
      SharedPreferences.setMockInitialValues({'auth.users': jsonEncode(users)});
      await Storage.init();

      await AuthService.login('carol@example.com', 'pwd1234');
      expect(AuthService.isLoggedIn(), isTrue);
      expect(AuthService.currentEmail(), 'carol@example.com');
    });

    test('login throws when user not found or wrong password', () async {
      // no users
      expect(() async {
        await AuthService.login('noone@example.com', 'x');
      }, throwsA(isA<Exception>()));

      // wrong password
      final users = [
        {'name': 'Dan', 'email': 'dan@example.com', 'password': 'rightpass'}
      ];
      SharedPreferences.setMockInitialValues({'auth.users': jsonEncode(users)});
      await Storage.init();

      expect(() async {
        await AuthService.login('dan@example.com', 'wrong');
      }, throwsA(isA<Exception>()));
    });

    test('logout clears logged flag', () async {
      SharedPreferences.setMockInitialValues({'auth.logged': true});
      await Storage.init();

      expect(AuthService.isLoggedIn(), isTrue);
      await AuthService.logout();
      expect(AuthService.isLoggedIn(), isFalse);
    });
  });
}
