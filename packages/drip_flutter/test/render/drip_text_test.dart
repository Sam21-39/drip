import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drip_core/drip_core.dart';
import 'package:drip_flutter/drip_flutter.dart';

Finder findDripText(String text) {
  return find.byElementPredicate((element) {
    if (element.widget is DripText && element.renderObject is RenderParagraph) {
      final rp = element.renderObject as RenderParagraph;
      return rp.text.toPlainText() == text;
    }
    return false;
  });
}

void main() {
  group('DripText Widget Tests', () {
    testWidgets('T-1.1: Initial state.value rendered on first pump',
        (tester) async {
      final state = dripState('Hello');
      await tester.pumpWidget(MaterialApp(
        home: Directionality(
          textDirection: TextDirection.ltr,
          child: DripText(state),
        ),
      ));

      expect(findDripText('Hello'), findsOneWidget);
    });

    testWidgets('T-1.2: state.write() updates rendered text', (tester) async {
      final state = dripState('Hello');
      await tester.pumpWidget(MaterialApp(
        home: Directionality(
          textDirection: TextDirection.ltr,
          child: DripText(state),
        ),
      ));

      state.write('World');
      await tester.pump();

      expect(findDripText('World'), findsOneWidget);
    });

    testWidgets('T-1.3: ZERO build() calls during state update',
        (tester) async {
      final state = dripState('Initial');
      var buildCount = 0;

      await tester.pumpWidget(MaterialApp(
        home: Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) {
              buildCount++;
              return DripText(state);
            },
          ),
        ),
      ));

      expect(buildCount, 1);
      expect(findDripText('Initial'), findsOneWidget);

      state.write('Updated');
      await tester.pump();

      expect(buildCount, 1,
          reason:
              'DripText should update without rebuilding its parent Builder');
      expect(findDripText('Updated'), findsOneWidget);
    });

    testWidgets('T-1.4: Binding deregistered on widget unmount',
        (tester) async {
      final state = dripState('Hello');

      await tester.pumpWidget(MaterialApp(
        home: Directionality(
          textDirection: TextDirection.ltr,
          child: DripText(state),
        ),
      ));

      // Remove the widget
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));

      // Writing to state should not trigger any RenderObject calls (which would fail if unmounted)
      state.write('World');
      await tester.pump();

      // Success is defined as no crash/assertion failure
    });

    testWidgets('T-1.6: Multiple DripText bound to same state all update',
        (tester) async {
      final state = dripState('Shared');

      await tester.pumpWidget(MaterialApp(
        home: Directionality(
          textDirection: TextDirection.ltr,
          child: Column(
            children: [
              DripText(state),
              DripText(state),
              DripText(state),
            ],
          ),
        ),
      ));

      state.write('Update All');
      await tester.pump();

      expect(findDripText('Update All'), findsNWidgets(3));
    });

    testWidgets('T-1.8: Empty string write updates correctly', (tester) async {
      final state = dripState('Something');
      await tester.pumpWidget(MaterialApp(
        home: Directionality(
          textDirection: TextDirection.ltr,
          child: DripText(state),
        ),
      ));

      state.write('');
      await tester.pump();

      expect(findDripText(''), findsOneWidget);
    });
  });
}
