
// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget tree,
// read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:accessa_mobile/main.dart';
import 'package:accessa_mobile/data/services/storage.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Prepare a mocked SharedPreferences and initialize Storage used by AuthService
    SharedPreferences.setMockInitialValues(<String, Object>{'auth.logged': false});
    await Storage.init();

    // Build our app and trigger a frame.
    await tester.pumpWidget(const AccessaApp());

  // Verify HomeScreen content is shown
  expect(find.text('Bem-vindo ao Accessa'), findsOneWidget);
  expect(find.text('Entrar'), findsOneWidget);

  // Tap the 'Entrar' button and wait for navigation to LoginScreen
  await tester.tap(find.text('Entrar'));
  await tester.pumpAndSettle();

  // On the login screen we should see the email field label
  expect(find.text('E-mail'), findsOneWidget);
  });
}
