import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:crypto/crypto.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:uuid/uuid.dart';
import 'mqtt_config.dart';

class MqttService {
  MqttService._();
  static final MqttService instance = MqttService._();

  late final MqttConfig _cfg;
  MqttClient? _client;

  final _eventsCtr = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get eventsStream => _eventsCtr.stream;

  bool get isConnected => _client?.connectionStatus?.state == MqttConnectionState.connected;

  Future<void> init(MqttConfig cfg) async {
    _cfg = cfg;
  }

  Future<void> connect({String clientId = 'app_accessa'}) async {
    if (isConnected) return;

    if (_isWeb && _cfg.wsEndpoint != null) {
      _client = MqttBrowserClient(_cfg.wsEndpoint!, clientId);
    } else {
      final cli = MqttServerClient(_cfg.host, clientId);
      cli.port = _cfg.port;
      cli.secure = true; // TLS
      _client = cli;
    }

    _client!
      ..logging(on: false)
      ..keepAlivePeriod = 30
      ..onDisconnected = _onDisconnected
      ..onConnected = _onConnected;

    final connMsg = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    _client!.connectionMessage = connMsg;

    try {
      await _client!.connect(_cfg.username, _cfg.password);
    } on Exception {
      _client!.disconnect();
      rethrow;
    }
  }

  void _onConnected() {/* noop or debug */}
  void _onDisconnected() {/* noop or debug */}

  Future<void> disconnect() async {
    _client?.disconnect();
  }

  /// Assina eventos de um dispositivo (evt + state)
  Future<void> subscribeDevice(String deviceId) async {
    if (!isConnected) await connect();
    _client!.updates?.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final rec = c?.firstOrNull;
      if (rec == null) return;
      final pt = (rec.payload as MqttPublishMessage).payload.message;
      final txt = MqttPublishPayload.bytesToStringAsString(pt);
      try {
        final data = jsonDecode(txt) as Map<String, dynamic>;
        _eventsCtr.add({'topic': rec.topic, 'data': data});
      } catch (_) {
        _eventsCtr.add({'topic': rec.topic, 'data': {'raw': txt}});
      }
    });

    _client!.subscribe(_cfg.topicEvt(deviceId), MqttQos.atLeastOnce);
    _client!.subscribe(_cfg.topicState(deviceId), MqttQos.atLeastOnce);
  }

  /// Publica comando de destravar (gera requestId, nonce, HMAC *demo*)
  Future<void> unlock(String deviceId, String userId, {int durationMs = 5000}) async {
    if (!isConnected) await connect();
    final ts = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final nonce = const Uuid().v4().substring(0, 12);
    // DEMO: HMAC com chave “fraca”; em produção use chave por dispositivo segura
    final key = utf8.encode('CHAVE_DEMO_$deviceId');
    final msg = utf8.encode('$nonce|$ts|$deviceId|$userId');
    final hmacHex = Hmac(sha256, key).convert(msg).toString();

    final payload = {
      'requestId': const Uuid().v4(),
      'deviceId': deviceId,
      'userId': userId,
      'timestamp': ts,
      'nonce': nonce,
      'hmac': hmacHex,
      'action': 'unlock',
      'durationMs': durationMs,
    };
    final builder = MqttClientPayloadBuilder()..addString(jsonEncode(payload));
    _client!.publishMessage(
      _cfg.topicCmd(deviceId),
      MqttQos.atLeastOnce,
      builder.payload!,
      retain: false,
    );
  }

  bool get _isWeb {
    // maneira simples de detectar compilação web
    try {
      return identical(0, 0.0); // só para evitar import de kIsWeb
    } catch (_) {
      return false;
    }
  }
}

extension _FirstOrNull<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
