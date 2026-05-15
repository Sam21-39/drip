import 'dart:async';
import 'package:drip_core/drip_core.dart';
import 'package:test/test.dart';

void main() {
  group('DripAsync', () {
    test('AS-1.1: Initial state is DripLoading with null previous data', () {
      final state = DripAsync<int>();
      expect(state.value, isA<DripLoading<int>>());
      expect(state.value.dataOrNull, null);
    });

    test('AS-1.2: setData(v) transitions to DripData', () {
      final state = DripAsync<int>();
      state.setData(42);
      expect(state.value, isA<DripData<int>>());
      expect(state.value.dataOrNull, 42);
    });

    test('AS-1.3: setLoading() after setData() preserves previous data', () {
      final state = DripAsync<int>();
      state.setData(42);
      state.setLoading();
      expect(state.value, isA<DripLoading<int>>());
      expect(state.value.dataOrNull, 42);
    });

    test('AS-1.4: setError() preserves previous data', () {
      final state = DripAsync<int>();
      state.setData(42);
      state.setError(Exception(), StackTrace.empty);
      expect(state.value, isA<DripError<int>>());
      expect(state.value.dataOrNull, 42);
    });

    test('AS-1.6: run() transitions: loading -> data on success', () async {
      final state = DripAsync<int>();
      await state.run(() async => 42);
      expect(state.value, isA<DripData<int>>());
      expect(state.value.dataOrNull, 42);
    });

    test('AS-1.7: run() transitions: loading -> error on failure', () async {
      final state = DripAsync<int>();
      await state.run(() async => throw Exception('failed'));
      expect(state.value, isA<DripError<int>>());
      expect((state.value as DripError).error.toString(), contains('failed'));
    });

    test('AS-1.8: run() preserves previous data in loading state', () async {
      final state = DripAsync<int>();
      state.setData(42);

      final completer = Completer<int>();
      final runFuture = state.run(() => completer.future);

      expect(state.value, isA<DripLoading<int>>());
      expect(state.value.dataOrNull, 42);

      completer.complete(43);
      await runFuture;
    });

    test('AS-1.9: Concurrent run() - second cancels first', () async {
      final state = DripAsync<int>();

      final completer1 = Completer<int>();
      final completer2 = Completer<int>();

      // First run starts
      final run1 = state.run(() => completer1.future);

      // Second run starts immediately
      final run2 = state.run(() => completer2.future);

      // Complete first
      completer1.complete(1);
      await run1;

      // State should still be loading because run2 is active
      expect(state.value, isA<DripLoading<int>>());

      // Complete second
      completer2.complete(2);
      await run2;

      // State should be data from second
      expect(state.value, isA<DripData<int>>());
      expect(state.value.dataOrNull, 2);
    });

    test('AS-1.10: fromFuture() - starts loading, transitions to data',
        () async {
      final completer = Completer<int>();
      final state = DripAsync.fromFuture(completer.future);

      expect(state.value, isA<DripLoading<int>>());
      completer.complete(42);

      await Future.microtask(() {}); // allow run to finish
      expect(state.value, isA<DripData<int>>());
      expect(state.value.dataOrNull, 42);
    });

    test('AS-1.12: fromStream() - first event produces data state', () async {
      final controller = StreamController<int>();
      final state = DripAsync.fromStream(controller.stream, scope: DripScope());

      expect(state.value, isA<DripLoading<int>>());
      controller.add(42);

      await Future.microtask(() {});
      expect(state.value, isA<DripData<int>>());
      expect(state.value.dataOrNull, 42);
      controller.close();
    });

    test('AS-1.16: fromStream() - subscription cancelled on scope dispose',
        () async {
      final controller = StreamController<int>();
      final scope = DripScope();
      DripAsync.fromStream(controller.stream, scope: scope);

      expect(controller.hasListener, true);
      scope.dispose();
      expect(controller.hasListener, false);
    });

    test('AS-1.17: DripAsync notifies listeners on every state transition',
        () async {
      final state = DripAsync<int>();
      int calls = 0;
      state.addListener(() => calls++);

      state.setData(42);
      await Future.microtask(() {});
      expect(calls, 1);

      state.setLoading();
      await Future.microtask(() {});
      expect(calls, 2);
    });
  });
}
