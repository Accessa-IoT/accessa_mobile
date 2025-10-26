import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'screens/home_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/devices/devices_screen.dart';
import 'screens/devices/device_detail_screen.dart';
import 'screens/history/history_screen.dart';
import 'screens/admin/admin_screen.dart';

import 'services/storage.dart';
import 'services/auth_service.dart';

import 'screens/devtools/mqtt_tester.dart';

// MQTT (config + client)
import 'services/mqtt_config.dart';
import 'services/mqtt_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa storage local (preferências)
  await Storage.init();

  // Carrega variáveis de ambiente (.env) – usado para endpoints/credenciais MQTT
  // Obs: o arquivo ".env" precisa estar listado em `flutter.assets` no pubspec.yaml
  await dotenv.load(fileName: '.env');

  print('MQTT_HOST=${dotenv.env['MQTT_HOST']}');
  print('MQTT_USER=${dotenv.env['MQTT_USER']}');
  

  // Prepara configuração MQTT (sem conectar ainda; conexão é on-demand nas telas)
  final mqttCfg = MqttConfig.fromEnv();
  await MqttService.instance.init(mqttCfg);

  runApp(const AccessaApp());
}

class AccessaApp extends StatelessWidget {
  const AccessaApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Se houver sessão válida, inicia direto na lista de dispositivos
    final logged = AuthService.isLoggedIn();

    return MaterialApp(
      title: '🔐 Accessa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // se logado, começa direto em /devices
      initialRoute: logged ? '/devices' : '/',
      routes: {
        '/': (_) => const HomeScreen(),
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/devices': (_) => const DevicesScreen(),
        '/history': (_) => const HistoryScreen(),
        '/admin': (_) => const AdminScreen(),
        // '/dev/mqtt': (_) => const MqttTesterScreen(),
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
    );
  }
}
