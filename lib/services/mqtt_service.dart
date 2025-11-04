import 'dart:async';
import 'dart:io' show SecurityContext;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import 'mqtt_config.dart';

/// Serviço MQTT híbrido (Windows/Android/iOS = TLS 8883, Web = WS 8884)
class MqttService {
  MqttServerClient? _client;
  final _messageCtrl =
      StreamController<MqttReceivedMessage<MqttMessage>>.broadcast();
  Stream<MqttReceivedMessage<MqttMessage>> get messages => _messageCtrl.stream;

  /// Altere para `true` *apenas para diagnóstico* se houver proxy/antivírus
  /// interceptando TLS no Windows. Se funcionar com `true`, o problema é MITM.
  static const bool acceptBadCerts = false;

  bool get isConnected =>
      _client?.connectionStatus?.state == MqttConnectionState.connected;

  Future<void> connect() async {
    if (isConnected) return;

    final client = kIsWeb ? _buildWsClient() : _buildTlsClient();

    client.onConnected = () {};
    client.onDisconnected = () {};
    client.onSubscribed = (t) {};
    client.onUnsubscribed = (t) {};
    client.onSubscribeFail = (t) {};

    client.updates?.listen((events) {
      for (final e in events) {
        _messageCtrl.add(e);
      }
    });

    try {
      await client.connect(MqttConfig.username, MqttConfig.password);
      _client = client;
    } on Exception {
      // Falhou o primário; para Web não faz sentido tentar TLS,
      // mas em desktop podemos opcionalmente testar WS como fallback.
      client.disconnect();
      _client = null;

      if (!kIsWeb) {
        // fallback para WS 8884
        final fb = _buildWsClient();
        try {
          await fb.connect(MqttConfig.username, MqttConfig.password);
          _client = fb;
          return;
        } catch (e) {
          fb.disconnect();
          rethrow;
        }
      } else {
        rethrow;
      }
    }
  }

  Future<void> disconnect() async {
    _client?.disconnect();
    _client = null;
  }

  Future<void> subscribe(
    String topic, {
    MqttQos qos = MqttQos.atLeastOnce,
  }) async {
    if (!isConnected) await connect();
    _client?.subscribe(topic, qos);
  }

  Future<void> unsubscribe(String topic) async {
    _client?.unsubscribe(topic);
  }

  Future<void> publishString(
    String topic,
    String payload, {
    MqttQos qos = MqttQos.atLeastOnce,
    bool retain = false,
  }) async {
    if (!isConnected) await connect();
    final builder = MqttClientPayloadBuilder()..addString(payload);
    _client?.publishMessage(topic, qos, builder.payload!, retain: retain);
  }

  // -------------------- builders --------------------

  MqttServerClient _buildTlsClient() {
    final client = MqttServerClient.withPort(
      MqttConfig.host,
      MqttConfig.clientId(),
      8883,
    );
    client.logging(on: false);
    client.keepAlivePeriod = 30;
    client.setProtocolV311();
    client.secure = true;
    client.connectTimeoutPeriod = 8000;

    // contexto padrão do SO
    client.securityContext = SecurityContext.defaultContext;

    // Aceitar certificado ruim (diagnóstico de MITM/proxy)
    if (acceptBadCerts) {
      // algumas versões tipam dynamic; funciona nas atuais:
      // ignore: unnecessary_cast
      client.onBadCertificate = (dynamic cert) => true as bool;
    }

    client.connectionMessage = MqttConnectMessage()
        .withClientIdentifier(MqttConfig.clientId())
        .authenticateAs(MqttConfig.username, MqttConfig.password)
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    return client;
  }

  MqttServerClient _buildWsClient() {
    final client = MqttServerClient.withPort(
      MqttConfig.host,
      MqttConfig.clientId(),
      8884,
    );
    client.logging(on: false);
    client.keepAlivePeriod = 30;
    client.setProtocolV311();
    client.secure = true;
    client.connectTimeoutPeriod = 10000;

    // WebSocket
    client.useWebSocket = true;
    client.websocketProtocols = MqttClientConstants.protocolsSingleDefault;
    // Algumas versões do mqtt_client não têm websocketPath; o HiveMQ Cloud
    // pede '/mqtt'. Se a sua não tiver a propriedade, o Web pode não conectar.

    client.connectionMessage = MqttConnectMessage()
        .withClientIdentifier(MqttConfig.clientId())
        .authenticateAs(MqttConfig.username, MqttConfig.password)
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    return client;
  }
}
