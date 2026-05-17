import 'package:drip_core/drip_core.dart';
import 'package:test/test.dart';

void main() {
  group('DripAsyncValue', () {
    test('AV-1.1: DripAsyncLoading.isLoading is true', () {
      const state = DripAsyncLoading<int>();
      expect(state.isLoading, true);
      expect(state.hasData, false);
      expect(state.hasError, false);
    });

    test('AV-1.2: DripAsyncData.hasData is true', () {
      const state = DripAsyncData<int>(42);
      expect(state.hasData, true);
      expect(state.isLoading, false);
      expect(state.hasError, false);
    });

    test('AV-1.3: DripAsyncError.hasError is true', () {
      final state = DripAsyncError<int>(Exception('test'), StackTrace.empty);
      expect(state.hasError, true);
      expect(state.isLoading, false);
      expect(state.hasData, false);
    });

    test(
        'AV-1.4: DripAsyncLoading.dataOrNull returns null when no previous data',
        () {
      const state = DripAsyncLoading<int>();
      expect(state.dataOrNull, null);
    });

    test('AV-1.5: DripAsyncLoading.dataOrNull returns previousData if set', () {
      const state = DripAsyncLoading<int>(previousData: 42);
      expect(state.dataOrNull, 42);
    });

    test('AV-1.6: DripAsyncData.dataOrNull returns value', () {
      const state = DripAsyncData<int>(42);
      expect(state.dataOrNull, 42);
    });

    test('AV-1.7: DripAsyncError.dataOrNull returns previousData if set', () {
      final state =
          DripAsyncError<int>(Exception(), StackTrace.empty, previousData: 42);
      expect(state.dataOrNull, 42);
    });

    test('AV-1.8: getDataOr returns fallback when no data', () {
      const state = DripAsyncLoading<int>();
      expect(state.getDataOr(0), 0);
    });

    test('AV-1.9: getDataOr returns value when DripAsyncData', () {
      const state = DripAsyncData<int>(42);
      expect(state.getDataOr(0), 42);
    });

    test('AV-1.10: map() on DripAsyncData transforms value', () {
      const state = DripAsyncData<int>(42);
      final mapped = state.map((v) => v.toString());
      expect(mapped, isA<DripAsyncData<String>>());
      expect(mapped.dataOrNull, '42');
    });

    test(
        'AV-1.11: map() on DripAsyncLoading preserves loading, maps previousData',
        () {
      const state = DripAsyncLoading<int>(previousData: 42);
      final mapped = state.map((v) => v.toString());
      expect(mapped, isA<DripAsyncLoading<String>>());
      expect(mapped.dataOrNull, '42');

      const stateNull = DripAsyncLoading<int>();
      final mappedNull = stateNull.map((v) => v.toString());
      expect(mappedNull, isA<DripAsyncLoading<String>>());
      expect(mappedNull.dataOrNull, null);
    });

    test('AV-1.12: map() on DripAsyncError preserves error, maps previousData',
        () {
      final state = DripAsyncError<int>(Exception('test'), StackTrace.empty,
          previousData: 42);
      final mapped = state.map((v) => v.toString());
      expect(mapped, isA<DripAsyncError<String>>());
      expect(mapped.dataOrNull, '42');
      expect((mapped as DripAsyncError).error.toString(), contains('test'));
    });

    test('AV-1.13: hasPreviousData false when DripAsyncLoading() with no data',
        () {
      const state = DripAsyncLoading<int>();
      expect(state.hasPreviousData, false);
    });

    test('AV-1.14: hasPreviousData true when DripAsyncLoading(previousData: x)',
        () {
      const state = DripAsyncLoading<int>(previousData: 42);
      expect(state.hasPreviousData, true);
    });

    test('AV-1.15: Switch is exhaustive', () {
      // Dart compiler checks exhaustiveness for sealed classes
      const DripAsyncValue<int> state = DripAsyncData(0);
      final result = switch (state) {
        DripAsyncLoading() => 'loading',
        DripAsyncData() => 'data',
        DripAsyncError() => 'error',
      };
      expect(result, 'data');
    });

    test('AV-1.16: hasPreviousData for DripAsyncError', () {
      final errorWithData =
          DripAsyncError<int>(Exception(), StackTrace.empty, previousData: 42);
      expect(errorWithData.hasPreviousData, true);

      final errorWithoutData =
          DripAsyncError<int>(Exception(), StackTrace.empty);
      expect(errorWithoutData.hasPreviousData, false);
    });
  });
}
