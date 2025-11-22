import 'package:flutter/material.dart';
import 'package:accessa_mobile/data/services/history_service.dart';

class HistoryViewModel extends ChangeNotifier {
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;


  String? _user = 'Hagliberto';
  String? _device = 'Laboratório 01';
  String? _result;

  List<Map<String, dynamic>> get items => _items;
  bool get loading => _loading;
  String? get user => _user;
  String? get device => _device;
  String? get result => _result;

  void init() {
    reload();
  }

  Future<void> reload() async {
    _loading = true;
    notifyListeners();
    
    final data = await HistoryService.load();
    _items = data;
    _loading = false;
    notifyListeners();
  }

  void setFilters({String? user, String? device, String? result}) {
    _user = user;
    _device = device;
    _result = result;
    notifyListeners();
  }

  List<Map<String, dynamic>> get filteredItems {
    return _items.where((e) {
      final okUser = _user == null || e['user'] == _user;
      final okDev = _device == null || e['device'] == _device;
      final okRes = _result == null || e['result'] == _result;
      return okUser && okDev && okRes;
    }).toList();
  }
}
