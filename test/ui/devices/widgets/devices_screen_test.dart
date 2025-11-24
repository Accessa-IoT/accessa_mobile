import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:accessa_mobile/ui/devices/widgets/devices_screen.dart';
import 'package:accessa_mobile/data/services/storage.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await Storage.init();
  });

  Widget createWidget() {
    return const MaterialApp(home: DevicesScreen());
  }

  testWidgets('renders correctly with loading state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidget());

    // Should show loading initially
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Dispositivos'), findsOneWidget);
  });

  testWidgets('displays default devices when storage is empty', (
    WidgetTester tester,
  ) async {
    // When storage is empty, DeviceService loads defaults
    await tester.pumpWidget(createWidget());
    await tester.pumpAndSettle();

    // Should show default devices
    expect(find.text('Laboratório 01'), findsOneWidget);
    expect(find.text('Cowork Sala A'), findsOneWidget);
    expect(find.text('Armário 07'), findsOneWidget);
  });

  testWidgets('displays device list with data', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'devices.items': '''[
        {"id": "dev-101", "name": "Laboratório 01", "status": "online"},
        {"id": "dev-102", "name": "Cowork Sala A", "status": "offline"}
      ]''',
    });
    await Storage.init();

    await tester.pumpWidget(createWidget());
    await tester.pumpAndSettle();

    expect(find.text('Laboratório 01'), findsOneWidget);
    expect(find.text('ID: dev-101'), findsOneWidget);

    expect(find.text('Cowork Sala A'), findsOneWidget);
    expect(find.text('ID: dev-102'), findsOneWidget);

    // Check for online and offline icons
    expect(find.byIcon(Icons.cloud_done), findsOneWidget); // online
    expect(find.byIcon(Icons.cloud_off), findsOneWidget); // offline
  });

  testWidgets('navigates to device detail on tap', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'devices.items': '''[
        {"id": "dev-101", "name": "Laboratório 01", "status": "online"}
      ]''',
    });

    await tester.pumpWidget(
      MaterialApp(
        routes: {
          '/': (_) => const DevicesScreen(),
          '/device_detail': (context) {
            final args =
                ModalRoute.of(context)!.settings.arguments
                    as Map<String, String>;
            return Scaffold(body: Text('Detail: ${args['name']}'));
          },
        },
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Laboratório 01'));
    await tester.pumpAndSettle();

    expect(find.text('Detail: Laboratório 01'), findsOneWidget);
  });

  testWidgets('navigates to MQTT screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'devices.items': '[]'});

    await tester.pumpWidget(
      MaterialApp(
        routes: {
          '/': (_) => const DevicesScreen(),
          '/mqtt': (_) => const Scaffold(body: Text('MQTT Screen')),
        },
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Testar Conexão MQTT'));
    await tester.pumpAndSettle();

    expect(find.text('MQTT Screen'), findsOneWidget);
  });

  testWidgets('navigates to MQTT Diag screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'devices.items': '[]'});

    await tester.pumpWidget(
      MaterialApp(
        routes: {
          '/': (_) => const DevicesScreen(),
          '/mqtt_diag': (_) => const Scaffold(body: Text('MQTT Diag Screen')),
        },
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Diagnóstico MQTT'));
    await tester.pumpAndSettle();

    expect(find.text('MQTT Diag Screen'), findsOneWidget);
  });

  testWidgets('navigates via popup menu to home', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'devices.items': '[]'});

    await tester.pumpWidget(
      MaterialApp(
        routes: {
          '/': (_) => const Scaffold(body: Text('Home Screen')),
          '/devices': (_) => const DevicesScreen(),
        },
        initialRoute: '/devices',
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();

    expect(find.text('Home Screen'), findsOneWidget);
  });

  testWidgets('navigates via popup menu to history', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({'devices.items': '[]'});

    await tester.pumpWidget(
      MaterialApp(
        routes: {
          '/devices': (_) => const DevicesScreen(),
          '/history': (_) => const Scaffold(body: Text('History Screen')),
        },
        initialRoute: '/devices',
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Histórico'));
    await tester.pumpAndSettle();

    expect(find.text('History Screen'), findsOneWidget);
  });

  testWidgets('navigates via popup menu to admin', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'devices.items': '[]'});

    await tester.pumpWidget(
      MaterialApp(
        routes: {
          '/devices': (_) => const DevicesScreen(),
          '/admin': (_) => const Scaffold(body: Text('Admin Screen')),
        },
        initialRoute: '/devices',
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Admin'));
    await tester.pumpAndSettle();

    expect(find.text('Admin Screen'), findsOneWidget);
  });
}
