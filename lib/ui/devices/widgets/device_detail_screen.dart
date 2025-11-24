import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:accessa_mobile/ui/devices/view_model/device_detail_view_model.dart';

class DeviceDetailScreen extends StatelessWidget {
  final Map<String, String> device;
  final DeviceDetailViewModel? viewModel;

  const DeviceDetailScreen({super.key, required this.device, this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          viewModel ?? (DeviceDetailViewModel()..init(device["id"]!)),
      child: _DeviceDetailContent(device: device),
    );
  }
}

class _DeviceDetailContent extends StatelessWidget {
  final Map<String, String> device;
  const _DeviceDetailContent({required this.device});

  void _enviarComando(BuildContext context, String comando) {
    final vm = context.read<DeviceDetailViewModel>();
    vm.sendCommand(
      comando,
      onSuccess: (msg) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      },
      onError: (msg) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DeviceDetailViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(device['name'] ?? 'Detalhe'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reconectar',
            onPressed: vm.loading ? null : vm.reconnect,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (vm.loading)
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: LinearProgressIndicator(),
              ),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.door_front_door, size: 40),
                title: Text(device['name'] ?? 'Dispositivo'),
                subtitle: Text('Status atual: ${vm.status}'),
                trailing: Icon(
                  vm.status.toLowerCase().contains('aberta')
                      ? Icons.lock_open
                      : Icons.lock_outline,
                  color: vm.status.toLowerCase().contains('aberta')
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
                  onPressed: () => _enviarComando(context, 'abrir'),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.lock),
                  label: const Text('Travar Porta'),
                  onPressed: () => _enviarComando(context, 'travar'),
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
                  itemCount: vm.log.length,
                  itemBuilder: (_, i) => Text(vm.log[i]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
