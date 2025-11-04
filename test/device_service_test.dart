import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:accessa_mobile/data/services/storage.dart';
import 'package:accessa_mobile/data/services/device_service.dart';

void main() {
  group('DeviceService', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      await Storage.init();
    });

    test('load returns defaults when none stored', () async {
      final items = await DeviceService.load();
      expect(items, isNotNull);
      // defaults contain 3 entries with known ids
      expect(items.length, 3);
      expect(items.any((e) => e['id'] == 'dev-101'), isTrue);
      expect(items.any((e) => e['id'] == 'dev-102'), isTrue);
      expect(items.any((e) => e['id'] == 'dev-103'), isTrue);
    });

    test('save persists provided list and load returns it', () async {
      final custom = [
        {'id': 'x1', 'name': 'X One', 'status': 'offline'}
      ];
      await DeviceService.save(custom);
      final loaded = await DeviceService.load();
      expect(loaded.length, 1);
      expect(loaded[0]['id'], 'x1');
      expect(loaded[0]['name'], 'X One');
    });

    test('add appends an item to existing list', () async {
      // start with defaults
      final initial = await DeviceService.load();
      final initialLen = initial.length;

      final newItem = {'id': 'new-999', 'name': 'Nova', 'status': 'online'};
      await DeviceService.add(newItem);

      final after = await DeviceService.load();
      expect(after.length, initialLen + 1);
      expect(after.any((e) => e['id'] == 'new-999'), isTrue);
    });
  });
}
