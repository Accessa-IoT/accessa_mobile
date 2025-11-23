import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:accessa_mobile/data/services/mqtt_service.dart';
import 'package:accessa_mobile/data/services/mqtt_config.dart';

class DeviceDetailViewModel extends ChangeNotifier {
  final MqttService _mqtt;

  DeviceDetailViewModel({MqttService? mqtt}) : _mqtt = mqtt ?? MqttService();
  String _status = 'Desconhecido';
  final List<String> _log = [];
  bool _loading = false;
  StreamSubscription? _sub;
  String? _deviceId;

  String get status => _status;
  List<String> get log => _log;
  bool get loading => _loading;

  void init(String deviceId) {
    _deviceId = deviceId;
    _connect();
  }

  Future<void> _connect() async {
    if (_deviceId == null) return;
    _loading = true;
    notifyListeners();

    try {
      await _mqtt.connect();
      final base = '${MqttConfig.baseTopic}/$_deviceId';
      await _mqtt.subscribe('$base/#');
      _sub?.cancel();
      _sub = _mqtt.messages.listen(_onMessage);
      _addLog('✅ Conectado ao HiveMQ Cloud');
    } catch (e) {
      _addLog('❌ Falha na conexão: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void _onMessage(MqttReceivedMessage<MqttMessage> evt) {
    final topic = evt.topic;
    final MqttPublishMessage recMess = evt.payload as MqttPublishMessage;
    final payload = MqttPublishPayload.bytesToStringAsString(
      recMess.payload.message,
    );
    _addLog('📩 [$topic] $payload');

    if (topic.endsWith('/status')) {
      _status = payload;
      notifyListeners();
    } else if (topic.endsWith('/log')) {
      try {
        final data = jsonDecode(payload);
        _addLog('👤 ${data["usuario"]} → ${data["acao"]} (${data["hora"]})');
      } catch (_) {
        _addLog('🔍 Log inválido recebido');
      }
    }
  }

  Future<void> sendCommand(
    String command, {
    required Function(String) onSuccess,
    required Function(String) onError,
  }) async {
    if (_deviceId == null) return;
    try {
      final topic = '${MqttConfig.baseTopic}/$_deviceId/comando';
      await _mqtt.publishString(topic, command);
      _addLog('📤 Enviado: $command');
      onSuccess('Comando enviado: $command');
    } catch (e) {
      _addLog('❌ Falha ao enviar: $e');
      onError('Falha ao enviar: $e');
    }
  }

  void _addLog(String msg) {
    final now = DateTime.now();
    final time =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    _log.insert(0, '[$time] $msg');
    notifyListeners();
  }

  Future<void> reconnect() async {
    if (!loading) _connect();
  }

  @override
  void dispose() {
    _sub?.cancel();
    _mqtt.disconnect();
    super.dispose();
  }
}
