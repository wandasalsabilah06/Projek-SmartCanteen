import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart';

void main() {
  testWidgets('Smart Canteen app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartCanteenApp());
    expect(find.byType(SmartCanteenApp), findsOneWidget);
  });
}
