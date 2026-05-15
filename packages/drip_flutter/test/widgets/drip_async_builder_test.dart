import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart' show CircularProgressIndicator;
import 'package:flutter_test/flutter_test.dart';
import 'package:drip_core/drip_core.dart';
import 'package:drip_flutter/drip_flutter.dart';

void main() {
  group('DripAsyncBuilder', () {
    testWidgets('DAB-1.1 & DAB-1.2: Shows loading widget',
        (WidgetTester tester) async {
      final state = DripAsync<String>(); // Starts as DripLoading

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: DripAsyncBuilder<String>(
            state: state,
            data: (context, value) => Text(value),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('DAB-1.3: Shows data widget', (WidgetTester tester) async {
      final state = DripAsync<String>();
      state.setData('loaded data');

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: DripAsyncBuilder<String>(
            state: state,
            data: (context, value) => Text(value),
          ),
        ),
      );

      expect(find.text('loaded data'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('DAB-1.4 & DAB-1.5: Shows error widget',
        (WidgetTester tester) async {
      final state = DripAsync<String>();
      state.setError(Exception('failed'), StackTrace.empty);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: DripAsyncBuilder<String>(
            state: state,
            data: (context, value) => Text(value),
          ),
        ),
      );

      expect(find.text('Exception: failed'), findsOneWidget);
    });

    testWidgets('DAB-1.6: Loading widget receives previousData',
        (WidgetTester tester) async {
      final state = DripAsync<String>();
      state.setData('old data');
      state.setLoading();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: DripAsyncBuilder<String>(
            state: state,
            loading: (context, prev) => Text('Loading... prev: $prev'),
            data: (context, value) => Text(value),
          ),
        ),
      );

      expect(find.text('Loading... prev: old data'), findsOneWidget);
    });

    testWidgets('DAB-1.7: Error widget receives previousData',
        (WidgetTester tester) async {
      final state = DripAsync<String>();
      state.setData('old data');
      state.setError(Exception('failed'), StackTrace.empty);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: DripAsyncBuilder<String>(
            state: state,
            error: (context, err, st, prev) => Text('Error... prev: $prev'),
            data: (context, value) => Text(value),
          ),
        ),
      );

      expect(find.text('Error... prev: old data'), findsOneWidget);
    });

    testWidgets('DAB-1.8: Refresh: DripData -> DripLoading -> DripData',
        (WidgetTester tester) async {
      final state = DripAsync<String>();
      state.setData('1');

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: DripAsyncBuilder<String>(
            state: state,
            loading: (context, prev) => Text('Loading... prev: $prev'),
            data: (context, value) => Text('Data: $value'),
          ),
        ),
      );

      expect(find.text('Data: 1'), findsOneWidget);

      state.setLoading();
      await tester.pumpAndSettle();
      expect(find.text('Loading... prev: 1'), findsOneWidget);

      state.setData('2');
      await tester.pumpAndSettle();
      expect(find.text('Data: 2'), findsOneWidget);
    });

    testWidgets('DAB-1.9: Listener deregistered on unmount',
        (WidgetTester tester) async {
      final state = DripAsync<String>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: DripAsyncBuilder<String>(
            state: state,
            data: (context, value) => Text(value),
          ),
        ),
      );

      expect(state.subscribers.length, 1);

      await tester.pumpWidget(const SizedBox());

      expect(state.subscribers.length, 0);
    });

    testWidgets('DAB-1.10: didUpdateWidget switches to different DripAsync',
        (WidgetTester tester) async {
      final state1 = DripAsync<String>()..setData('1');
      final state2 = DripAsync<String>()..setData('2');

      Widget buildWidget(DripAsync<String> state) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: DripAsyncBuilder<String>(
            state: state,
            data: (context, value) => Text(value),
          ),
        );
      }

      await tester.pumpWidget(buildWidget(state1));
      expect(find.text('1'), findsOneWidget);
      expect(state1.subscribers.length, 1);
      expect(state2.subscribers.length, 0);

      await tester.pumpWidget(buildWidget(state2));
      expect(find.text('2'), findsOneWidget);
      expect(state1.subscribers.length, 0);
      expect(state2.subscribers.length, 1);
    });

    testWidgets(
        'DAB-1.11: Builder does not rebuild when sibling DripAsync changes',
        (WidgetTester tester) async {
      final state1 = DripAsync<String>()..setData('1');
      final state2 = DripAsync<String>()..setData('2');
      int buildCount1 = 0;
      int buildCount2 = 0;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Column(
            children: [
              DripAsyncBuilder<String>(
                state: state1,
                data: (context, value) {
                  buildCount1++;
                  return Text(value);
                },
              ),
              DripAsyncBuilder<String>(
                state: state2,
                data: (context, value) {
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

      state1.setData('1 updated');
      await tester.pumpAndSettle();

      expect(buildCount1, 2);
      expect(buildCount2, 1); // State 2 did not rebuild
    });
  });
}
