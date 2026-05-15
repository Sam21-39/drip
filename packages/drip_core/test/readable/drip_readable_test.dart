import 'package:drip_core/drip_core.dart';
import 'package:test/test.dart';

void main() {
  group('DripReadable', () {
    test('R-1.1: DripState is assignable to DripReadable', () {
      DripReadable<int> r = dripState(0);
      expect(r.value, 0);
    });

    test('R-1.2: DripComputed is assignable to DripReadable', () {
      DripReadable<int> r = DripComputed(() => 0);
      expect(r.value, 0);
    });

    test('R-1.3: addListener called when state changes', () async {
      final state = dripState(0);
      int callCount = 0;

      state.addListener(() => callCount++);
      state.write(1);

      await Future.microtask(() {}); // microtask flush for batch
      expect(callCount, 1);
    });

    test('R-1.4: removeListener prevents further calls', () async {
      final state = dripState(0);
      int callCount = 0;
      void listener() => callCount++;

      state.addListener(listener);
      state.removeListener(listener);
      state.write(1);

      await Future.microtask(() {});
      expect(callCount, 0);
    });

    test('R-1.5: removeListener on unregistered listener does not throw', () {
      final state = dripState(0);
      expect(() => state.removeListener(() {}), returnsNormally);
    });

    test('R-1.6: addListener on computed called when source changes', () async {
      final state = dripState(0);
      final computed = DripComputed(() => state.value * 2);
      int callCount = 0;

      computed.addListener(() => callCount++);
      // read to initialize and subscribe to source
      expect(computed.value, 0);

      state.write(1);

      await Future.microtask(() {});
      expect(callCount, 1);
      expect(computed.value, 2);
    });

    test('R-1.7: value getter returns current value', () {
      final state = dripState(42);
      DripReadable<int> r = state;
      expect(r.value, 42);
    });

    test('R-1.8: Liskov substitution - mock implementation works', () async {
      final mock = MockReadable(10);
      expect(mock.value, 10);

      int calls = 0;
      mock.addListener(() => calls++);
      mock.notify();

      expect(calls, 1);
    });
  });
}

class MockReadable<T> implements DripReadable<T> {
  @override
  final T value;
  final List<VoidCallback> _listeners = [];

  MockReadable(this.value);

  @override
  void addListener(VoidCallback listener) => _listeners.add(listener);

  @override
  void removeListener(VoidCallback listener) => _listeners.remove(listener);

  void notify() {
    for (final l in _listeners) {
      l();
    }
  }
}
