import 'package:accessa_mobile/services/storage.dart';

class HistoryService {
  static const _kHistory = 'history.items';

  static List<Map<String, dynamic>> _seed() {
    final now = DateTime.now();
    return List.generate(12, (i) => {
          'when': now.subtract(Duration(hours: i * 3)).toIso8601String(),
          'user': i.isEven ? 'Hagliberto' : 'admin',
          'device': i.isEven ? 'Laboratório 01' : 'Armário 07',
          'result': i % 3 == 0 ? 'falha' : 'sucesso',
        });
  }

  static Future<List<Map<String, dynamic>>> load() async {
    final data = Storage.getJsonList(_kHistory);
    final list = (data ?? _seed());
    // normaliza DateTime
    return list
        .map((e) => {
              ...Map<String, dynamic>.from(e as Map),
              'when': DateTime.parse((e as Map)['when'] as String),
            })
        .toList();
  }

  static Future<void> save(List<Map<String, dynamic>> items) async {
    final enc = items
        .map((e) => {
              ...e,
              'when': (e['when'] as DateTime).toIso8601String(),
            })
        .toList();
    await Storage.setJson(_kHistory, enc);
  }

  static Future<void> append(Map<String, dynamic> ev) async {
    final items = await load();
    items.insert(0, ev);
    await save(items);
  }
}
