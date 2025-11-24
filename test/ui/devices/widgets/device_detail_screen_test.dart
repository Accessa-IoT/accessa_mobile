import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:provider/provider.dart';
import 'package:accessa_mobile/ui/devices/widgets/device_detail_screen.dart';
import 'package:accessa_mobile/ui/devices/view_model/device_detail_view_model.dart';
import 'package:accessa_mobile/data/services/mqtt_service.dart';

class MockMqttService extends Mock implements MqttService {
  final StreamController<MqttReceivedMessage<MqttMessage>> _controller =
      StreamController<MqttReceivedMessage<MqttMessage>>.broadcast();

  @override
  Stream<MqttReceivedMessage<MqttMessage>> get messages => _controller.stream;

  @override
  Future<void> connect() async {
    // Do nothing - avoid real connection
  }

  @override
  Future<void> subscribe(
    String topic, {
    MqttQos qos = MqttQos.atMostOnce,
  }) async {
    // Do nothing
  }

  @override
  Future<void> publishString(
    String topic,
    String message, {
    MqttQos qos = MqttQos.atMostOnce,
    bool retain = false,
  }) async {
    // Do nothing
  }

  @override
  Future<void> disconnect() async {
    // Do nothing
  }

  void dispose() {
    _controller.close();
  }
}

void main() {
  late MockMqttService mockMqtt;
  late DeviceDetailViewModel viewModel;
  final device = {'id': 'dev-101', 'name': 'Test Device'};

  setUp(() {
    mockMqtt = MockMqttService();
    viewModel = DeviceDetailViewModel(mqtt: mockMqtt)..init(device['id']!);
  });

  tearDown(() {
    mockMqtt.dispose();
  });

  Widget createWidget() {
    return MaterialApp(
      home: DeviceDetailScreen(device: device, viewModel: viewModel),
    );
  }

  testWidgets('renders device info and initial status', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidget());
    await tester.pump();

    expect(find.text('Test Device'), findsNWidgets(2)); // AppBar + Card
    expect(find.text('Status atual: Desconhecido'), findsOneWidget);
  });

  testWidgets('displays lock icon for unknown status', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidget());
    await tester.pump();
    await tester.pump();

    // Default status "Desconhecido" should show lock_outline
    expect(find.byIcon(Icons.lock_outline), findsOneWidget);
  });

  testWidgets('displays command buttons', (WidgetTester tester) async {
    await tester.pumpWidget(createWidget());
    await tester.pump();

    expect(find.text('Abrir Porta'), findsOneWidget);
    expect(find.text('Travar Porta'), findsOneWidget);
    expect(find.byIcon(Icons.lock_open), findsOneWidget); // Button icon
    expect(find.byIcon(Icons.lock), findsOneWidget); // Button icon
  });

  testWidgets('sends open command and shows snackbar', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidget());
    await tester.pump();

    await tester.tap(find.text('Abrir Porta'));
    await tester.pump();

    // Should show success snackbar
    expect(find.text('Comando enviado: abrir'), findsOneWidget);
  });

  testWidgets('sends lock command and shows snackbar', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidget());
    await tester.pump();

    await tester.tap(find.text('Travar Porta'));
    await tester.pump();

    // Should show success snackbar
    expect(find.text('Comando enviado: travar'), findsOneWidget);
  });

  testWidgets('displays log section', (WidgetTester tester) async {
    await tester.pumpWidget(createWidget());
    await tester.pump();

    expect(find.text('📜 Log de Acesso'), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);
  });

  testWidgets('reconnect button is present', (WidgetTester tester) async {
    await tester.pumpWidget(createWidget());
    await tester.pump();

    expect(find.byTooltip('Reconectar'), findsOneWidget);
  });

  testWidgets('displays device name in app bar', (WidgetTester tester) async {
    await tester.pumpWidget(createWidget());
    await tester.pump();

    expect(find.widgetWithText(AppBar, 'Test Device'), findsOneWidget);
  });

  testWidgets('displays door icon', (WidgetTester tester) async {
    await tester.pumpWidget(createWidget());
    await tester.pump();

    expect(find.byIcon(Icons.door_front_door), findsOneWidget);
  });
}
