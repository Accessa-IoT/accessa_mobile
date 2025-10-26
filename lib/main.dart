import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // kDebugMode
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'screens/home_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/devices/devices_screen.dart';
import 'screens/devices/device_detail_screen.dart';
import 'screens/history/history_screen.dart';
import 'screens/admin/admin_screen.dart';
import 'screens/devtools/mqtt_tester.dart';

import 'services/storage.dart';
import 'services/auth_service.dart';
import 'services/mqtt_config.dart';
import 'services/mqtt_service.dart';

// ===== chave global do Navigator =====
final GlobalKey<NavigatorState> _navKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Storage.init();
  await dotenv.load(fileName: '.env');

  // logs úteis
  // ignore: avoid_print
  print('MQTT_HOST=${dotenv.env['MQTT_HOST']}');
  // ignore: avoid_print
  print('MQTT_USER=${dotenv.env['MQTT_USER']}');

  final mqttCfg = MqttConfig.fromEnv();
  await MqttService.instance.init(mqttCfg);

  runApp(const AccessaApp());
}

class AccessaApp extends StatelessWidget {
  const AccessaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final logged = AuthService.isLoggedIn();

    return MaterialApp(
      title: '🔐 Accessa',
      debugShowCheckedModeBanner: false,
      navigatorKey: _navKey, // ← importante
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: logged ? '/devices' : '/',
      routes: {
        '/': (_) => const HomeScreen(),
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/devices': (_) => const DevicesScreen(),
        '/history': (_) => const HistoryScreen(),
        '/admin': (_) => const AdminScreen(),
        '/dev/mqtt': (_) => const MqttTesterPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/device_detail') {
          final args = settings.arguments as Map<String, dynamic>? ?? {};
          return MaterialPageRoute(
            builder: (_) => DeviceDetailScreen(
              deviceId: args['deviceId'] ?? 'dev-000',
              deviceName: args['deviceName'] ?? 'Dispositivo',
            ),
          );
        }
        return null;
      },

      // Overlay para o atalho de debug
      builder: (context, child) {
        return Overlay(
          initialEntries: [
            OverlayEntry(
              builder: (ctx) => Stack(
                children: [
                  if (child != null) child,
                  if (kDebugMode) const _DebugMqttShortcut(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Botão flutuante (mostrado apenas em debug) para abrir o tester de MQTT.
class _DebugMqttShortcut extends StatelessWidget {
  const _DebugMqttShortcut();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Tooltip(
            message: 'MQTT Tester',
            preferBelow: false,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                elevation: 6,
                shadowColor: Colors.black26,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                backgroundColor: const Color(0xFFE7F0FF),
                foregroundColor: const Color(0xFF0B3D91),
              ),
              onPressed: () {
                // usa a chave global para navegar,
                // evitando "context sem Navigator"
                _navKey.currentState?.pushNamed('/dev/mqtt');
              },
              icon: const Icon(Icons.developer_board),
              label: const Text('MQTT Tester'),
            ),
          ),
        ),
      ),
    );
  }
}
