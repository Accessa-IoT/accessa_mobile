import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttTesterScreen extends StatefulWidget {
  const MqttTesterScreen({super.key});

  @override
  State<MqttTesterScreen> createState() => _MqttTesterScreenState();
}

class _MqttTesterScreenState extends State<MqttTesterScreen> {
  MqttClient? _client;
  StreamSubscription? _sub;
  bool _connecting = false;
  bool _connected = false;

  final _topicCtrl = TextEditingController(text: 'accessa/devices/teste1/up');
  final _payloadCtrl = TextEditingController(text: '{"ping": true}');
  MqttQos _qos = MqttQos.atLeastOnce;
  bool _retain = false;

  final List<String> _logs = <String>[];
  void _log(String msg) {
    setState(() => _logs.insert(0, '[${DateTime.now().toIso8601String()}] $msg'));
  }

  // Lê do .env (com defaults amigáveis)
  String get _host => dotenv.maybeGet('MQTT_HOST') ?? '';
  int get _wsPort => int.tryParse(dotenv.maybeGet('MQTT_WS_PORT') ?? '') ?? 8884;
  String get _wsPath => dotenv.maybeGet('MQTT_WS_PATH') ?? '/mqtt';
  int get _tlsPort => int.tryParse(dotenv.maybeGet('MQTT_TLS_PORT') ?? '') ?? 8883;
  String get _user => dotenv.maybeGet('MQTT_USER') ?? '';
  String get _pass => dotenv.maybeGet('MQTT_PASS') ?? '';
  String get _prefix => dotenv.maybeGet('MQTT_CLIENT_PREFIX') ?? 'accessa';

  String get _clientId {
    final rnd = Random().nextInt(0xFFFFFF).toRadixString(16).padLeft(6, '0');
    return '${_prefix}_tester_$rnd';
  }

  Future<void> _connect() async {
    if (_host.isEmpty) {
      _log('❌ MQTT_HOST não definido no .env');
      return;
    }
    if (_connecting || _connected) return;

    setState(() => _connecting = true);
    _log('🔌 Conectando…');

    try {
      late MqttClient client;

      if (kIsWeb) {
        // Web precisa de WebSocket seguro (WSS)
        final url = 'wss://$_host:$_wsPort$_wsPath';
        client = MqttBrowserClient(url, _clientId);
      } else {
        // Nativo/desktop: TLS tradicional na porta 8883
        final c = MqttServerClient(_host, _clientId);
        c.port = _tlsPort;
        c.secure = true;
        c.onBadCertificate = (_) => true; // HiveMQ Cloud usa CA válida, mas deixamos flexível
        client = c;
      }

      client.logging(on: false);
      client.setProtocolV311(); // Compatível com HiveMQ Cloud plano free
      client.keepAlivePeriod = 30;
      client.autoReconnect = true;
      client.onConnected = () => _log('✅ Conectado');
      client.onDisconnected = () {
        _log('🔌 Desconectado');
        setState(() => _connected = false);
      };
      client.onSubscribed = (t) => _log('📡 Subscribed => $t');
      client.onUnsubscribed = (t) => _log('📴 Unsubscribed => $t');

      final connMess = MqttConnectMessage()
          .withClientIdentifier(_clientId)
          .authenticateAs(_user, _pass)
          .keepAliveFor(30)
          .startClean()
          .withWillQos(MqttQos.atMostOnce);

      client.connectionMessage = connMess;

      final status = await client.connect();
      if (status?.state == MqttConnectionState.connected) {
        setState(() {
          _client = client;
          _connected = true;
        });

        _sub?.cancel();
        _sub = client.updates?.listen((events) {
          for (final MqttReceivedMessage msg in events) {
            final MqttPublishMessage rec = msg.payload as MqttPublishMessage;
            final pt =
                MqttPublishPayload.bytesToStringAsString(rec.payload.message);

            _log('📥 ${msg.topic}  ${_qosToString(rec.payload.header!.qos)}  ${pt}');
          }
        });
      } else {
        _log('❌ Falha na conexão: ${status?.state}');
        client.disconnect();
      }
    } catch (e) {
      _log('❌ Erro de conexão: $e');
    } finally {
      setState(() => _connecting = false);
    }
  }

  Future<void> _disconnect() async {
    try {
      _client?.disconnect();
    } catch (_) {}
    setState(() {
      _client = null;
      _connected = false;
    });
  }

  Future<void> _subscribe(String topic) async {
    if (!_connected || _client == null) return;
    if (topic.trim().isEmpty) return;
    try {
      _client!.subscribe(topic, _qos);
      _log('➡️  Subscribing $topic ($_qos)');
    } catch (e) {
      _log('❌ Subscribe error: $e');
    }
  }

  Future<void> _unsubscribe(String topic) async {
    if (!_connected || _client == null) return;
    if (topic.trim().isEmpty) return;
    try {
      _client!.unsubscribe(topic);
      _log('⛔ Unsubscribing $topic');
    } catch (e) {
      _log('❌ Unsubscribe error: $e');
    }
  }

  Future<void> _publish(String topic, String payload) async {
    if (!_connected || _client == null) return;
    if (topic.trim().isEmpty) return;
    try {
      // Se for um JSON válido, mantém bonito, senão manda string crua
      String data = payload;
      try {
        data = jsonEncode(jsonDecode(payload));
      } catch (_) {}

      final builder = MqttClientPayloadBuilder();
      builder.addUTF8String(data);
      _client!.publishMessage(topic, _qos, builder.payload!, retain: _retain);
      _log('📤 $topic ($_qos, retain=$_retain)  $data');
    } catch (e) {
      _log('❌ Publish error: $e');
    }
  }

  String _qosToString(MqttQos q) {
    switch (q) {
      case MqttQos.atMostOnce:
        return 'QoS0';
      case MqttQos.atLeastOnce:
        return 'QoS1';
      case MqttQos.exactlyOnce:
        return 'QoS2';
      default:
        return '$q';
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _client?.disconnect();
    _topicCtrl.dispose();
    _payloadCtrl.dispose();
    super.dispose();
    _client = null;
  }

  @override
  Widget build(BuildContext context) {
    final hintWs = kIsWeb ? ' (WebSocket wss)' : ' (TLS nativo)';

    return Scaffold(
      appBar: AppBar(
        title: const Text('MQTT Tester • Accessa'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(
              child: Text(
                _connected ? 'Conectado$hintWs' : 'Desconectado$hintWs',
                style: TextStyle(
                  color: _connected ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Bloco de conexão (.env preview)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Wrap(
                  runSpacing: 8,
                  spacing: 16,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text('Host: $_host'),
                    Text(kIsWeb ? 'WSS: $_wsPort$_wsPath' : 'TLS: $_tlsPort'),
                    Text('User: ${_user.isEmpty ? '(vazio)' : _user}'),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: (!_connected && !_connecting) ? _connect : null,
                      icon: const Icon(Icons.power_settings_new),
                      label: Text(_connecting ? 'Conectando…' : 'Conectar'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _connected ? _disconnect : null,
                      icon: const Icon(Icons.link_off),
                      label: const Text('Desconectar'),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Publicar/Assinar
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _topicCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Tópico',
                              hintText: 'ex.: accessa/devices/teste1/up',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        DropdownButton<MqttQos>(
                          value: _qos,
                          onChanged: (v) => setState(() => _qos = v ?? _qos),
                          items: const [
                            DropdownMenuItem(
                                value: MqttQos.atMostOnce, child: Text('QoS0')),
                            DropdownMenuItem(
                                value: MqttQos.atLeastOnce, child: Text('QoS1')),
                            DropdownMenuItem(
                                value: MqttQos.exactlyOnce, child: Text('QoS2')),
                          ],
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            const Text('Retain'),
                            Switch(
                              value: _retain,
                              onChanged: (v) => setState(() => _retain = v),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _payloadCtrl,
                      minLines: 1,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Payload (JSON ou texto)',
                        hintText: '{"ping": true}',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        FilledButton.icon(
                          onPressed: _connected
                              ? () => _publish(_topicCtrl.text, _payloadCtrl.text)
                              : null,
                          icon: const Icon(Icons.send),
                          label: const Text('Publicar'),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: _connected
                              ? () => _subscribe(_topicCtrl.text)
                              : null,
                          icon: const Icon(Icons.podcasts),
                          label: const Text('Assinar'),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: _connected
                              ? () => _unsubscribe(_topicCtrl.text)
                              : null,
                          icon: const Icon(Icons.podcasts_outlined),
                          label: const Text('Unsubscribe'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Logs
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Card(
                child: ListView.separated(
                  reverse: false,
                  padding: const EdgeInsets.all(12),
                  itemCount: _logs.length,
                  separatorBuilder: (_, __) => const Divider(height: 8),
                  itemBuilder: (_, i) => Text(
                    _logs[i],
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
