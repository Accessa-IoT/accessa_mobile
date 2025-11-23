import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:accessa_mobile/data/services/mqtt_service.dart';
import 'package:accessa_mobile/ui/devices/view_model/device_detail_view_model.dart';

// Generate mock for MqttService
@GenerateMocks([MqttService])
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

      // Wait for async connect
      await Future.delayed(Duration.zero);

      verify(mockMqtt.connect()).called(1);
      verify(mockMqtt.subscribe(any)).called(1);
      expect(vm.log.first, contains('Conectado'));
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

    test('reconnect calls connect', () async {
      vm.init('dev-123');

      await Future.delayed(Duration.zero); // Let init start

      await vm.reconnect();
      verify(mockMqtt.connect()).called(2); // 1 from init, 1 from reconnect
    });
  });
}
