import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:accessa_mobile/services/storage.dart';
import 'package:accessa_mobile/services/device_service.dart';

void main() {
  // Garante binding inicializado para usar SharedPreferences em teste
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    // Zera o "banco" em memória antes de cada teste
    SharedPreferences.setMockInitialValues({});
    await Storage.init();
  });

  test('DeviceService.load retorna lista padrão quando não há dados salvos', () async {
    // Act
    final devices = await DeviceService.load();

    // Assert
    expect(devices.length, 3);
    expect(devices[0]['id'], 'dev-101');
    expect(devices[0]['name'], 'Laboratório 01');
    expect(devices[0]['status'], 'online');
  });

  test('DeviceService.add adiciona um novo dispositivo à lista', () async {
    // Arrange
    final newDevice = {
      'id': 'dev-200',
      'name': 'Sala de Reunião',
      'status': 'offline',
    };

    // Act
    await DeviceService.add(newDevice);
    final devices = await DeviceService.load();

    // Assert
    expect(devices.length, 4); // 3 defaults + 1 novo
    expect(
      devices.any((d) => d['id'] == 'dev-200' && d['name'] == 'Sala de Reunião'),
      isTrue,
    );
  });
}
