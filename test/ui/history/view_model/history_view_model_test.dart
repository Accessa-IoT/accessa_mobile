import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:accessa_mobile/data/services/storage.dart';
import 'package:accessa_mobile/ui/history/view_model/history_view_model.dart';

void main() {
  group('HistoryViewModel', () {
    late HistoryViewModel vm;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await Storage.init();
      vm = HistoryViewModel();
    });

    test('initial state is correct', () {
      expect(vm.items, isEmpty);
      expect(vm.loading, isTrue); // Starts loading
      expect(vm.user, 'Hagliberto');
      expect(vm.device, 'Laboratório 01');
      expect(vm.result, isNull);
    });

    test('init loads items', () async {
      // Act
      vm.init();

      // Wait for async load (simulated by just waiting a bit or pumping if it was widget test, but here we can await reload if we could, but init is void.
      // However, reload is async. We can call reload directly to await it.)
      await vm.reload();

      // Assert
      expect(vm.items, isNotEmpty);
      expect(vm.loading, isFalse);
    });

    test('setFilters updates filters and notifies listeners', () {
      bool notified = false;
      vm.addListener(() => notified = true);

      vm.setFilters(user: 'NewUser', device: 'NewDevice', result: 'sucesso');

      expect(vm.user, 'NewUser');
      expect(vm.device, 'NewDevice');
      expect(vm.result, 'sucesso');
      expect(notified, isTrue);
    });

    test('filteredItems returns filtered list', () async {
      await vm.reload(); // Load default items

      // Default filters are Hagliberto, Lab 01, any result
      final filtered = vm.filteredItems;

      expect(filtered.every((e) => e['user'] == 'Hagliberto'), isTrue);
      expect(filtered.every((e) => e['device'] == 'Laboratório 01'), isTrue);
    });
  });
}
