class MqttConfig {
  static const String host =
      'b57e703be5e8423287c46b91e5714e83.s1.eu.hivemq.cloud';
  static const String username = 'app_accessa';
  static const String password = 'Bx@EXHuLvw.V7X6';
  static const String baseTopic = 'accessa';

  static String clientId() =>
      'accessa_${DateTime.now().millisecondsSinceEpoch}';
}
