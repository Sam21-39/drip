import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drip_core/drip_core.dart';
import 'package:drip_flutter/drip_flutter.dart';

Future<void> _pumpDrip(WidgetTester tester) async {
  await tester.pump();
  await tester.pump();
}

void main() {
  group('DripBuilder', () {
    testWidgets('Initial value rendered correctly',
        (WidgetTester tester) async {
      final state = dripState('initial');

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: DripBuilder<String>(
            source: state,
            builder: (context, value) => Text(value),
          ),
        ),
      );

      expect(find.text('initial'), findsOneWidget);
    });

    testWidgets('state.write() triggers builder rebuild',
        (WidgetTester tester) async {
      final state = dripState('initial');

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: DripBuilder<String>(
            source: state,
            builder: (context, value) => Text(value),
          ),
        ),
      );

      state.write('updated');
      await _pumpDrip(tester);

      expect(find.text('updated'), findsOneWidget);
    });

    testWidgets('Equality skip prevents unnecessary rebuilds',
        (WidgetTester tester) async {
      final state = dripState('initial');
      int buildCount = 0;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: DripBuilder<String>(
            source: state,
            builder: (context, value) {
              buildCount++;
              return Text(value);
            },
          ),
        ),
      );

      expect(buildCount, 1);

      // Write same value
      state.write('initial');
      await _pumpDrip(tester);

      expect(buildCount, 1); // No rebuild

      state.write('updated');
      await _pumpDrip(tester);

      expect(buildCount, 2);
    });

    testWidgets('Custom identity function works', (WidgetTester tester) async {
      final state = dripState('initial');
      int buildCount = 0;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: DripBuilder<String>(
            source: state,
            identity: (a, b) => a.length == b.length,
            builder: (context, value) {
              buildCount++;
              return Text(value);
            },
          ),
        ),
      );

      expect(buildCount, 1);

      // Write value with same length
      state.write('abcde');
      state.write('1234567'); // same length as "initial"
      await _pumpDrip(tester);

      expect(buildCount, 1); // No rebuild due to custom identity

      state.write('different');
      await _pumpDrip(tester);

      expect(buildCount, 2);
    });

    testWidgets('Listener deregistered on widget dispose',
        (WidgetTester tester) async {
      final state = dripState('initial');

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: DripBuilder<String>(
            source: state,
            builder: (context, value) => Text(value),
          ),
        ),
      );

      expect(state.subscribers.length, 1);

      // Unmount the widget
      await tester.pumpWidget(const SizedBox());

      expect(state.subscribers.length, 0);
    });

    testWidgets('didUpdateWidget switches to different source',
        (WidgetTester tester) async {
      final state1 = dripState('one');
      final state2 = dripState('two');

      Widget buildWidget(DripState<String> state) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: DripBuilder<String>(
            source: state,
            builder: (context, value) => Text(value),
          ),
        );
      }

      await tester.pumpWidget(buildWidget(state1));
      expect(find.text('one'), findsOneWidget);
      expect(state1.subscribers.length, 1);
      expect(state2.subscribers.length, 0);

      await tester.pumpWidget(buildWidget(state2));
      expect(find.text('two'), findsOneWidget);
      expect(state1.subscribers.length, 0);
      expect(state2.subscribers.length, 1);
    });
  });
}
