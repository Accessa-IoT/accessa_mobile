import 'package:flutter_test/flutter_test.dart';
import 'package:accessa_mobile/data/services/mqtt_service.dart';

void main() {
  group('MqttService (light)', () {
    test('initial state: not connected and messages stream available', () {
      final svc = MqttService();
      expect(svc.isConnected, isFalse);
      expect(svc.messages, isA<Stream>());
    });

    test('disconnect when not connected does not throw', () async {
      final svc = MqttService();
      await svc.disconnect();
      expect(svc.isConnected, isFalse);
    });
  });
}
