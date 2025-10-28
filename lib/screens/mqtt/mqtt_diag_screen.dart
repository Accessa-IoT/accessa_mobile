import 'dart:async';
import 'dart:io' show SecurityContext; // ignorado no Web
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import '../../services/mqtt_config.dart';

class MqttDiagScreen extends StatefulWidget {
  const MqttDiagScreen({super.key});

  @override
  State<MqttDiagScreen> createState() => _MqttDiagScreenState();
}

class _MqttDiagScreenState extends State<MqttDiagScreen> {
  String _tlsStatus = 'Aguardando';
  String _wsStatus  = 'Aguardando';
  String _tlsError  = '';
  String _wsError   = '';
  bool _running = false;

  Future<void> _run() async {
    if (_running) return;
    setState(() {
      _running = true;
      _tlsStatus = 'Testando...';
      _wsStatus  = 'Testando...';
      _tlsError = _wsError = '';
    });

    final tls = await _tryConnectTLS();
    final ws  = await _tryConnectWS();

    if (!mounted) return;
    setState(() {
      _tlsStatus = tls.$1 ? 'OK' : 'Falhou';
      _wsStatus  = ws.$1  ? 'OK' : 'Falhou';
      _tlsError  = tls.$2;
      _wsError   = ws.$2;
      _running   = false;
    });
  }

  Future<(bool, String)> _tryConnectTLS() async {
    final client = MqttServerClient.withPort(
      MqttConfig.host,
      'diag_tls_${DateTime.now().millisecondsSinceEpoch}',
      8883,
    );
    client.logging(on: false);
    client.setProtocolV311();
    client.keepAlivePeriod = 20;
    client.secure = true;
    client.securityContext = SecurityContext.defaultContext;

    client.connectionMessage = MqttConnectMessage()
        .withClientIdentifier('diag_tls_${DateTime.now().millisecondsSinceEpoch}')
        .authenticateAs(MqttConfig.username, MqttConfig.password)
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);

    try {
      await client.connect();
      client.disconnect();
      return (true, '');
    } catch (e) {
      client.disconnect();
      return (false, e.toString());
    }
  }

  Future<(bool, String)> _tryConnectWS() async {
    final client = MqttServerClient.withPort(
      MqttConfig.host,
      'diag_ws_${DateTime.now().millisecondsSinceEpoch}',
      8884,
    );
    client.logging(on: false);
    client.setProtocolV311();
    client.keepAlivePeriod = 20;
    client.secure = true;

    client.useWebSocket = true;
    client.websocketProtocols = MqttClientConstants.protocolsSingleDefault;
    // websocketPath setter was removed/renamed in newer mqtt_client versions;
    // if your broker requires a specific path (e.g. "/mqtt"), configure it
    // via the server URL or package-specific API — remove this line to compile.

    client.connectionMessage = MqttConnectMessage()
        .withClientIdentifier('diag_ws_${DateTime.now().millisecondsSinceEpoch}')
        .authenticateAs(MqttConfig.username, MqttConfig.password)
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);

    try {
      await client.connect();
      client.disconnect();
      return (true, '');
    } catch (e) {
      client.disconnect();
      return (false, e.toString());
    }
  }

  Widget _statusChip(String label, String status) {
    final ok = status == 'OK';
    final color = status == 'Testando...'
        ? Colors.amber
        : ok ? Colors.green : Colors.red;
    final icon = status == 'Testando...'
        ? Icons.hourglass_top
        : ok ? Icons.check_circle : Icons.cancel;
    return Chip(
      avatar: Icon(icon, color: Colors.white),
      label: Text('$label: $status',
          style: const TextStyle(color: Colors.white)),
      backgroundColor: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    final hint = kIsWeb
        ? 'Você está no navegador (kIsWeb = true). No app normal usaremos TLS 8883.'
        : 'Você está no desktop/mobile (kIsWeb = false). No navegador usaremos WS 8884.';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnóstico MQTT'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline),
                const SizedBox(width: 8),
                Expanded(child: Text('Host: ${MqttConfig.host}\n$hint')),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _statusChip('TLS 8883', _tlsStatus),
                const SizedBox(width: 8),
                _statusChip('WS 8884', _wsStatus),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _running ? null : _run,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Executar diagnóstico'),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  const Text('Detalhes TLS 8883:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(_tlsError.isEmpty ? '—' : _tlsError),
                  const SizedBox(height: 12),
                  const Text('Detalhes WS 8884:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(_wsError.isEmpty ? '—' : _wsError),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
