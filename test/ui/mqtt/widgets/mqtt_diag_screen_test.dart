import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accessa_mobile/ui/mqtt/widgets/mqtt_diag_screen.dart';

void main() {
  testWidgets('MqttDiagScreen renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: MqttDiagScreen()));

    expect(find.text('MQTT Diag'), findsOneWidget);
    expect(find.text('MQTT Diag Screen (Restored)'), findsOneWidget);
  });
}
