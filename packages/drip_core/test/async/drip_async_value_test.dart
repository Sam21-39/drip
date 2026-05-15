import 'package:drip_core/drip_core.dart';
import 'package:test/test.dart';

void main() {
  group('DripAsyncValue', () {
    test('AV-1.1: DripLoading.isLoading is true', () {
      const state = DripLoading<int>();
      expect(state.isLoading, true);
      expect(state.hasData, false);
      expect(state.hasError, false);
    });

    test('AV-1.2: DripData.hasData is true', () {
      const state = DripData<int>(42);
      expect(state.hasData, true);
      expect(state.isLoading, false);
      expect(state.hasError, false);
    });

    test('AV-1.3: DripError.hasError is true', () {
      final state = DripError<int>(Exception('test'), StackTrace.empty);
      expect(state.hasError, true);
      expect(state.isLoading, false);
      expect(state.hasData, false);
    });

    test('AV-1.4: DripLoading.dataOrNull returns null when no previous data',
        () {
      const state = DripLoading<int>();
      expect(state.dataOrNull, null);
    });

    test('AV-1.5: DripLoading.dataOrNull returns previousData if set', () {
      const state = DripLoading<int>(previousData: 42);
      expect(state.dataOrNull, 42);
    });

    test('AV-1.6: DripData.dataOrNull returns value', () {
      const state = DripData<int>(42);
      expect(state.dataOrNull, 42);
    });

    test('AV-1.7: DripError.dataOrNull returns previousData if set', () {
      final state =
          DripError<int>(Exception(), StackTrace.empty, previousData: 42);
      expect(state.dataOrNull, 42);
    });

    test('AV-1.8: getDataOr returns fallback when no data', () {
      const state = DripLoading<int>();
      expect(state.getDataOr(0), 0);
    });

    test('AV-1.9: getDataOr returns value when DripData', () {
      const state = DripData<int>(42);
      expect(state.getDataOr(0), 42);
    });

    test('AV-1.10: map() on DripData transforms value', () {
      const state = DripData<int>(42);
      final mapped = state.map((v) => v.toString());
      expect(mapped, isA<DripData<String>>());
      expect(mapped.dataOrNull, '42');
    });

    test('AV-1.11: map() on DripLoading preserves loading, maps previousData',
        () {
      const state = DripLoading<int>(previousData: 42);
      final mapped = state.map((v) => v.toString());
      expect(mapped, isA<DripLoading<String>>());
      expect(mapped.dataOrNull, '42');

      const stateNull = DripLoading<int>();
      final mappedNull = stateNull.map((v) => v.toString());
      expect(mappedNull, isA<DripLoading<String>>());
      expect(mappedNull.dataOrNull, null);
    });

    test('AV-1.12: map() on DripError preserves error, maps previousData', () {
      final state =
          DripError<int>(Exception('test'), StackTrace.empty, previousData: 42);
      final mapped = state.map((v) => v.toString());
      expect(mapped, isA<DripError<String>>());
      expect(mapped.dataOrNull, '42');
      expect((mapped as DripError).error.toString(), contains('test'));
    });

    test('AV-1.13: hasPreviousData false when DripLoading() with no data', () {
      const state = DripLoading<int>();
      expect(state.hasPreviousData, false);
    });

    test('AV-1.14: hasPreviousData true when DripLoading(previousData: x)', () {
      const state = DripLoading<int>(previousData: 42);
      expect(state.hasPreviousData, true);
    });

    test('AV-1.15: Switch is exhaustive', () {
      // Dart compiler checks exhaustiveness for sealed classes
      const DripAsyncValue<int> state = DripData(0);
      final result = switch (state) {
        DripLoading() => 'loading',
        DripData() => 'data',
        DripError() => 'error',
      };
      expect(result, 'data');
    });
  });
}
