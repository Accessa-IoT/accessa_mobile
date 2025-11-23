import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accessa_mobile/ui/mqtt/widgets/mqtt_screen.dart';

void main() {
  testWidgets('MqttScreen renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: MqttScreen()));

    expect(find.text('MQTT'), findsOneWidget);
    expect(find.text('MQTT Screen (Restored)'), findsOneWidget);
  });
}
