import 'dart:async';
import 'dart:io' show SecurityContext;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import 'mqtt_config.dart';

class MqttService {
  MqttServerClient? _client;
  final MqttServerClient Function()? _clientFactory;
  final bool acceptBadCerts;
  final _messageCtrl =
      StreamController<MqttReceivedMessage<MqttMessage>>.broadcast();
  Stream<MqttReceivedMessage<MqttMessage>> get messages => _messageCtrl.stream;

  MqttService({
    MqttServerClient Function()? clientFactory,
    this.acceptBadCerts = false,
  }) : _clientFactory = clientFactory;

  bool get isConnected =>
      _client?.connectionStatus?.state == MqttConnectionState.connected;

  Future<void> connect() async {
    if (isConnected) return;

    final client = _clientFactory != null
        ? _clientFactory!()
        : (kIsWeb ? _buildWsClient() : _buildTlsClient());

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
      client.disconnect();
      _client = null;

      if (!kIsWeb) {
        final fb = _clientFactory != null
            ? _clientFactory!()
            : _buildWsClient();
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

    client.securityContext = SecurityContext.defaultContext;

    if (acceptBadCerts) {
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

    client.useWebSocket = true;
    client.websocketProtocols = MqttClientConstants.protocolsSingleDefault;

    client.connectionMessage = MqttConnectMessage()
        .withClientIdentifier(MqttConfig.clientId())
        .authenticateAs(MqttConfig.username, MqttConfig.password)
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    return client;
  }
}
