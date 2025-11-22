import 'package:flutter/material.dart';

import 'ui/home/widgets/home_screen.dart';
import 'ui/auth/widgets/login_screen.dart';
import 'ui/auth/widgets/register_screen.dart';
import 'ui/devices/widgets/devices_screen.dart';
import 'ui/devices/widgets/device_detail_screen.dart';
import 'ui/history/widgets/history_screen.dart';
import 'ui/admin/widgets/admin_screen.dart';

import 'ui/mqtt/widgets/mqtt_screen.dart';
import 'ui/mqtt/widgets/mqtt_diag_screen.dart';

import 'data/services/storage.dart';
import 'data/services/auth_service.dart';

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
      initialRoute: logged ? '/devices' : '/',
      routes: {
        '/': (_) => const HomeScreen(),
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/devices': (_) => const DevicesScreen(),
        '/device_detail': (context) {
          final args = ModalRoute.of(context)!.settings.arguments;
          final deviceArgs = (args is Map<String, String>)
              ? args
              : <String, String>{};
          return DeviceDetailScreen(device: deviceArgs);
        },
        '/history': (_) => const HistoryScreen(),
        '/admin': (_) => const AdminScreen(),
        '/mqtt': (_) => const MqttScreen(),
        '/mqtt_diag': (_) => const MqttDiagScreen(),
      },
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (_) =>
            const Scaffold(body: Center(child: Text('Página não encontrada'))),
      ),
    );
  }
}
