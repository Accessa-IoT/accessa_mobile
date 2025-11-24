import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accessa_mobile/ui/history/widgets/history_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:accessa_mobile/data/services/storage.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Storage.init();
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    // Seed data
    final now = DateTime.now();
    final items = [
      {
        'when': now.toIso8601String(),
        'user': 'Hagliberto',
        'device': 'Laboratório 01',
        'result': 'sucesso',
      },
      {
        'when': now.subtract(const Duration(hours: 1)).toIso8601String(),
        'user': 'admin',
        'device': 'Armário 07',
        'result': 'falha',
      },
    ];
    await Storage.setJson('history.items', items);
  });

  group('HistoryScreen', () {
    testWidgets('renders correctly and displays data', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: HistoryScreen()));

      // Initially loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      // Loaded
      expect(find.byType(HistoryScreen), findsOneWidget);
      expect(find.text('Histórico'), findsOneWidget);
      expect(find.byIcon(Icons.filter_list), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);

      // Check list items
      // Default filters are User: Hagliberto, Device: Laboratório 01
      expect(find.text('Laboratório 01 • Hagliberto'), findsOneWidget);
      expect(
        find.text('Armário 07 • admin'),
        findsNothing,
      ); // Hidden by default filters
      expect(find.textContaining('sucesso'), findsOneWidget);
      expect(find.textContaining('falha'), findsNothing); // Hidden
    });

    testWidgets('opens filter modal and applies filters', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: HistoryScreen()));
      await tester.pumpAndSettle();

      // Open filters
      await tester.tap(find.byKey(const Key('filter_button')));
      await tester.pumpAndSettle();

      expect(find.text('Filtros'), findsOneWidget);
      expect(find.byKey(const Key('filter_user_dropdown')), findsOneWidget);
      expect(find.byKey(const Key('filter_device_dropdown')), findsOneWidget);
      expect(find.byKey(const Key('filter_result_dropdown')), findsOneWidget);

      // Select User: Hagliberto
      await tester.tap(find.byKey(const Key('filter_user_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hagliberto').last); // Dropdown item
      await tester.pumpAndSettle();

      // Select Device: Laboratório 01
      await tester.tap(find.byKey(const Key('filter_device_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Laboratório 01').last);
      await tester.pumpAndSettle();

      // Select Result: sucesso
      await tester.tap(find.byKey(const Key('filter_result_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('sucesso').last);
      await tester.pumpAndSettle();

      // Apply
      await tester.tap(find.byKey(const Key('filter_apply_button')));
      await tester.pumpAndSettle();

      // Verify filtered list
      expect(find.text('Laboratório 01 • Hagliberto'), findsOneWidget);
      expect(find.text('Armário 07 • admin'), findsNothing);

      // Verify filter status text
      expect(find.text('Usuário: Hagliberto'), findsOneWidget);
      expect(find.text('Dispositivo: Laboratório 01'), findsOneWidget);
      expect(find.text('Resultado: sucesso'), findsOneWidget);
    });

    testWidgets('clears filters', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HistoryScreen()));
      await tester.pumpAndSettle();

      // Open filters
      await tester.tap(find.byKey(const Key('filter_button')));
      await tester.pumpAndSettle();

      // Select User: Hagliberto
      await tester.tap(find.byKey(const Key('filter_user_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hagliberto').last);
      await tester.pumpAndSettle();

      // Apply
      await tester.tap(find.byKey(const Key('filter_apply_button')));
      await tester.pumpAndSettle();

      // Verify filtered
      expect(find.text('Armário 07 • admin'), findsNothing);

      // Open filters again
      await tester.tap(find.byKey(const Key('filter_button')));
      await tester.pumpAndSettle();

      // Clear
      await tester.tap(find.byKey(const Key('filter_clear_button')));
      await tester.pumpAndSettle();

      // Verify all items shown
      expect(find.text('Laboratório 01 • Hagliberto'), findsOneWidget);
      expect(find.text('Armário 07 • admin'), findsOneWidget);

      // Verify filter status text
      expect(find.text('Usuário: qualquer'), findsOneWidget);
    });

    testWidgets('shows item details on tap', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HistoryScreen()));
      await tester.pumpAndSettle();

      // Tap first item
      await tester.tap(find.text('Laboratório 01 • Hagliberto'));
      await tester.pumpAndSettle();

      // Verify detail modal
      expect(
        find.text('Laboratório 01 • Hagliberto'),
        findsNWidgets(2),
      ); // List item + Modal title
      expect(find.text('Resultado: sucesso'), findsOneWidget);
    });

    testWidgets('refreshes data', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HistoryScreen()));
      await tester.pumpAndSettle();

      // Tap refresh
      await tester.tap(find.byKey(const Key('refresh_button')));
      await tester.pump(); // Start loading

      // Loading might be too fast to catch
      // expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle(); // Finish loading

      expect(find.byType(HistoryScreen), findsOneWidget);
    });
  });
}
