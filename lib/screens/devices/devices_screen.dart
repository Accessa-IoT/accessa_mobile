import 'package:flutter/material.dart';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  // TODO: substituir por fetch da API
  final _devices = const [
    {'id': 'dev-101', 'name': 'Laboratório 01', 'status': 'online'},
    {'id': 'dev-102', 'name': 'Cowork Sala A', 'status': 'offline'},
    {'id': 'dev-103', 'name': 'Armário 07', 'status': 'online'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Dispositivos'),
        actions: [
          IconButton(
            tooltip: 'Histórico',
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.pushNamed(context, '/history'),
          ),
          IconButton(
            tooltip: 'Admin',
            icon: const Icon(Icons.admin_panel_settings),
            onPressed: () => Navigator.pushNamed(context, '/admin'),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: _devices.length,
        separatorBuilder: (_, __) => const SizedBox(height: 6),
        itemBuilder: (_, i) {
          final d = _devices[i];
          final online = d['status'] == 'online';
          return Card(
            child: ListTile(
              leading: Icon(
                online ? Icons.wifi : Icons.wifi_off,
                color: online ? Colors.green : Colors.red,
              ),
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
        onPressed: () {
          // TODO: cadastro de dispositivo
        },
      ),
    );
  }
}
