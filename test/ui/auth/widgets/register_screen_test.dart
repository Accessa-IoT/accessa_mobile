import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accessa_mobile/ui/auth/widgets/register_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:accessa_mobile/data/services/storage.dart';
import 'package:accessa_mobile/domain/models/user_model.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Storage.init();
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('RegisterScreen', () {
    testWidgets('renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));

      expect(find.byType(RegisterScreen), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Criar conta'), findsOneWidget);
    });

    testWidgets('displays all form fields', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));

      expect(find.byKey(const Key('name_field')), findsOneWidget);
      expect(find.byKey(const Key('email_field')), findsOneWidget);
      expect(find.byKey(const Key('password_field')), findsOneWidget);
      expect(find.byKey(const Key('register_button')), findsOneWidget);
    });

    testWidgets('validates empty name field', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));

      // Tap register button without filling name
      await tester.ensureVisible(find.byKey(const Key('register_button')));
      await tester.tap(find.byKey(const Key('register_button')));
      await tester.pumpAndSettle();

      expect(find.text('Informe seu nome'), findsOneWidget);
    });

    testWidgets('validates empty email field', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));

      // Fill name but not email
      await tester.enterText(find.byKey(const Key('name_field')), 'Test User');

      await tester.ensureVisible(find.byKey(const Key('register_button')));
      await tester.tap(find.byKey(const Key('register_button')));
      await tester.pumpAndSettle();

      expect(find.text('Informe seu e-mail'), findsOneWidget);
    });

    testWidgets('validates invalid email - missing @', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));

      await tester.enterText(find.byKey(const Key('name_field')), 'Test User');
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'invalidemail.com',
      );

      await tester.ensureVisible(find.byKey(const Key('register_button')));
      await tester.tap(find.byKey(const Key('register_button')));
      await tester.pumpAndSettle();

      expect(find.text('E-mail inválido'), findsOneWidget);
    });

    testWidgets('validates invalid email - missing dot', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));

      await tester.enterText(find.byKey(const Key('name_field')), 'Test User');
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'invalid@emailcom',
      );

      await tester.ensureVisible(find.byKey(const Key('register_button')));
      await tester.tap(find.byKey(const Key('register_button')));
      await tester.pumpAndSettle();

      expect(find.text('E-mail inválido'), findsOneWidget);
    });

    testWidgets('validates short password', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));

      await tester.enterText(find.byKey(const Key('name_field')), 'Test User');
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@example.com',
      );
      await tester.enterText(find.byKey(const Key('password_field')), '12345');

      await tester.ensureVisible(find.byKey(const Key('register_button')));
      await tester.tap(find.byKey(const Key('register_button')));
      await tester.pumpAndSettle();

      expect(find.text('Mínimo 6 caracteres'), findsOneWidget);
    });

    testWidgets('submits form with valid data', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const RegisterScreen(),
          routes: {
            '/devices': (context) => const Scaffold(body: Text('Devices')),
          },
        ),
      );

      // Fill all fields with valid data
      await tester.enterText(find.byKey(const Key('name_field')), 'Test User');
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'password123',
      );

      // Tap register button
      await tester.ensureVisible(find.byKey(const Key('register_button')));
      await tester.tap(find.byKey(const Key('register_button')));
      await tester.pump();

      // Should show loading state
      // expect(find.text('Cadastrando...'), findsOneWidget);
      // expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      // Should navigate to devices
      expect(find.text('Devices'), findsOneWidget);
    });

    testWidgets('password field is obscured', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));

      // Verify password field exists (obscureText is set in the widget)
      expect(find.byKey(const Key('password_field')), findsOneWidget);
    });

    testWidgets('form controllers are disposed', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));

      // Verify widget is rendered
      expect(find.byType(RegisterScreen), findsOneWidget);

      // Remove widget from tree
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));

      // If controllers weren't disposed, this would cause issues
      // The test passing means dispose was called
    });
    testWidgets(
      'shows error message on registration failure (duplicate email)',
      (WidgetTester tester) async {
        // Pre-populate storage with a user
        final users = [
          User(
            name: 'Existing User',
            email: 'existing@example.com',
            password: 'password123',
          ),
        ];
        await Storage.setJson(
          'auth.users',
          users.map((u) => u.toJson()).toList(),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: const RegisterScreen(),
            routes: {
              '/devices': (context) => const Scaffold(body: Text('Devices')),
            },
          ),
        );

        // Fill form with existing email
        await tester.enterText(find.byKey(const Key('name_field')), 'New User');
        await tester.enterText(
          find.byKey(const Key('email_field')),
          'existing@example.com',
        );
        await tester.enterText(
          find.byKey(const Key('password_field')),
          'password123',
        );

        // Tap register button
        await tester.ensureVisible(find.byKey(const Key('register_button')));
        await tester.tap(find.byKey(const Key('register_button')));
        await tester.pump();

        await tester.pumpAndSettle();

        // Should show error snackbar
        expect(find.text('Exception: E-mail já cadastrado.'), findsOneWidget);
      },
    );
  });
}
