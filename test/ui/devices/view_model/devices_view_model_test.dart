import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:accessa_mobile/data/services/storage.dart';
import 'package:accessa_mobile/ui/devices/view_model/devices_view_model.dart';

void main() {
  group('DevicesViewModel', () {
    late DevicesViewModel vm;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await Storage.init();
      vm = DevicesViewModel();
    });

    test('initial state is correct', () {
      expect(vm.devices, isEmpty);
      expect(vm.loading, isFalse);
    });

    test('loadDevices populates devices list', () async {
      // Act
      await vm.loadDevices();

      // Assert
      expect(vm.loading, isFalse);
      expect(vm.devices, isNotEmpty);
      expect(vm.devices.length, 3); // Default devices
    });
  });
}
