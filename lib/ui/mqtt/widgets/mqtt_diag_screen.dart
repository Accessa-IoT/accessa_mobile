import 'package:flutter/material.dart';

class MqttDiagScreen extends StatelessWidget {
  const MqttDiagScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MQTT Diag')),
      body: const Center(child: Text('MQTT Diag Screen (Restored)')),
    );
  }
}
