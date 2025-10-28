import 'package:flutter/material.dart';

// Telas existentes
import 'screens/home_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/devices/devices_screen.dart';
import 'screens/devices/device_detail_screen.dart';
import 'screens/history/history_screen.dart';
import 'screens/admin/admin_screen.dart';

// Telas de integração e diagnóstico MQTT
import 'screens/mqtt/mqtt_screen.dart';
import 'screens/mqtt/mqtt_diag_screen.dart';

// Serviços locais
import 'services/storage.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Storage.init();
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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // Se logado, vai direto à tela de dispositivos
      initialRoute: logged ? '/devices' : '/',
      routes: {
        '/': (_) => const HomeScreen(),
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/devices': (_) => const DevicesScreen(),
        '/device_detail': (context) {
          final args = ModalRoute.of(context)!.settings.arguments;
          final deviceArgs = (args is Map<String, String>) ? args : <String, String>{};
          return DeviceDetailScreen(device: deviceArgs);
        },
        '/history': (_) => const HistoryScreen(),
        '/admin': (_) => const AdminScreen(),
        '/mqtt': (_) => const MqttScreen(),          // tela de controle MQTT
        '/mqtt_diag': (_) => const MqttDiagScreen(), // tela de diagnóstico MQTT
      },
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (_) => const Scaffold(
          body: Center(child: Text('Página não encontrada')),
        ),
      ),
    );
  }
}
