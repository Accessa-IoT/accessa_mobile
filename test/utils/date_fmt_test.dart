import 'package:flutter_test/flutter_test.dart';
import 'package:accessa_mobile/utils/date_fmt.dart';

void main() {
  group('fmtDateTime', () {
    test('formata data e hora no padrão DD/MM/AAAA - HH:MM:SS', () {
      // Arrange
      final dt = DateTime(2025, 11, 24, 15, 30, 45); // 24/11/2025 15:30:45

      // Act
      final result = fmtDateTime(dt);

      // Assert
      expect(result, '24/11/2025 - 15:30:45');
    });

    test('garante zero à esquerda em dia, mês e horário menores que 10', () {
      // Arrange
      final dt = DateTime(2025, 1, 2, 3, 4, 5); // 02/01/2025 03:04:05

      // Act
      final result = fmtDateTime(dt);

      // Assert
      expect(result, '02/01/2025 - 03:04:05');
    });

    test('preenche o ano sempre com quatro dígitos', () {
      // Arrange
      final dt = DateTime(45, 1, 1, 0, 0, 0); // ano 45 d.C.

      // Act
      final result = fmtDateTime(dt);

      // Assert
      expect(result, '01/01/0045 - 00:00:00');
    });
  });
}
