import 'package:flutter/material.dart';
import 'package:accessa_mobile/services/history_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> _items = [];
  String? _user;
  String? _device;
  String? _result;
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

  Future<void> _pickMenu({
    required Offset offset,
    required List<String> options,
    required void Function(String?) onSelect,
  }) async {
    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(offset.dx, offset.dy, offset.dx + 1, offset.dy + 1),
      items: options
          .map((e) => PopupMenuItem(value: e, child: Text(e)))
          .toList()
        ..insert(0, const PopupMenuItem<String>(value: '', child: Text('— Qualquer —'))),
    );
    onSelect(selected == '' ? null : selected);
  }

  void _showEventDetail(Map<String, dynamic> e) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  e['result'] == 'sucesso' ? Icons.check_circle : Icons.error,
                  color: e['result'] == 'sucesso' ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  '${e['device']} • ${e['user']}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Data/Hora: ${(e['when'] as DateTime).toLocal()}'),
            Text('Resultado: ${e['result']}'),
            const SizedBox(height: 12),
            Row(
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.copy),
                  label: const Text('Copiar resumo'),
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copiado')));
                  },
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  icon: const Icon(Icons.share),
                  label: const Text('Compartilhar'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _items.where((e) {
      final okUser = _user == null || e['user'] == _user;
      final okDev = _device == null || e['device'] == _device;
      final okRes = _result == null || e['result'] == _result;
      return okUser && okDev && okRes;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico'),
        actions: [
          IconButton(onPressed: _reload, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Filtros
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  child: Row(
                    children: [
                      _FilterButton(
                        label: _user == null ? 'Usuário' : 'Usuário: $_user',
                        onTap: (pos) => _pickMenu(
                          offset: pos,
                          options: const ['Hagliberto', 'admin'],
                          onSelect: (v) => setState(() => _user = v),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _FilterButton(
                        label: _device == null ? 'Dispositivo' : 'Dispositivo: $_device',
                        onTap: (pos) => _pickMenu(
                          offset: pos,
                          options: const ['Laboratório 01', 'Armário 07'],
                          onSelect: (v) => setState(() => _device = v),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _FilterButton(
                        label: _result == null ? 'Resultado' : 'Resultado: $_result',
                        onTap: (pos) => _pickMenu(
                          offset: pos,
                          options: const ['sucesso', 'falha'],
                          onSelect: (v) => setState(() => _result = v),
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => setState(() => {_user = null, _device = null, _result = null}),
                        child: const Text('Limpar filtros'),
                      )
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final e = filtered[i];
                      final ok = e['result'] == 'sucesso';
                      return ListTile(
                        leading: Icon(ok ? Icons.check_circle : Icons.error, color: ok ? Colors.green : Colors.red),
                        title: Text('${e['device']} • ${e['user']}'),
                        subtitle: Text('${e['result']} • ${(e['when'] as DateTime).toLocal()}'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _showEventDetail(e),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class _FilterButton extends StatefulWidget {
  final String label;
  final void Function(Offset globalPosition) onTap;
  const _FilterButton({required this.label, required this.onTap});

  @override
  State<_FilterButton> createState() => _FilterButtonState();
}

class _FilterButtonState extends State<_FilterButton> {
  final _key = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      key: _key,
      onPressed: () {
        final box = _key.currentContext!.findRenderObject() as RenderBox;
        final pos = box.localToGlobal(Offset.zero);
        widget.onTap(Offset(pos.dx, pos.dy + box.size.height));
      },
      child: Text(widget.label),
    );
  }
}
