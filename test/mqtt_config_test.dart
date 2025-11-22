import 'package:flutter_test/flutter_test.dart';
import 'package:accessa_mobile/data/services/mqtt_config.dart';

void main() {
  test('MqttConfig constants and clientId format', () {
    expect(MqttConfig.host, isNotEmpty);
    expect(MqttConfig.username, isNotEmpty);
    expect(MqttConfig.password, isNotEmpty);
    expect(MqttConfig.baseTopic, contains('accessa'));

    final id = MqttConfig.clientId();
    expect(id.startsWith('accessa_'), isTrue);
    // should contain timestamp digits after prefix
    final suffix = id.substring('accessa_'.length);
    expect(int.tryParse(suffix), isNotNull);
  });
}
