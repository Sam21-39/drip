import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drip_core/drip_core.dart';
import 'package:drip_flutter/drip_flutter.dart';

void main() {
  group('DripAsyncBuilder', () {
    testWidgets('Shows loading widget initially', (WidgetTester tester) async {
      final state = DripAsync<String>(); // Starts as DripLoading

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: DripAsyncBuilder<String>(
            source: state,
            loading: (context, prev) => const Text('loading'),
            data: (context, value) => Text(value),
            error: (context, err, st, prev) => const Text('error'),
          ),
        ),
      );

      expect(find.text('loading'), findsOneWidget);
    });

    testWidgets('Shows data widget when resolved', (WidgetTester tester) async {
      final state = DripAsync<String>();
      state.setData('loaded data');

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: DripAsyncBuilder<String>(
            source: state,
            loading: (context, prev) => const Text('loading'),
            data: (context, value) => Text(value),
            error: (context, err, st, prev) => const Text('error'),
          ),
        ),
      );

      expect(find.text('loaded data'), findsOneWidget);
    });

    testWidgets('Shows error widget when failed', (WidgetTester tester) async {
      final state = DripAsync<String>();
      state.setError(Exception('failed'), StackTrace.empty);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: DripAsyncBuilder<String>(
            source: state,
            loading: (context, prev) => const Text('loading'),
            data: (context, value) => Text(value),
            error: (context, err, st, prev) => Text('Error: $err'),
          ),
        ),
      );

      expect(find.text('Error: Exception: failed'), findsOneWidget);
    });

    testWidgets('Loading widget receives previousData during refresh',
        (WidgetTester tester) async {
      final state = DripAsync<String>();
      state.setData('old data');
      state.setLoading();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: DripAsyncBuilder<String>(
            source: state,
            loading: (context, prev) => Text('Loading... prev: $prev'),
            data: (context, value) => Text(value),
            error: (context, err, st, prev) => const Text('error'),
          ),
        ),
      );

      expect(find.text('Loading... prev: old data'), findsOneWidget);
    });

    testWidgets('Error widget receives previousData',
        (WidgetTester tester) async {
      final state = DripAsync<String>();
      state.setData('old data');
      state.setError(Exception('failed'), StackTrace.empty);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: DripAsyncBuilder<String>(
            source: state,
            loading: (context, prev) => const Text('loading'),
            data: (context, value) => Text(value),
            error: (context, err, st, prev) => Text('Error... prev: $prev'),
          ),
        ),
      );

      expect(find.text('Error... prev: old data'), findsOneWidget);
    });

    testWidgets('Listener deregistered on unmount',
        (WidgetTester tester) async {
      final state = DripAsync<String>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: DripAsyncBuilder<String>(
            source: state,
            loading: (context, prev) => const Text('loading'),
            data: (context, value) => Text(value),
            error: (context, err, st, prev) => const Text('error'),
          ),
        ),
      );

      expect(state.subscribers.length, 1);

      await tester.pumpWidget(const SizedBox());

      expect(state.subscribers.length, 0);
    });

    testWidgets('didUpdateWidget switches listeners and current value',
        (WidgetTester tester) async {
      final first = DripAsync<String>()..setData('first');
      final second = DripAsync<String>()..setData('second');

      Widget build(DripAsync<String> source) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: DripAsyncBuilder<String>(
            source: source,
            loading: (context, prev) => const Text('loading'),
            data: (context, value) => Text(value),
            error: (context, err, st, prev) => const Text('error'),
          ),
        );
      }

      await tester.pumpWidget(build(first));
      expect(find.text('first'), findsOneWidget);
      expect(first.subscribers.length, 1);
      expect(second.subscribers.length, 0);

      await tester.pumpWidget(build(second));
      expect(find.text('second'), findsOneWidget);
      expect(first.subscribers.length, 0);
      expect(second.subscribers.length, 1);
    });

    testWidgets('responds to all transition types after mount',
        (WidgetTester tester) async {
      final state = DripAsync<String>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: DripAsyncBuilder<String>(
            source: state,
            loading: (context, prev) => Text('loading:$prev'),
            data: (context, value) => Text('data:$value'),
            error: (context, err, st, prev) => Text('error:$prev'),
          ),
        ),
      );

      expect(find.text('loading:null'), findsOneWidget);

      state.setData('ready');
      await tester.pumpAndSettle();
      expect(find.text('data:ready'), findsOneWidget);

      state.setLoading();
      await tester.pumpAndSettle();
      expect(find.text('loading:ready'), findsOneWidget);

      state.setError(Exception('boom'), StackTrace.empty);
      await tester.pumpAndSettle();
      expect(find.text('error:ready'), findsOneWidget);

      state.setData('recovered');
      await tester.pumpAndSettle();
      expect(find.text('data:recovered'), findsOneWidget);
    });
  });
}
