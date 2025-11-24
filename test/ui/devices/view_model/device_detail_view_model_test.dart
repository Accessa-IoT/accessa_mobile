import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:accessa_mobile/data/services/mqtt_service.dart';
import 'package:accessa_mobile/ui/devices/view_model/device_detail_view_model.dart';
import 'package:typed_data/typed_data.dart';

// Generate mock for MqttService
@GenerateMocks([MqttService, MqttPublishMessage, MqttPublishPayload])
import 'device_detail_view_model_test.mocks.dart';

void main() {
  group('DeviceDetailViewModel', () {
    late DeviceDetailViewModel vm;
    late MockMqttService mockMqtt;
    late StreamController<MqttReceivedMessage<MqttMessage>> msgController;

    setUp(() {
      mockMqtt = MockMqttService();
      msgController =
          StreamController<MqttReceivedMessage<MqttMessage>>.broadcast();

      when(mockMqtt.messages).thenAnswer((_) => msgController.stream);
      when(mockMqtt.connect()).thenAnswer((_) async {});
      when(mockMqtt.subscribe(any)).thenAnswer((_) async {});
      when(mockMqtt.publishString(any, any)).thenAnswer((_) async {});
      when(mockMqtt.disconnect()).thenAnswer((_) async {});

      vm = DeviceDetailViewModel(mqtt: mockMqtt);
    });

    tearDown(() {
      msgController.close();
      vm.dispose();
    });

    test('initial state is correct', () {
      expect(vm.status, 'Desconhecido');
      expect(vm.log, isEmpty);
      expect(vm.loading, isFalse);
    });

    test('init connects to MQTT', () async {
      vm.init('dev-123');
      await Future.delayed(Duration.zero);

      verify(mockMqtt.connect()).called(1);
      verify(mockMqtt.subscribe(any)).called(1);
      expect(vm.log.first, contains('Conectado'));
    });

    test('init handles connection failure', () async {
      when(mockMqtt.connect()).thenThrow(Exception('Connection failed'));

      vm.init('dev-123');
      await Future.delayed(Duration.zero);

      expect(vm.log.first, contains('Falha na conexão'));
      expect(vm.loading, isFalse);
    });

    test('handles status message', () async {
      vm.init('dev-123');
      await Future.delayed(Duration.zero);

      final topic = 'accessa/dev-123/status';
      final payload = 'online';

      final msg = MockMqttPublishMessage();
      final payloadObj = MockMqttPublishPayload();

      when(msg.payload).thenReturn(payloadObj);
      when(
        payloadObj.message,
      ).thenReturn(Uint8Buffer()..addAll(utf8.encode(payload)));

      msgController.add(MqttReceivedMessage<MqttMessage>(topic, msg));

      // Wait for stream listener
      await Future.delayed(Duration.zero);

      expect(vm.status, 'online');
      expect(vm.log.first, contains('online'));
    });

    test('handles log message with valid JSON', () async {
      vm.init('dev-123');
      await Future.delayed(Duration.zero);

      final topic = 'accessa/dev-123/log';
      final json = jsonEncode({
        'usuario': 'User',
        'acao': 'Open',
        'hora': '12:00',
      });

      final msg = MockMqttPublishMessage();
      final payloadObj = MockMqttPublishPayload();

      when(msg.payload).thenReturn(payloadObj);
      when(
        payloadObj.message,
      ).thenReturn(Uint8Buffer()..addAll(utf8.encode(json)));

      msgController.add(MqttReceivedMessage<MqttMessage>(topic, msg));

      await Future.delayed(Duration.zero);

      expect(vm.log.first, contains('User → Open'));
    });

    test('handles log message with invalid JSON', () async {
      vm.init('dev-123');
      await Future.delayed(Duration.zero);

      final topic = 'accessa/dev-123/log';
      final payload = 'invalid json';

      final msg = MockMqttPublishMessage();
      final payloadObj = MockMqttPublishPayload();

      when(msg.payload).thenReturn(payloadObj);
      when(
        payloadObj.message,
      ).thenReturn(Uint8Buffer()..addAll(utf8.encode(payload)));

      msgController.add(MqttReceivedMessage<MqttMessage>(topic, msg));

      await Future.delayed(Duration.zero);

      expect(vm.log.first, contains('Log inválido'));
    });

    test('sendCommand publishes message', () async {
      vm.init('dev-123');

      bool successCalled = false;
      await vm.sendCommand(
        'OPEN',
        onSuccess: (_) => successCalled = true,
        onError: (_) {},
      );

      verify(mockMqtt.publishString(any, 'OPEN')).called(1);
      expect(successCalled, isTrue);
      expect(vm.log.first, contains('Enviado: OPEN'));
    });

    test('sendCommand handles failure', () async {
      vm.init('dev-123');
      when(
        mockMqtt.publishString(any, any),
      ).thenThrow(Exception('Publish failed'));

      bool errorCalled = false;
      await vm.sendCommand(
        'OPEN',
        onSuccess: (_) {},
        onError: (_) => errorCalled = true,
      );

      expect(errorCalled, isTrue);
      expect(vm.log.first, contains('Falha ao enviar'));
    });

    test('reconnect calls connect if not loading', () async {
      vm.init('dev-123');
      await Future.delayed(Duration.zero); // Let init finish
      await Future.delayed(Duration.zero);

      await vm.reconnect();
      verify(mockMqtt.connect()).called(2);
    });

    test('reconnect does nothing if loading', () async {
      // Manually trigger loading state via init but don't let it finish immediately
      // Actually, init sets loading=true synchronously.
      // We need to call reconnect while init is awaiting connect.

      var completer = Completer<void>();
      when(mockMqtt.connect()).thenAnswer((_) => completer.future);

      vm.init('dev-123');
      // loading is true now

      await vm.reconnect();

      // Should only be called once (by init)
      verify(mockMqtt.connect()).called(1);

      completer.complete();
      await Future.delayed(Duration.zero); // Allow _connect to finish
    });

    test('reconnect does nothing if deviceId is null', () async {
      // No init called
      await vm.reconnect();
      verifyNever(mockMqtt.connect());
    });

    test('sendCommand does nothing if deviceId is null', () async {
      // No init called
      bool callbackCalled = false;
      await vm.sendCommand(
        'CMD',
        onSuccess: (_) => callbackCalled = true,
        onError: (_) => callbackCalled = true,
      );

      verifyNever(mockMqtt.publishString(any, any));
      expect(callbackCalled, isFalse);
    });
  });
}
