import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import '../../data/services/mqtt_service.dart';
import '../../data/services/mqtt_config.dart';

class DeviceDetailScreen extends StatefulWidget {
  final Map<String, String> device;
  const DeviceDetailScreen({super.key, required this.device});

  @override
  State<DeviceDetailScreen> createState() => _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends State<DeviceDetailScreen> {
  final mqtt = MqttService();
  String status = 'Desconhecido';
  final List<String> log = [];
  bool loading = false;
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _connect();
  }

  Future<void> _connect() async {
    if (!mounted) return;
    setState(() => loading = true);
    try {
      await mqtt.connect();
      final base = '${MqttConfig.baseTopic}/${widget.device["id"]}';
      await mqtt.subscribe('$base/#');
      _sub?.cancel();
      _sub = mqtt.messages.listen(_onMessage);
      _addLog('✅ Conectado ao HiveMQ Cloud');
    } catch (e) {
      _addLog('❌ Falha na conexão: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro MQTT: $e')));
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
      setState(() => status = payload);
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
      final topic = '${MqttConfig.baseTopic}/${widget.device["id"]}/comando';
      await mqtt.publishString(topic, comando);
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
    mqtt.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final device = widget.device;
    return Scaffold(
      appBar: AppBar(
        title: Text(device['name'] ?? 'Detalhe'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reconectar',
            onPressed: loading ? null : _connect,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.door_front_door, size: 40),
                title: Text(device['name'] ?? 'Dispositivo'),
                subtitle: Text('Status atual: $status'),
                trailing: Icon(
                  status.toLowerCase().contains('aberta')
                      ? Icons.lock_open
                      : Icons.lock_outline,
                  color: status.toLowerCase().contains('aberta')
                      ? Colors.green
                      : Colors.red,
                  size: 30,
                ),
              ),
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '📜 Log de Acesso',
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
