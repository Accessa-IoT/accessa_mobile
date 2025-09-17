import 'package:flutter/material.dart';
import 'package:accessa_mobile/services/device_service.dart';
import 'package:accessa_mobile/services/auth_service.dart';

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

  Future<void> _persist() async {
    await DeviceService.save(_devices);
    if (mounted) setState(() {});
  }

  Future<bool> _onWillPop() async {
    // Bloqueia "voltar" para login/home quando autenticado.
    return false;
  }

  void _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
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
              final exists = _devices.any((d) => d['id'] == idCtrl.text.trim());
              if (exists) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ID já existente')));
                return;
              }
              _devices.add({'id': idCtrl.text.trim(), 'name': nameCtrl.text.trim(), 'status': status});
              await _persist();
              if (!mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dispositivo adicionado')));
            },
          ),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  void _openEditDevice(int index) {
    final current = Map<String, String>.from(_devices[index]);
    final idCtrl = TextEditingController(text: current['id']);
    final nameCtrl = TextEditingController(text: current['name']);
    String status = current['status'] ?? 'online';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          left: 16, right: 16, top: 16,
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Editar dispositivo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nome')),
          const SizedBox(height: 8),
          TextField(controller: idCtrl, decoration: const InputDecoration(labelText: 'ID')),
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
            label: const Text('Salvar alterações'),
            onPressed: () async {
              if (idCtrl.text.isEmpty || nameCtrl.text.isEmpty) return;
              final newId = idCtrl.text.trim();
              final changedId = newId != current['id'];
              if (changedId && _devices.any((d) => d['id'] == newId)) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ID já existente')));
                return;
              }
              _devices[index] = {'id': newId, 'name': nameCtrl.text.trim(), 'status': status};
              await _persist();
              if (!mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dispositivo atualizado')));
            },
          ),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  void _removeDevice(int index) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remover dispositivo'),
        content: Text('Tem certeza que deseja remover "${_devices[index]['name']}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Remover')),
        ],
      ),
    );
    if (ok == true) {
      _devices.removeAt(index);
      await _persist();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dispositivo removido')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true, // mostra hambúrguer se houver Drawer
          title: const Text('Meus Dispositivos'),
          actions: [
            IconButton(tooltip: 'Histórico', icon: const Icon(Icons.history), onPressed: () => Navigator.pushNamed(context, '/history')),
            IconButton(tooltip: 'Admin', icon: const Icon(Icons.admin_panel_settings), onPressed: () => Navigator.pushNamed(context, '/admin')),
            IconButton(tooltip: 'Atualizar', icon: const Icon(Icons.refresh), onPressed: _reload),
            IconButton(tooltip: 'Sair', icon: const Icon(Icons.logout), onPressed: _logout),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              const DrawerHeader(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lock_open, size: 40),
                    SizedBox(height: 8),
                    Text('Accessa', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.devices),
                title: const Text('Dispositivos'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Histórico'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/history');
                },
              ),
              ListTile(
                leading: const Icon(Icons.admin_panel_settings),
                title: const Text('Administração'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/admin');
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Sair'),
                onTap: () {
                  Navigator.pop(context);
                  _logout();
                },
              ),
            ],
          ),
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
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/device_detail',
                        arguments: {'deviceId': d['id'], 'deviceName': d['name']},
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            _openEditDevice(i);
                          } else if (value == 'remove') {
                            _removeDevice(i);
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'edit', child: Text('Editar')),
                          PopupMenuItem(value: 'remove', child: Text('Remover')),
                        ],
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
      ),
    );
  }
}
