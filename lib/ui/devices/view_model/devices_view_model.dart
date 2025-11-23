import 'package:flutter/material.dart';
import 'package:accessa_mobile/data/services/device_service.dart';

typedef DeviceLoader = Future<List<Map<String, String>>> Function();

class DevicesViewModel extends ChangeNotifier {
  final DeviceLoader _loader;

  DevicesViewModel({DeviceLoader? loader})
    : _loader = loader ?? DeviceService.load;

  List<Map<String, String>> _devices = [];
  bool _loading = false;

  List<Map<String, String>> get devices => _devices;
  bool get loading => _loading;

  Future<void> loadDevices() async {
    _loading = true;
    notifyListeners();

    try {
      _devices = await _loader();
    } catch (e) {
      _devices = [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
