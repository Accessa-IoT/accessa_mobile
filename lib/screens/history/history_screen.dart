import 'package:flutter/material.dart';
import 'package:accessa_mobile/services/history_service.dart';
import 'package:accessa_mobile/utils/date_fmt.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> _items = [];

  // Filtros (inicial)
  String? _user = 'Hagliberto';
  String? _device = 'Laboratório 01';
  String? _result; // qualquer

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    setState(() => _loading = true);
    final data = await HistoryService.load();
    if (mounted) setState(() {
      _items = data;
      _loading = false;
    });
  }

  // ---------- BottomSheet de filtros (compacto, sem nulos no Dropdown) ----------
  Future<void> _openFilters() async {
    String u = _user ?? '';
    String d = _device ?? '';
    String r = _result ?? '';

    final Map<String, String>? res = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16, right: 16, top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Filtros', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: u,
                items: const [
                  DropdownMenuItem<String>(value: '', child: Text('— Usuário: qualquer —')),
                  DropdownMenuItem<String>(value: 'Hagliberto', child: Text('Hagliberto')),
                  DropdownMenuItem<String>(value: 'admin', child: Text('admin')),
                ],
                onChanged: (v) => u = v ?? '',
                decoration: const InputDecoration(labelText: 'Usuário'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: d,
                items: const [
                  DropdownMenuItem<String>(value: '', child: Text('— Dispositivo: qualquer —')),
                  DropdownMenuItem<String>(value: 'Laboratório 01', child: Text('Laboratório 01')),
                  DropdownMenuItem<String>(value: 'Armário 07', child: Text('Armário 07')),
                ],
                onChanged: (v) => d = v ?? '',
                decoration: const InputDecoration(labelText: 'Dispositivo'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: r,
                items: const [
                  DropdownMenuItem<String>(value: '', child: Text('— Resultado: qualquer —')),
                  DropdownMenuItem<String>(value: 'sucesso', child: Text('sucesso')),
                  DropdownMenuItem<String>(value: 'falha', child: Text('falha')),
                ],
                onChanged: (v) => r = v ?? '',
                decoration: const InputDecoration(labelText: 'Resultado'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop<Map<String, String>>(context, {'u': '', 'd': '', 'r': ''}),
                    child: const Text('Limpar'),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    icon: const Icon(Icons.check),
                    label: const Text('Aplicar'),
                    onPressed: () => Navigator.pop<Map<String, String>>(context, {'u': u, 'd': d, 'r': r}),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (res != null && mounted) {
      setState(() {
        _user = (res['u'] ?? '').isEmpty ? null : res['u'];
        _device = (res['d'] ?? '').isEmpty ? null : res['d'];
        _result = (res['r'] ?? '').isEmpty ? null : res['r'];
      });
    }
  }
  // -----------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final filtered = _items.where((e) {
      final okUser = _user == null || e['user'] == _user;
      final okDev = _device == null || e['device'] == _device;
      final okRes = _result == null || e['result'] == _result;
      return okUser && okDev && okRes;
    }).toList();
    final count = filtered.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Text('$count', style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
          IconButton(tooltip: 'Filtros', icon: const Icon(Icons.filter_list), onPressed: _openFilters),
          IconButton(onPressed: _reload, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Resumo compacto dos filtros ativos
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                  child: Row(
                    children: [
                      Expanded(child: Text('Usuário: ${_user ?? "qualquer"}', overflow: TextOverflow.ellipsis)),
                      const SizedBox(width: 8),
                      Expanded(child: Text('Dispositivo: ${_device ?? "qualquer"}', overflow: TextOverflow.ellipsis)),
                      const SizedBox(width: 8),
                      Expanded(child: Text('Resultado: ${_result ?? "qualquer"}', overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final e = filtered[i];
                      final ok = e['result'] == 'sucesso';
                      final when = fmtDateTime(e['when'] as DateTime);
                      return ListTile(
                        leading: Icon(ok ? Icons.check_circle : Icons.error, color: ok ? Colors.green : Colors.red),
                        title: Text('${e['device']} • ${e['user']}'),
                        subtitle: Text('${e['result']} • $when'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => showModalBottomSheet(
                          context: context,
                          builder: (_) => Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(ok ? Icons.check_circle : Icons.error, color: ok ? Colors.green : Colors.red),
                                    const SizedBox(width: 8),
                                    Text('${e['device']} • ${e['user']}', style: const TextStyle(fontWeight: FontWeight.w600)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text('Data/Hora: $when'),
                                Text('Resultado: ${e['result']}'),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
