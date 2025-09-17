import 'package:flutter/material.dart';
import 'package:accessa_mobile/utils/date_fmt.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final List<_Rule> _rules = [];
  final List<_KeyItem> _keys = [
    _KeyItem(deviceId: 'dev-101', maskedKey: '••••abcd', lastRotation: DateTime(2025, 9, 1)),
  ];

  void _createRule() async {
    final rule = await showModalBottomSheet<_Rule>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _CreateRuleSheet(),
    );
    if (rule != null) {
      setState(() => _rules.add(rule));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Regra criada')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Administração'),
          bottom: const TabBar(tabs: [
            Tab(icon: Icon(Icons.person), text: 'Usuários'),
            Tab(icon: Icon(Icons.lock_clock), text: 'Permissões'),
            Tab(icon: Icon(Icons.key), text: 'Chaves'),
          ]),
        ),
        body: TabBarView(
          children: [
            const _UsersTab(),
            _PermissionsTab(rules: _rules, onCreateRule: _createRule),
            _KeysTab(items: _keys),
          ],
        ),
      ),
    );
  }
}

class _UsersTab extends StatelessWidget {
  const _UsersTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: const [
        ListTile(leading: Icon(Icons.person), title: Text('Hagliberto'), subtitle: Text('admin')),
        ListTile(leading: Icon(Icons.person_outline), title: Text('Victor'), subtitle: Text('usuário')),
      ],
    );
  }
}

class _PermissionsTab extends StatelessWidget {
  final List<_Rule> rules;
  final VoidCallback onCreateRule;
  const _PermissionsTab({required this.rules, required this.onCreateRule});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 24),
        const Text('Permissões por horário/dispositivo'),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: onCreateRule,
          child: const Text('Criar regra'),
        ),
        const SizedBox(height: 16),
        const Divider(),
        Expanded(
          child: rules.isEmpty
              ? const Center(child: Text('Nenhuma regra criada ainda'))
              : ListView.separated(
                  itemBuilder: (_, i) => ListTile(
                    leading: const Icon(Icons.rule),
                    title: Text('${rules[i].user} • ${rules[i].deviceId}'),
                    subtitle: Text('${rules[i].days.join(", ")} • ${rules[i].start.format(context)} - ${rules[i].end.format(context)}'),
                  ),
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemCount: rules.length,
                ),
        ),
      ],
    );
  }
}

class _KeysTab extends StatefulWidget {
  final List<_KeyItem> items;
  const _KeysTab({required this.items});

  @override
  State<_KeysTab> createState() => _KeysTabState();
}

class _KeysTabState extends State<_KeysTab> {
  void _rotate(_KeyItem item) {
    setState(() {
      item.lastRotation = DateTime.now();
      item.maskedKey = '••••${DateTime.now().millisecondsSinceEpoch.toRadixString(16).substring(8)}';
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chaves rotacionadas')));
  }

  void _menuAction(String action, _KeyItem item) {
    switch (action) {
      case 'reveal':
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chave real (demo): 1234-ABCD-XYZ')));
        break;
      case 'revoke':
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chave revogada (demo)')));
        break;
      case 'copy':
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ID copiado')));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final k in widget.items) ...[
          ListTile(
            leading: const Icon(Icons.vpn_key),
            title: Text(k.deviceId),
            subtitle: Text('Chave: ${k.maskedKey}  |  Última rotação: ${fmtDateTime(k.lastRotation)}'),
            trailing: PopupMenuButton<String>(
              onSelected: (a) => _menuAction(a, k),
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'reveal', child: Text('Revelar chave')),
                PopupMenuItem(value: 'revoke', child: Text('Revogar chave')),
                PopupMenuItem(value: 'copy', child: Text('Copiar ID do device')),
              ],
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            icon: const Icon(Icons.autorenew),
            label: const Text('Rotacionar chaves'),
            onPressed: () => _rotate(k),
          ),
          const Divider(height: 24),
        ],
      ],
    );
  }
}

class _CreateRuleSheet extends StatefulWidget {
  @override
  State<_CreateRuleSheet> createState() => _CreateRuleSheetState();
}

class _CreateRuleSheetState extends State<_CreateRuleSheet> {
  final _formKey = GlobalKey<FormState>();
  String _user = 'Hagliberto';
  String _deviceId = 'dev-101';
  TimeOfDay _start = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _end = const TimeOfDay(hour: 18, minute: 0);
  final Map<String, bool> _days = {
    'Seg': true, 'Ter': true, 'Qua': true, 'Qui': true, 'Sex': true, 'Sáb': false, 'Dom': false,
  };

  Future<void> _pickStart() async {
    final r = await showTimePicker(context: context, initialTime: _start);
    if (r != null) setState(() => _start = r);
  }

  Future<void> _pickEnd() async {
    final r = await showTimePicker(context: context, initialTime: _end);
    if (r != null) setState(() => _end = r);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 16, right: 16, top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Nova regra de permissão', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _user,
                items: const [
                  DropdownMenuItem(value: 'Hagliberto', child: Text('Hagliberto')),
                  DropdownMenuItem(value: 'admin', child: Text('admin')),
                ],
                onChanged: (v) => setState(() => _user = v ?? _user),
                decoration: const InputDecoration(labelText: 'Usuário'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _deviceId,
                items: const [
                  DropdownMenuItem(value: 'dev-101', child: Text('dev-101 (Laboratório 01)')),
                  DropdownMenuItem(value: 'dev-103', child: Text('dev-103 (Armário 07)')),
                ],
                onChanged: (v) => setState(() => _deviceId = v ?? _deviceId),
                decoration: const InputDecoration(labelText: 'Dispositivo'),
              ),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _pickStart,
                    child: Text('Início: ${_start.format(context)}'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _pickEnd,
                    child: Text('Fim: ${_end.format(context)}'),
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                children: _days.keys.map((d) {
                  final v = _days[d]!;
                  return FilterChip(
                    label: Text(d),
                    selected: v,
                    onSelected: (sel) => setState(() => _days[d] = sel),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Salvar regra'),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final days = _days.entries.where((e) => e.value).map((e) => e.key).toList();
                    Navigator.pop(context, _Rule(user: _user, deviceId: _deviceId, start: _start, end: _end, days: days));
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Rule {
  final String user;
  final String deviceId;
  final TimeOfDay start;
  final TimeOfDay end;
  final List<String> days;
  _Rule({required this.user, required this.deviceId, required this.start, required this.end, required this.days});
}

class _KeyItem {
  final String deviceId;
  String maskedKey;
  DateTime lastRotation;
  _KeyItem({required this.deviceId, required this.maskedKey, required this.lastRotation});
}
