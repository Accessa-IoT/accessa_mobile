import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:accessa_mobile/data/services/storage.dart';
import 'package:accessa_mobile/data/services/device_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await Storage.init();
  });

  test(
    'DeviceService.load retorna lista padrão quando não há dados salvos',
    () async {
      final devices = await DeviceService.load();

      expect(devices.length, 3);
      expect(devices[0]['id'], 'dev-101');
      expect(devices[0]['name'], 'Laboratório 01');
      expect(devices[0]['status'], 'online');
    },
  );

  test('DeviceService.add adiciona um novo dispositivo à lista', () async {
    final newDevice = {
      'id': 'dev-200',
      'name': 'Sala de Reunião',
      'status': 'offline',
    };

    await DeviceService.add(newDevice);
    final devices = await DeviceService.load();

    expect(devices.length, 4);
    expect(
      devices.any(
        (d) => d['id'] == 'dev-200' && d['name'] == 'Sala de Reunião',
      ),
      isTrue,
    );
  });
}
