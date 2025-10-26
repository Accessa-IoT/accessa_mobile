import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';

class MqttTesterPage extends StatefulWidget {
  const MqttTesterPage({super.key});
  @override
  State<MqttTesterPage> createState() => _MqttTesterPageState();
}

class _MqttTesterPageState extends State<MqttTesterPage> {
  MqttBrowserClient? _client;
  StreamSubscription? _sub;

  final _topicCtrl = TextEditingController(text: 'accessa/devices/teste1/up');
  final _payloadCtrl = TextEditingController(text: '{"ping": true}');
  final List<String> _logs = [];

  bool _connected = false;
  bool _connecting = false;
  bool _retain = false;
  MqttQos _qos = MqttQos.atLeastOnce;

  // ---- ENV HELPERS ----------------------------------------------------------
  String get _endpointWss => dotenv.get('MQTT_ENDPOINT_WSS', fallback: '');
  String get _host => dotenv.get('MQTT_HOST', fallback: '');
  int get _wsPort =>
      int.tryParse(dotenv.get('MQTT_WS_PORT', fallback: '8884')) ?? 8884;
  String get _wsPath => dotenv.get('MQTT_WS_PATH', fallback: '/mqtt');
  String get _user => dotenv.get('MQTT_USER', fallback: '');
  String get _pass => dotenv.get('MQTT_PASS', fallback: '');

  String get _effectiveUrl {
    if (_endpointWss.isNotEmpty) return _endpointWss.trim();
    if (_host.isEmpty) return '';
    // Garante que o path tenha barra inicial
    final path = _wsPath.startsWith('/') ? _wsPath : '/$_wsPath';
    return 'wss://$_host:$_wsPort$path';
  }

  // ---- LOG ------------------------------------------------------------------
  void _log(String m) {
    setState(() {
      _logs.insert(0, '[${DateTime.now().toIso8601String()}] $m');
    });
  }

  // Gera clientId seguro (evita RangeError em web quando max==0)
  String _newClientId() {
    final rnd = Random.secure();
    final part = rnd.nextInt(0x7fffffff); // 31 bits positivos
    return 'web_${DateTime.now().millisecondsSinceEpoch}_$part';
    // Ex.: web_1730000000000_123456789
  }

  // ---- CONNECT --------------------------------------------------------------
  Future<void> _connect() async {
    if (_connected || _connecting) return;

    final url = _effectiveUrl;
    if (url.isEmpty) {
      _log('❌ Variáveis do .env não definidas. Configure MQTT_ENDPOINT_WSS OU MQTT_HOST/MQTT_WS_PORT/MQTT_WS_PATH.');
      return;
    }

    // Aviso comum: porta errada (8883) para Web
    if (url.contains(':8883/')) {
      _log('⚠️ Você está apontando para 8883 (MQTT TCP/TLS). Para WebSocket use 8884 + /mqtt. URL atual: $url');
    }

    final clientId = _newClientId();
    _client = MqttBrowserClient(url, clientId);
    _client!.keepAlivePeriod = 20;
    _client!.onConnected = () {
      _log('✅ Conectado (clientId=$clientId)');
    };
    _client!.onDisconnected = () {
      _log('🔴 Desconectado');
      setState(() => _connected = false);
    };
    _client!.onSubscribed = (t) => _log('📌 Assinado: $t');
    _client!.onSubscribeFail = (t) => _log('⚠️ Falha ao assinar: $t');
    _client!.pongCallback = () => _log('🏓 PONG');

    // logging(...) returns void — call it separately instead of inside the cascade
    _client!.logging(on: false);

    // Mensagem CONNECT (auth)
    _client!.connectionMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .authenticateAs(_user, _pass)
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);

    try {
      _connecting = true;
      _log('Conectando em $url como ${_user.isEmpty ? "(sem usuário)" : _user} ...');

      final res = await _client!.connect();
      // res pode ser null em alguns erros do browser; tratamos ambos:
      if (res != null &&
          res.returnCode == MqttConnectReturnCode.connectionAccepted) {
        setState(() => _connected = true);
        _attachListener();
      } else {
        _log('❌ CONNECT falhou: ${res?.returnCode ?? "desconhecido"}');
        _client!.disconnect();
      }
    } catch (e) {
      _log('❌ Erro de conexão: $e');
      _client?.disconnect();
    } finally {
      _connecting = false;
    }
  }

  void _attachListener() {
    _sub?.cancel();
    // Em web, `updates` nunca é null após connect; ainda assim, protegemos.
    final stream = _client!.updates;
    if (stream == null) return;

    _sub = stream.listen((events) {
      for (final evt in events) {
        final MqttReceivedMessage rec = evt;
        final MqttPublishMessage payloadMsg = rec.payload as MqttPublishMessage;
        final data =
            MqttPublishPayload.bytesToStringAsString(payloadMsg.payload.message);
        final qosName = payloadMsg.header?.qos.name ?? 'unknown';
        _log('📥 ${rec.topic} => $data (QoS: $qosName)');
      }
    });
  }

  Future<void> _disconnect() async {
    await _sub?.cancel();
    _sub = null;
    _client?.disconnect();
    setState(() => _connected = false);
  }

  void _subscribe() {
    if (!_connected) return;
    final topic = _topicCtrl.text.trim();
    if (topic.isEmpty) return;
    _client!.subscribe(topic, _qos);
  }

  void _publish() {
    if (!_connected) return;
    final topic = _topicCtrl.text.trim();
    if (topic.isEmpty) return;

    final builder = MqttClientPayloadBuilder()..addUTF8String(_payloadCtrl.text);
    _client!.publishMessage(topic, _qos, builder.payload!, retain: _retain);
    _log('📤 Publicado em $topic');
  }

  @override
  void dispose() {
    _sub?.cancel();
    _client?.disconnect();
    _topicCtrl.dispose();
    _payloadCtrl.dispose();
    super.dispose();
  }

  // ---- UI -------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final url = _effectiveUrl.isEmpty ? '(defina no .env)' : _effectiveUrl;
    return Scaffold(
      appBar: AppBar(
        title: const Text('MQTT Tester • Accessa'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(
              child: Text(
                'URL: $url   User: ${_user.isEmpty ? "(vazio)" : _user}',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _connected ? null : _connect,
                icon: const Icon(Icons.power_settings_new),
                label: Text(_connected
                    ? (_connecting ? 'Conectando...' : 'Conectado')
                    : 'Conectar'),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: _connected ? _disconnect : null,
                icon: const Icon(Icons.link_off),
                label: const Text('Desconectar'),
              ),
              const SizedBox(width: 16),
              Text(_connected
                  ? '🟢 Conectado'
                  : (_connecting
                      ? '🟡 Conectando…'
                      : '🔴 Desconectado (WebSocket wss)')),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _topicCtrl,
            decoration: const InputDecoration(
              labelText: 'Tópico',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              DropdownButton<MqttQos>(
                value: _qos,
                onChanged: (v) => setState(() => _qos = v!),
                items: const [
                  DropdownMenuItem(
                      value: MqttQos.atMostOnce, child: Text('QoS0')),
                  DropdownMenuItem(
                      value: MqttQos.atLeastOnce, child: Text('QoS1')),
                  DropdownMenuItem(
                      value: MqttQos.exactlyOnce, child: Text('QoS2')),
                ],
              ),
              const SizedBox(width: 16),
              Switch.adaptive(
                value: _retain,
                onChanged: (v) => setState(() => _retain = v),
              ),
              const Text('Retain'),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            minLines: 2,
            maxLines: 4,
            controller: _payloadCtrl,
            decoration: const InputDecoration(
              labelText: 'Payload (JSON ou texto)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _publish,
                icon: const Icon(Icons.send),
                label: const Text('Publicar'),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: _subscribe,
                icon: const Icon(Icons.subscriptions),
                label: const Text('Assinar'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Logs'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black12),
              borderRadius: BorderRadius.circular(8),
            ),
            height: 240,
            child: ListView.builder(
              reverse: true,
              itemCount: _logs.length,
              itemBuilder: (_, i) => Text(
                _logs[i],
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Dica: Em ambiente Web, use sempre WSS (porta 8884) e path /mqtt no HiveMQ Cloud.',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
