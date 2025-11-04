import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:accessa_mobile/data/services/storage.dart';
import 'package:accessa_mobile/data/services/history_service.dart';

void main() {
  group('HistoryService', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      await Storage.init();
    });

    test('load returns seeded list when none stored and parses DateTime', () async {
      final items = await HistoryService.load();
      expect(items, isNotNull);
      expect(items.length, 12);
      final first = items.first;
      expect(first.containsKey('when'), isTrue);
      expect(first['when'], isA<DateTime>());
      expect(first.containsKey('user'), isTrue);
    });

    test('save persists DateTime as ISO string and load returns DateTime', () async {
      final now = DateTime.now();
      final ev = [
        {
          'when': now,
          'user': 'Tester',
          'device': 'Unit 1',
          'result': 'sucesso'
        }
      ];
      await HistoryService.save(ev);

      final loaded = await HistoryService.load();
      expect(loaded.length, 1);
      final w = loaded[0]['when'] as DateTime;
      expect(w.toIso8601String(), now.toIso8601String());
      expect(loaded[0]['user'], 'Tester');
    });

    test('append inserts event at start of list', () async {
      // start with seed
      final before = await HistoryService.load();
      final beforeLen = before.length;

      final ev = {
        'when': DateTime.now(),
        'user': 'AppendUser',
        'device': 'AppendDevice',
        'result': 'sucesso'
      };
      await HistoryService.append(ev);

      final after = await HistoryService.load();
      expect(after.length, beforeLen + 1);
      expect(after.first['user'], 'AppendUser');
    });
  });
}
