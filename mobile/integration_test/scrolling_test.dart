import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:frontend/main.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Performance profiling test', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: UEventsApp()));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    final listFinder = find.byType(Scrollable).first;

    await binding.traceAction(() async {
      for (int i = 0; i < 6; i++) {
        await tester.drag(listFinder, const Offset(0, -500));
        await tester.pumpAndSettle();
      }
    }, reportKey: 'scrolling_timeline');
  });
}
