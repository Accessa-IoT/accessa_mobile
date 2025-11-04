import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';

import '../../data/services/mqtt_service.dart';
import '../../data/services/mqtt_config.dart';

class MqttScreen extends StatefulWidget {
  const MqttScreen({super.key});

  @override
  State<MqttScreen> createState() => _MqttScreenState();
}

class _MqttScreenState extends State<MqttScreen> {
  final svc = MqttService();
  final List<String> log = [];
  String portaStatus = 'Desconhecido';
  bool loading = false;
  StreamSubscription? _sub;

  String get _modeLabel => kIsWeb ? 'WS 8884' : 'TLS 8883';

  @override
  void initState() {
    super.initState();
    _connect();
  }

  Future<void> _connect() async {
    if (!mounted) return;
    setState(() => loading = true);
    try {
      await svc.connect();
      await svc.subscribe('${MqttConfig.baseTopic}/porta01/#');
      await _sub?.cancel();
      _sub = svc.messages.listen(_onMessage);
      _addLog('✅ Conectado (${_modeLabel}) ao ${MqttConfig.host}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('MQTT conectado (${_modeLabel}).')),
        );
      }
    } catch (e) {
      _addLog('❌ Erro ao conectar: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Falha na conexão: $e')));
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _onMessage(MqttReceivedMessage<MqttMessage> evt) {
    if (!mounted) return;
    final topic = evt.topic;
    final MqttPublishMessage recMess = evt.payload as MqttPublishMessage;
    final payload = MqttPublishPayload.bytesToStringAsString(
      recMess.payload.message,
    );

    _addLog('📩 [$topic] $payload');

    if (topic.endsWith('/status')) {
      setState(() => portaStatus = payload);
    } else if (topic.endsWith('/log')) {
      try {
        final data = jsonDecode(payload);
        _addLog('👤 ${data["usuario"]} → ${data["acao"]} (${data["hora"]})');
      } catch (_) {
        _addLog('🔍 Log inválido recebido');
      }
    }
  }

  Future<void> _enviarComando(String comando) async {
    try {
      final topic = '${MqttConfig.baseTopic}/porta01/comando';
      await svc.publishString(topic, comando);
      _addLog('📤 Enviado: $comando');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Comando enviado: $comando')));
      }
    } catch (e) {
      _addLog('❌ Falha ao enviar: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Falha ao enviar: $e')));
      }
    }
  }

  void _addLog(String msg) {
    if (!mounted) return;
    setState(() => log.insert(0, '[${TimeOfDay.now().format(context)}] $msg'));
  }

  @override
  void dispose() {
    _sub?.cancel();
    svc.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Controle de Acesso (MQTT)'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reconectar',
            onPressed: loading ? null : _connect,
          ),
          IconButton(
            icon: const Icon(Icons.health_and_safety),
            tooltip: 'Diagnóstico MQTT',
            onPressed: () => Navigator.pushNamed(context, '/mqtt_diag'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔖 Etiqueta de modo + host (debug)
            Row(
              children: [
                Chip(
                  label: Text('Modo: ${_modeLabel.toUpperCase()}'),
                  avatar: const Icon(Icons.network_check),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Host: ${MqttConfig.host}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.door_front_door, size: 40),
                title: const Text(
                  'Porta 01',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Status atual: $portaStatus'),
                trailing: Icon(
                  portaStatus.toLowerCase().contains('aberta')
                      ? Icons.lock_open
                      : Icons.lock_outline,
                  color: portaStatus.toLowerCase().contains('aberta')
                      ? Colors.green
                      : Colors.red,
                  size: 28,
                ),
              ),
            ),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.lock_open),
                  label: const Text('Abrir Porta'),
                  onPressed: () => _enviarComando('abrir'),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.lock),
                  label: const Text('Travar Porta'),
                  onPressed: () => _enviarComando('travar'),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '📜 Log de Eventos',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  itemCount: log.length,
                  itemBuilder: (_, i) => Text(log[i]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
