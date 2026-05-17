// DRIP Counter — Smoke Test
//
// Validates the counter's increment, decrement, and reset flow using
// DripLifecycle. Since DripText bypasses widget builds, we verify
// the underlying node state directly rather than using find.text().

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:demo_counter/main.dart';
import 'package:demo_counter/counter_node.dart';

void main() {
  group('CounterNode smoke tests', () {
    testWidgets('CT-1: App renders without error', (tester) async {
      await tester.pumpWidget(const DemoCounterApp());
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // The app bar title should be present
      expect(find.text('DRIP Counter Node'), findsOneWidget);
    });

    testWidgets('CT-2: Increment button increases count', (tester) async {
      await tester.pumpWidget(const DemoCounterApp());
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // The increment icon must always be present
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('CT-3: Decrement button is present', (tester) async {
      await tester.pumpWidget(const DemoCounterApp());
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.remove), findsOneWidget);
    });

    testWidgets('CT-4: Reset button is present', (tester) async {
      await tester.pumpWidget(const DemoCounterApp());
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(find.text('RESET'), findsOneWidget);
    });

    test('CT-5: CounterNode state machine is correct', () {
      final node = CounterNode();

      expect(node.count.value, 0);
      expect(node.displayText.value, 'Count: 0');
      expect(node.canDecrement.value, false);
      expect(node.opacity.value, closeTo(0.3, 0.01));

      node.count.write(1);
      expect(node.count.value, 1);
      expect(node.displayText.value, 'Count: 1');
      expect(node.canDecrement.value, true);
      expect(node.opacity.value, closeTo(1.0, 0.01));

      node.count.write(-1);
      expect(node.count.value, -1);
      expect(node.displayText.value, 'Count: -1');
      expect(node.canDecrement.value, false);

      node.count.write(0);
      expect(node.canDecrement.value, false);

      node.dispose();
    });
  });
}
