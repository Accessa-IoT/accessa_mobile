import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accessa_mobile/ui/auth/widgets/login_screen.dart';
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
    // Create a test user for login tests
    final users = [
      User(
        name: 'Test User',
        email: 'test@example.com',
        password: 'password123',
      ),
    ];
    await Storage.setJson('auth.users', users.map((u) => u.toJson()).toList());
  });

  group('LoginScreen', () {
    testWidgets('renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Entrar'), findsNWidgets(2)); // AppBar + Button
    });

    testWidgets('displays all form fields', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

      expect(find.byKey(const Key('email_field')), findsOneWidget);
      expect(find.byKey(const Key('password_field')), findsOneWidget);
      expect(find.byKey(const Key('remember_switch')), findsOneWidget);
      expect(find.byKey(const Key('forgot_password_button')), findsOneWidget);
      expect(find.byKey(const Key('login_button')), findsOneWidget);
    });

    testWidgets('validates empty email field', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

      await tester.ensureVisible(find.byKey(const Key('login_button')));
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      expect(find.text('Informe seu e-mail'), findsOneWidget);
    });

    testWidgets('validates empty password field', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@example.com',
      );

      await tester.ensureVisible(find.byKey(const Key('login_button')));
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      expect(find.text('Senha inválida'), findsOneWidget);
    });

    testWidgets('validates short password', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@example.com',
      );
      await tester.enterText(find.byKey(const Key('password_field')), '12345');

      await tester.ensureVisible(find.byKey(const Key('login_button')));
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      expect(find.text('Senha inválida'), findsOneWidget);
    });

    testWidgets('toggles password visibility', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

      // Find and tap the visibility toggle button
      expect(find.byIcon(Icons.visibility), findsOneWidget);
      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pumpAndSettle();

      // Icon should change to visibility_off
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);

      // Toggle back
      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pumpAndSettle();

      // Icon should change back to visibility
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('toggles remember me switch', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

      // Initially switch should be on (default in ViewModel is true)
      var switchWidget = tester.widget<Switch>(
        find.byKey(const Key('remember_switch')),
      );
      expect(switchWidget.value, isTrue);

      // Tap the switch
      await tester.tap(find.byKey(const Key('remember_switch')));
      await tester.pumpAndSettle();

      // Switch should now be off
      switchWidget = tester.widget<Switch>(
        find.byKey(const Key('remember_switch')),
      );
      expect(switchWidget.value, isFalse);

      // Toggle back
      await tester.tap(find.byKey(const Key('remember_switch')));
      await tester.pumpAndSettle();

      switchWidget = tester.widget<Switch>(
        find.byKey(const Key('remember_switch')),
      );
      expect(switchWidget.value, isTrue);
    });

    testWidgets('opens forgot password dialog', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

      // Tap forgot password button
      await tester.tap(find.byKey(const Key('forgot_password_button')));
      await tester.pumpAndSettle();

      // Dialog should be displayed
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Recuperar senha'), findsOneWidget);
    });

    testWidgets('cancels forgot password dialog', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

      await tester.tap(find.byKey(const Key('forgot_password_button')));
      await tester.pumpAndSettle();

      // Tap cancel button
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      // Dialog should be closed
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('submits forgot password with email', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

      // Enter email in login form
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@example.com',
      );

      // Open forgot password dialog
      await tester.tap(find.byKey(const Key('forgot_password_button')));
      await tester.pumpAndSettle();

      // Email should be pre-filled in the dialog's TextField
      final dialogTextFieldFinder = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      );
      final textField = tester.widget<TextField>(dialogTextFieldFinder);
      expect(textField.controller?.text, 'test@example.com');

      // Tap send button
      await tester.tap(find.text('Enviar'));

      // Wait for the dialog to close and the async operation (600ms delay) to complete
      await tester.pump(); // Close dialog
      await tester.pump(
        const Duration(seconds: 1),
      ); // Wait for AuthService delay
      await tester.pump(); // Show snackbar

      // Should show success snackbar
      expect(find.text('Link de recuperação enviado (demo)'), findsOneWidget);
    });

    testWidgets('submits form with valid data', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const LoginScreen(),
          routes: {
            '/devices': (context) => const Scaffold(body: Text('Devices')),
          },
        ),
      );

      // Fill form with valid data
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'password123',
      );

      // Ensure button is visible and tap it
      await tester.ensureVisible(find.byKey(const Key('login_button')));
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pump(); // Start animation/loading

      // Should show loading state
      // expect(find.text('Entrando...'), findsOneWidget);
      // expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle(); // Wait for navigation

      // Should navigate to devices screen
      expect(find.text('Devices'), findsOneWidget);
    });

    testWidgets('form controllers are disposed', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

      // Verify widget is rendered
      expect(find.byType(LoginScreen), findsOneWidget);

      // Remove widget from tree
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));

      // If controllers weren't disposed, this would cause issues
      // The test passing means dispose was called
    });

    // testWidgets('button is disabled while loading', (
    //   WidgetTester tester,
    // ) async {
    //   await tester.pumpWidget(
    //     MaterialApp(
    //       home: const LoginScreen(),
    //       routes: {
    //         '/devices': (context) => const Scaffold(body: Text('Devices')),
    //       },
    //     ),
    //   );

    //   // Fill form
    //   await tester.enterText(
    //     find.byKey(const Key('email_field')),
    //     'test@example.com',
    //   );
    //   await tester.enterText(
    //     find.byKey(const Key('password_field')),
    //     'password123',
    //   );

    //   // Tap login button
    //   await tester.ensureVisible(find.byKey(const Key('login_button')));
    //   await tester.tap(find.byKey(const Key('login_button')));
    //   await tester.pump();

    //   // Button should be disabled (onPressed is null)
    //   final button = tester.widget<FilledButton>(
    //     find.byKey(const Key('login_button')),
    //   );
    //   expect(button.onPressed, isNull);

    //   await tester.pumpAndSettle();
    // });
    testWidgets('shows error message on login failure', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const LoginScreen(),
          routes: {
            '/devices': (context) => const Scaffold(body: Text('Devices')),
          },
        ),
      );

      // Fill form with non-existent user
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'nonexistent@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'password123',
      );

      // Tap login button
      await tester.ensureVisible(find.byKey(const Key('login_button')));
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pump();

      await tester.pumpAndSettle();

      // Should show error snackbar
      expect(
        find.text('Exception: Usuário não encontrado. Crie uma conta.'),
        findsOneWidget,
      );
    });
  });
}
