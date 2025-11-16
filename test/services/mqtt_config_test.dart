import 'package:flutter_test/flutter_test.dart';
import 'package:accessa_mobile/services/mqtt_config.dart';

void main() {
  group('MqttConfig', () {
    test('baseTopic é "accessa"', () {
      expect(MqttConfig.baseTopic, 'accessa');
    });

    test('clientId começa com "accessa_" e tem sufixo numérico', () {
      final id = MqttConfig.clientId();

      // Deve começar com o prefixo configurado
      expect(id.startsWith('accessa_'), isTrue);

      // O restante deve ser um número (timestamp)
      final suffix = id.substring('accessa_'.length);
      expect(suffix.isNotEmpty, isTrue);
      expect(int.tryParse(suffix) != null, isTrue);
    });
  });
}
