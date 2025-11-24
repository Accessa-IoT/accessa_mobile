import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:accessa_mobile/main.dart';
import 'package:accessa_mobile/data/services/storage.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'auth.logged': false,
    });
    await Storage.init();

    await tester.pumpWidget(const AccessaApp());

    expect(find.text('Bem-vindo ao Accessa'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);

    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(find.text('E-mail'), findsOneWidget);
  });
}
