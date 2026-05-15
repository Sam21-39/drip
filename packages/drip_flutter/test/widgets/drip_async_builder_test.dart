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
  });
}
