import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/devices/devices_screen.dart';
import 'screens/devices/device_detail_screen.dart';
import 'screens/history/history_screen.dart';
import 'screens/admin/admin_screen.dart';
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
      // se logado, começa direto em /devices
      initialRoute: logged ? '/devices' : '/',
      routes: {
        '/': (_) => const HomeScreen(),
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/devices': (_) => const DevicesScreen(),
        '/history': (_) => const HistoryScreen(),
        '/admin': (_) => const AdminScreen(),
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
