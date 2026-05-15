import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drip_core/drip_core.dart';
import 'package:drip_flutter/drip_flutter.dart';

void main() {
  group('DripBuilder', () {
    testWidgets(
        'DB-1.1 & DB-1.3: Initial value rendered correctly with DripState',
        (WidgetTester tester) async {
      final state = dripState('initial');

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: DripBuilder<String>(
            value: state,
            builder: (context, value) => Text(value),
          ),
        ),
      );

      expect(find.text('initial'), findsOneWidget);
    });

    testWidgets('DB-1.2: state.write() triggers builder rebuild',
        (WidgetTester tester) async {
      final state = dripState('initial');

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: DripBuilder<String>(
            value: state,
            builder: (context, value) => Text(value),
          ),
        ),
      );

      state.write('updated');
      await tester.pumpAndSettle();

      expect(find.text('updated'), findsOneWidget);
    });

    testWidgets('DB-1.4: Works with DripComputed', (WidgetTester tester) async {
      final state = dripState(2);
      final computed = DripComputed(() => state.value * 2);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: DripBuilder<int>(
            value: computed,
            builder: (context, value) => Text(value.toString()),
          ),
        ),
      );

      expect(find.text('4'), findsOneWidget);

      state.write(3);
      await tester.pumpAndSettle();

      expect(find.text('6'), findsOneWidget);
    });

    testWidgets('DB-1.5: Works with DripAsync (via DripReadable)',
        (WidgetTester tester) async {
      final asyncState = DripAsync<String>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: DripBuilder<DripAsyncValue<String>>(
            value: asyncState,
            builder: (context, value) {
              if (value is DripLoading) return const Text('loading');
              if (value is DripData<String>) return Text(value.value);
              return const Text('error');
            },
          ),
        ),
      );

      expect(find.text('loading'), findsOneWidget);

      asyncState.setData('loaded');
      await tester.pumpAndSettle();

      expect(find.text('loaded'), findsOneWidget);
    });

    testWidgets(
        'DB-1.6 & DB-1.9: Unrelated state change does NOT trigger rebuild, sibling isolation',
        (WidgetTester tester) async {
      final state1 = dripState('one');
      final state2 = dripState('two');
      int buildCount1 = 0;
      int buildCount2 = 0;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Column(
            children: [
              DripBuilder<String>(
                value: state1,
                builder: (context, value) {
                  buildCount1++;
                  return Text(value);
                },
              ),
              DripBuilder<String>(
                value: state2,
                builder: (context, value) {
                  buildCount2++;
                  return Text(value);
                },
              ),
            ],
          ),
        ),
      );

      expect(buildCount1, 1);
      expect(buildCount2, 1);

      state1.write('one updated');
      await tester.pumpAndSettle();

      expect(buildCount1, 2);
      expect(buildCount2, 1); // State 2 did not rebuild
    });

    testWidgets('DB-1.7: Listener deregistered on widget dispose',
        (WidgetTester tester) async {
      final state = dripState('initial');

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: DripBuilder<String>(
            value: state,
            builder: (context, value) => Text(value),
          ),
        ),
      );

      expect(state.subscribers.length, 1);

      // Unmount the widget
      await tester.pumpWidget(const SizedBox());

      expect(state.subscribers.length, 0);
    });

    testWidgets('DB-1.8: didUpdateWidget switches to different source',
        (WidgetTester tester) async {
      final state1 = dripState('one');
      final state2 = dripState('two');

      Widget buildWidget(DripState<String> state) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: DripBuilder<String>(
            value: state,
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

    testWidgets(
        'DB-1.10: Nested DripBuilder only rebuilds inner on inner state',
        (WidgetTester tester) async {
      final outerState = dripState('outer');
      final innerState = dripState('inner');
      int outerBuildCount = 0;
      int innerBuildCount = 0;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: DripBuilder<String>(
            value: outerState,
            builder: (context, outerValue) {
              outerBuildCount++;
              return DripBuilder<String>(
                value: innerState,
                builder: (context, innerValue) {
                  innerBuildCount++;
                  return Text('$outerValue $innerValue');
                },
              );
            },
          ),
        ),
      );

      expect(outerBuildCount, 1);
      expect(innerBuildCount, 1);

      innerState.write('inner updated');
      await tester.pumpAndSettle();

      expect(outerBuildCount, 1);
      expect(innerBuildCount, 2);
    });
  });
}
