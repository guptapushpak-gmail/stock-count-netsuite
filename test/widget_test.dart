import 'package:flutter_test/flutter_test.dart';
import 'package:netstore_next/main.dart';

void main() {
  testWidgets('app boots', (WidgetTester tester) async {
    await tester.pumpWidget(const StockCountApp());
    expect(find.text('NetSuite Authentication'), findsOneWidget);
  });
}
