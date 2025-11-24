import 'package:flutter_test/flutter_test.dart';
import 'package:accessa_mobile/data/services/mqtt_config.dart';

void main() {
  group('MqttConfig', () {
    test('baseTopic é "accessa"', () {
      expect(MqttConfig.baseTopic, 'accessa');
    });

    test('clientId começa com "accessa_" e tem sufixo numérico', () {
      final id = MqttConfig.clientId();

      expect(id.startsWith('accessa_'), isTrue);

      final suffix = id.substring('accessa_'.length);
      expect(suffix.isNotEmpty, isTrue);
      expect(int.tryParse(suffix) != null, isTrue);
    });
  });
}
