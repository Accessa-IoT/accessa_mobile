import 'dart:math';
import 'package:flutter/material.dart';

class DeviceDetailScreen extends StatefulWidget {
  final String deviceId;
  final String deviceName;
  const DeviceDetailScreen({super.key, required this.deviceId, required this.deviceName});

  @override
  State<DeviceDetailScreen> createState() => _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends State<DeviceDetailScreen> {
  bool _busy = false;
  String _lastStatus = '—';
  int _relaySeconds = 5;
  bool _buzzerOn = true;
  String _ledMode = 'Padrão';

  Future<void> _openLock() async {
    setState(() => _busy = true);
    await Future.delayed(const Duration(seconds: 1)); // simula request
    setState(() {
      _busy = false;
      _lastStatus = 'Sucesso • ${DateTime.now().toLocal()}';
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Solicitação enviada')));
  }

  Future<void> _readDoorSensor() async {
    await Future.delayed(const Duration(milliseconds: 400));
    final open = Random().nextBool();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sensor: porta ${open ? 'ABERTA' : 'FECHADA'}')),
    );
  }

  void _changeRelayTime() async {
    final values = [3, 5, 7, 10];
    final selected = await showMenu<int>(
      context: context,
      position: const RelativeRect.fromLTRB(24, 120, 24, 24),
      items: values.map((v) => PopupMenuItem(value: v, child: Text('Tempo: ${v}s'))).toList(),
    );
    if (selected != null) setState(() => _relaySeconds = selected);
  }

  void _toggleBuzzer() {
    setState(() => _buzzerOn = !_buzzerOn);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Buzzer: ${_buzzerOn ? 'ON' : 'OFF'}')));
  }

  void _changeLed() async {
    final modes = ['Padrão', 'Sucesso', 'Erro', 'Processando'];
    final selected = await showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(24, 160, 24, 24),
      items: modes.map((m) => PopupMenuItem(value: m, child: Text('LED: $m'))).toList(),
    );
    if (selected != null) setState(() => _ledMode = selected);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.deviceName)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('ID: ${widget.deviceId}'),
          const SizedBox(height: 8),
          Text('Última ação: $_lastStatus'),
          const SizedBox(height: 24),
          FilledButton.icon(
            icon: _busy
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.lock_open),
            label: Text(_busy ? 'Enviando...' : 'Abrir'),
            onPressed: _busy ? null : _openLock,
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.sensors),
            label: const Text('Ler sensor da porta'),
            onPressed: _readDoorSensor,
          ),
          const SizedBox(height: 24),
          const Text('Configurações rápidas'),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: [
            ActionChip(label: Text('Tempo: ${_relaySeconds}s'), onPressed: _changeRelayTime),
            ActionChip(label: Text('Buzzer: ${_buzzerOn ? 'ON' : 'OFF'}'), onPressed: _toggleBuzzer),
            ActionChip(label: Text('LED: $_ledMode'), onPressed: _changeLed),
          ]),
        ]),
      ),
    );
  }
}
