import 'package:flutter/material.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // placeholders de gestão
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Administração'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.person), text: 'Usuários'),
              Tab(icon: Icon(Icons.lock_clock), text: 'Permissões'),
              Tab(icon: Icon(Icons.key), text: 'Chaves'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [_UsersTab(), _PermissionsTab(), _KeysTab()],
        ),
      ),
    );
  }
}

class _UsersTab extends StatelessWidget {
  const _UsersTab();

  @override
  Widget build(BuildContext context) {
    // TODO: listar/editar perfis
    return ListView(
      padding: const EdgeInsets.all(12),
      children: const [
        ListTile(
          leading: Icon(Icons.person),
          title: Text('Hagliberto'),
          subtitle: Text('admin'),
        ),
        ListTile(
          leading: Icon(Icons.person_outline),
          title: Text('Hagliberto'),
          subtitle: Text('usuário'),
        ),
      ],
    );
  }
}

class _PermissionsTab extends StatelessWidget {
  const _PermissionsTab();

  @override
  Widget build(BuildContext context) {
    // TODO: gerenciar janelas de acesso por dispositivo/horário
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Permissões por horário/dispositivo'),
          const SizedBox(height: 12),
          FilledButton(onPressed: () {}, child: const Text('Criar regra')),
        ],
      ),
    );
  }
}

class _KeysTab extends StatelessWidget {
  const _KeysTab();

  @override
  Widget build(BuildContext context) {
    // TODO: rotação/revogação de chaves simétricas por device
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const ListTile(
            leading: Icon(Icons.vpn_key),
            title: Text('dev-101'),
            subtitle: Text('Chave: ••••abcd  |  Última rotação: 2025-09-01'),
            trailing: Icon(Icons.more_vert),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            icon: const Icon(Icons.autorenew),
            label: const Text('Rotacionar chaves'),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
