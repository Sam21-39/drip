import 'package:drip_core/drip_core.dart';
import 'package:test/test.dart';

class TestListener implements DripListener {
  int callCount = 0;
  @override
  void onStateChanged() {
    callCount++;
  }
}

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

    test('R-1.3: addListener (subscribe) called when state changes', () async {
      final state = dripState(0);
      final listener = TestListener();

      state.subscribe(listener);
      state.write(1);

      await Future.microtask(() {}); // microtask flush for batch
      expect(listener.callCount, 1);
    });

    test('R-1.4: removeListener (unsubscribe) prevents further calls',
        () async {
      final state = dripState(0);
      final listener = TestListener();

      state.subscribe(listener);
      state.unsubscribe(listener);
      state.write(1);

      await Future.microtask(() {});
      expect(listener.callCount, 0);
    });

    test('R-1.5: removeListener on unregistered listener does not throw', () {
      final state = dripState(0);
      final listener = TestListener();

      expect(() => state.unsubscribe(listener), returnsNormally);
    });

    test('R-1.6: subscribe on computed called when source changes', () async {
      final state = dripState(0);
      final computed = DripComputed(() => state.value * 2);
      final listener = TestListener();

      computed.subscribe(listener);
      // read to initialize and subscribe to source
      expect(computed.value, 0);

      state.write(1);

      await Future.microtask(() {});
      expect(listener.callCount, 1);
      expect(computed.value, 2);
    });

    test('R-1.7: value getter returns current value', () {
      final state = dripState(42);
      DripReadable<int> r = state;
      expect(r.value, 42);
    });
  });
}
