import 'package:flutter_test/flutter_test.dart';
import 'package:accessa_mobile/utils/date_fmt.dart';

void main() {
  test('fmtDateTime formats local DateTime with leading zeros', () {
    final dt = DateTime(2020, 1, 2, 3, 4, 5); // local time
    expect(fmtDateTime(dt), '02/01/2020 - 03:04:05');
  });

  test('fmtDateTime formats typical midday time', () {
    final dt = DateTime(2023, 11, 4, 15, 30, 59);
    expect(fmtDateTime(dt), '04/11/2023 - 15:30:59');
  });
}
