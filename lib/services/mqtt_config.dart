import 'package:flutter_dotenv/flutter_dotenv.dart';

class MqttConfig {
  final String namespace;
  final String? wsEndpoint; // para Web (wss://host:8884)
  final String host;        // para mobile/desktop (TLS 8883)
  final int port;
  final String username;
  final String password;

  const MqttConfig({
    required this.namespace,
    required this.host,
    required this.port,
    required this.username,
    required this.password,
    this.wsEndpoint,
  });

  static MqttConfig fromEnv() {
    final ns  = dotenv.env['MQTT_NAMESPACE'] ?? 'accessa';
    final ep  = dotenv.env['MQTT_ENDPOINT']; // opcional (Web)
    final h   = dotenv.env['MQTT_BROKER_HOST'] ?? '';
    final p   = int.tryParse(dotenv.env['MQTT_BROKER_PORT'] ?? '8883') ?? 8883;
    final usr = dotenv.env['MQTT_USERNAME'] ?? '';
    final pwd = dotenv.env['MQTT_PASSWORD'] ?? '';
    return MqttConfig(
      namespace: ns,
      wsEndpoint: ep?.isNotEmpty == true ? ep : null,
      host: h,
      port: p,
      username: usr,
      password: pwd,
    );
  }

  String topicCmd(String deviceId) => '$namespace/$deviceId/cmd';
  String topicEvt(String deviceId) => '$namespace/$deviceId/evt';
  String topicState(String deviceId) => '$namespace/$deviceId/state';
  String topicTele(String deviceId) => '$namespace/$deviceId/tele';
}
