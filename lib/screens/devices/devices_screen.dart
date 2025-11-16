import 'package:flutter/material.dart';
import '../../services/device_service.dart';
import '../../services/mqtt_service.dart';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  late Future<List<Map<String, String>>> _future;
  final mqtt = MqttService();

  @override
  void initState() {
    super.initState();
    _future = DeviceService.load();
  }

  @override
  void dispose() {
    mqtt.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      body: FutureBuilder<List<Map<String, String>>>(
        future: _future,
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snap.data!;
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
