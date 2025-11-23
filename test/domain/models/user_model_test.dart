import 'package:flutter_test/flutter_test.dart';
import 'package:accessa_mobile/domain/models/user_model.dart';

void main() {
  group('User Model', () {
    test('fromJson creates a valid User object', () {
      final json = {
        'name': 'Test User',
        'email': 'test@example.com',
        'password': 'password123',
      };

      final user = User.fromJson(json);

      expect(user.name, 'Test User');
      expect(user.email, 'test@example.com');
      expect(user.password, 'password123');
    });

    test('toJson creates a valid Map', () {
      final user = User(
        name: 'Test User',
        email: 'test@example.com',
        password: 'password123',
      );

      final json = user.toJson();

      expect(json['name'], 'Test User');
      expect(json['email'], 'test@example.com');
      expect(json['password'], 'password123');
    });

    test('toJson omits password if null', () {
      final user = User(name: 'Test User', email: 'test@example.com');

      final json = user.toJson();

      expect(json['name'], 'Test User');
      expect(json['email'], 'test@example.com');
      expect(json.containsKey('password'), isFalse);
    });
  });
}
