import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart';

void main() {
  testWidgets('UEvents app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const UEventsApp());
    expect(find.text('UEvents'), findsOneWidget);
  });
}
