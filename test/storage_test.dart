import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:accessa_mobile/data/services/storage.dart';

void main() {
  group('Storage', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      await Storage.init();
    });

    test('setJson and getJsonMap work for Map', () async {
      final map = {'a': 1, 'b': 'two'};
      final ok = await Storage.setJson('m', map);
      expect(ok, isTrue);

      final got = Storage.getJsonMap('m');
      expect(got, isNotNull);
      expect(got!['a'], 1);
      expect(got['b'], 'two');
    });

    test('setJson and getJsonList work for List', () async {
      final list = [
        {'x': 1},
        {'y': 'z'}
      ];
      final ok = await Storage.setJson('l', list);
      expect(ok, isTrue);

      final got = Storage.getJsonList('l');
      expect(got, isNotNull);
      expect(got!.length, 2);
      expect((got[0] as Map)['x'], 1);
      expect((got[1] as Map)['y'], 'z');
    });

    test('getJsonMap/getJsonList return null for missing keys', () {
      expect(Storage.getJsonMap('no'), isNull);
      expect(Storage.getJsonList('no'), isNull);
    });

    test('setBool/getBool and defaults', () async {
      final ok = await Storage.setBool('b', true);
      expect(ok, isTrue);
      expect(Storage.getBool('b'), isTrue);

      // missing key returns default
      expect(Storage.getBool('missing'), isFalse);
      expect(Storage.getBool('missing', def: true), isTrue);
    });

    test('remove removes key', () async {
      await Storage.setBool('r', true);
      expect(Storage.getBool('r'), isTrue);
      await Storage.remove('r');
      expect(Storage.getBool('r'), isFalse);
    });
  });
}
