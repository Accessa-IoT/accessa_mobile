import 'package:flutter/material.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // TODO: substituir por busca na API
  final _items = List.generate(
    12,
    (i) => {
      'when': DateTime.now().subtract(Duration(hours: i * 3)),
      'user': i.isEven ? 'Hagliberto' : 'admin',
      'device': i.isEven ? 'Laboratório 01' : 'Armário 07',
      'result': i % 3 == 0 ? 'falha' : 'sucesso',
    },
  );

  String? _user;
  String? _device;
  String? _result;

  @override
  Widget build(BuildContext context) {
    final filtered = _items.where((e) {
      final okUser = _user == null || e['user'] == _user;
      final okDev = _device == null || e['device'] == _device;
      final okRes = _result == null || e['result'] == _result;
      return okUser && okDev && okRes;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Histórico')),
      body: Column(
        children: [
          // filtros
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                DropdownButton<String>(
                  hint: const Text('Usuário'),
                  value: _user,
                  items: const [
                    DropdownMenuItem(
                      value: 'Hagliberto',
                      child: Text('Hagliberto'),
                    ),
                    DropdownMenuItem(value: 'admin', child: Text('admin')),
                  ],
                  onChanged: (v) => setState(() => _user = v),
                ),
                DropdownButton<String>(
                  hint: const Text('Dispositivo'),
                  value: _device,
                  items: const [
                    DropdownMenuItem(
                      value: 'Laboratório 01',
                      child: Text('Laboratório 01'),
                    ),
                    DropdownMenuItem(
                      value: 'Armário 07',
                      child: Text('Armário 07'),
                    ),
                  ],
                  onChanged: (v) => setState(() => _device = v),
                ),
                DropdownButton<String>(
                  hint: const Text('Resultado'),
                  value: _result,
                  items: const [
                    DropdownMenuItem(value: 'sucesso', child: Text('sucesso')),
                    DropdownMenuItem(value: 'falha', child: Text('falha')),
                  ],
                  onChanged: (v) => setState(() => _result = v),
                ),
                TextButton(
                  onPressed: () => setState(() {
                    _user = _device = _result = null;
                  }),
                  child: const Text('Limpar filtros'),
                ),
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
                  leading: Icon(
                    ok ? Icons.check_circle : Icons.error,
                    color: ok ? Colors.green : Colors.red,
                  ),
                  title: Text('${e['device']} • ${e['user']}'),
                  subtitle: Text(
                    '${e['result']} • ${(e['when'] as DateTime).toLocal()}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: abrir detalhes do evento
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
