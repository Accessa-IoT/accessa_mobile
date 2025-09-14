import 'package:flutter/material.dart';
import 'package:accessa_mobile/services/device_service.dart';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  List<Map<String, String>> _devices = [];

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final items = await DeviceService.load();
    if (mounted) setState(() => _devices = items);
  }

  void _openAddDevice() {
    final idCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    String status = 'online';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          left: 16, right: 16, top: 16,
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Adicionar dispositivo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nome')),
          const SizedBox(height: 8),
          TextField(controller: idCtrl, decoration: const InputDecoration(labelText: 'ID (ex.: dev-104)')),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: status,
            items: const [
              DropdownMenuItem(value: 'online', child: Text('online')),
              DropdownMenuItem(value: 'offline', child: Text('offline')),
            ],
            onChanged: (v) => status = v ?? 'online',
            decoration: const InputDecoration(labelText: 'Status'),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            icon: const Icon(Icons.save),
            label: const Text('Salvar'),
            onPressed: () async {
              if (idCtrl.text.isEmpty || nameCtrl.text.isEmpty) return;
              await DeviceService.add({'id': idCtrl.text, 'name': nameCtrl.text, 'status': status});
              if (!mounted) return;
              Navigator.pop(context);
              await _reload();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dispositivo adicionado')));
            },
          ),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Dispositivos'),
        actions: [
          IconButton(tooltip: 'Atualizar', icon: const Icon(Icons.refresh), onPressed: _reload),
        ],
      ),
      body: _devices.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: _devices.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (_, i) {
                final d = _devices[i];
                final online = d['status'] == 'online';
                return Card(
                  child: ListTile(
                    leading: Icon(online ? Icons.wifi : Icons.wifi_off, color: online ? Colors.green : Colors.red),
                    title: Text(d['name']!),
                    subtitle: Text('ID: ${d['id']}  •  ${d['status']}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/device_detail',
                      arguments: {'deviceId': d['id'], 'deviceName': d['name']},
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Adicionar'),
        onPressed: _openAddDevice,
      ),
    );
  }
}
