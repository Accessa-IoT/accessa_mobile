import 'package:flutter/material.dart';
import '../../services/device_service.dart';
import '../../services/mqtt_service.dart';
import 'package:provider/provider.dart';
import 'package:accessa_mobile/ui/devices/view_model/devices_view_model.dart';

class DevicesScreen extends StatelessWidget {
  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DevicesViewModel()..loadDevices(),
      child: const _DevicesContent(),
    );
  }
}
//

class _DevicesContent extends StatelessWidget {
  const _DevicesContent();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DevicesViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dispositivos'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.wifi_tethering),
            tooltip: 'Testar Conexão MQTT',
            onPressed: () => Navigator.pushNamed(context, '/mqtt'),
          ),
          IconButton(
            icon: const Icon(Icons.health_and_safety),
            tooltip: 'Diagnóstico MQTT',
            onPressed: () => Navigator.pushNamed(context, '/mqtt_diag'),
          ),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'home') Navigator.pushNamed(context, '/');
              if (v == 'history') Navigator.pushNamed(context, '/history');
              if (v == 'admin') Navigator.pushNamed(context, '/admin');
            },
            itemBuilder: (c) => const [
              PopupMenuItem(value: 'home', child: Text('Home')),
              PopupMenuItem(value: 'history', child: Text('Histórico')),
              PopupMenuItem(value: 'admin', child: Text('Admin')),
            ],
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (vm.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = vm.devices;
          if (items.isEmpty) {
            return const Center(child: Text('Nenhum dispositivo cadastrado'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, i) {
              final d = items[i];
              final online = d['status'] == 'online';
              return ListTile(
                leading: Icon(
                  online ? Icons.cloud_done : Icons.cloud_off,
                  color: online ? Colors.green : Colors.grey,
                  size: 28,
                ),
                title: Text(d['name'] ?? 'Dispositivo'),
                subtitle: Text('ID: ${d['id']}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.pushNamed(
                  context,
                  '/device_detail',
                  arguments: d,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
