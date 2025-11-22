import 'package:flutter/material.dart';

class MqttScreen extends StatelessWidget {
  const MqttScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MQTT')),
      body: const Center(child: Text('MQTT Screen (Restored)')),
    );
  }
}
