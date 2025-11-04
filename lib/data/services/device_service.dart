import 'package:accessa_mobile/data/services/storage.dart';

class DeviceService {
  static const _kDevices = 'devices.items';

  static final List<Map<String, String>> _defaults = [
    {'id': 'dev-101', 'name': 'Laboratório 01', 'status': 'online'},
    {'id': 'dev-102', 'name': 'Cowork Sala A', 'status': 'offline'},
    {'id': 'dev-103', 'name': 'Armário 07', 'status': 'online'},
  ];

  static Future<List<Map<String, String>>> load() async {
    final data = Storage.getJsonList(_kDevices);
    if (data == null) {
      await save(_defaults);
      return List<Map<String, String>>.from(_defaults);
    }
    return data.map((e) => Map<String, String>.from(e as Map)).toList();
  }

  static Future<void> save(List<Map<String, String>> items) async {
    await Storage.setJson(_kDevices, items);
  }

  static Future<void> add(Map<String, String> item) async {
    final items = await load();
    items.add(item);
    await save(items);
  }
}
