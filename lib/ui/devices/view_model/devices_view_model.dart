import 'package:flutter/material.dart';
import 'package:accessa_mobile/data/services/device_service.dart';

class DevicesViewModel extends ChangeNotifier {
  List<Map<String, String>> _devices = [];
  bool _loading = false;

  List<Map<String, String>> get devices => _devices;
  bool get loading => _loading;

  Future<void> loadDevices() async {
    _loading = true;
    notifyListeners();

    try {
      _devices = await DeviceService.load();
    } catch (e) {

    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
