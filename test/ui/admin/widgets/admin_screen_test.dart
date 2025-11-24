import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accessa_mobile/ui/admin/widgets/admin_screen.dart';

void main() {
  group('AdminScreen', () {
    testWidgets('creates widget successfully', (WidgetTester tester) async {
      // Create the widget
      const widget = AdminScreen();

      // Verify it can be created
      expect(widget, isNotNull);
      expect(widget, isA<StatelessWidget>());
    });

    testWidgets('renders Scaffold with AppBar and body', (
      WidgetTester tester,
    ) async {
      // Build the widget
      await tester.pumpWidget(const MaterialApp(home: AdminScreen()));

      // Verify Scaffold is rendered
      expect(find.byType(Scaffold), findsOneWidget);

      // Verify AppBar is rendered
      expect(find.byType(AppBar), findsOneWidget);

      // Verify Center widget is in the body
      expect(find.byType(Center), findsOneWidget);
    });

    testWidgets('displays correct AppBar title', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(const MaterialApp(home: AdminScreen()));

      // Verify AppBar title
      expect(find.text('Admin'), findsOneWidget);

      // Verify the title is in the AppBar
      final appBarFinder = find.byType(AppBar);
      expect(
        find.descendant(of: appBarFinder, matching: find.text('Admin')),
        findsOneWidget,
      );
    });

    testWidgets('displays correct body text', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(const MaterialApp(home: AdminScreen()));

      // Verify body text
      expect(find.text('Admin Screen (Restored)'), findsOneWidget);

      // Verify the text is centered
      final centerFinder = find.byType(Center);
      expect(
        find.descendant(
          of: centerFinder,
          matching: find.text('Admin Screen (Restored)'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('has correct widget structure', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(const MaterialApp(home: AdminScreen()));

      // Verify the complete widget tree structure
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(AdminScreen), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(Center), findsOneWidget);
      expect(find.byType(Text), findsNWidgets(2)); // AppBar title + body text
    });
  });
}
