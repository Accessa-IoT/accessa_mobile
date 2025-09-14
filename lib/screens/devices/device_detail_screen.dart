import 'package:flutter/material.dart';

class DeviceDetailScreen extends StatefulWidget {
  final String deviceId;
  final String deviceName;
  const DeviceDetailScreen({
    super.key,
    required this.deviceId,
    required this.deviceName,
  });

  @override
  State<DeviceDetailScreen> createState() => _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends State<DeviceDetailScreen> {
  bool _busy = false;
  String _lastStatus = '—';

  Future<void> _openLock() async {
    setState(() => _busy = true);
    await Future.delayed(const Duration(seconds: 1)); // simula request
    // TODO: publicar MQTT/HMAC -> aguardar resposta
    setState(() {
      _busy = false;
      _lastStatus = 'Sucesso • ${DateTime.now().toLocal()}';
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitação enviada')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.deviceName)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${widget.deviceId}'),
            const SizedBox(height: 8),
            Text('Última ação: $_lastStatus'),
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: _busy ? const SizedBox(
                height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2),
              ) : const Icon(Icons.lock_open),
              label: Text(_busy ? 'Enviando...' : 'Abrir'),
              onPressed: _busy ? null : _openLock,
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.sensors),
              label: const Text('Ler sensor da porta'),
              onPressed: () {
                // TODO: consultar estado do reed switch via API/MQTT
              },
            ),
            const SizedBox(height: 24),
            const Text('Configurações rápidas'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ActionChip(label: const Text('Tempo: 5s'), onPressed: () {}),
                ActionChip(label: const Text('Buzzer: ON'), onPressed: () {}),
                ActionChip(label: const Text('LED: Padrão'), onPressed: () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
