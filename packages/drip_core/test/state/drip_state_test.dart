import 'package:drip_core/drip_core.dart';
import 'package:test/test.dart';

void main() {
  group('DripState', () {
    test('1.1 Initial value returned on first read', () {
      final state = dripState(0);
      expect(state.value, 0);
    });

    test('1.2 write() updates the value', () {
      final state = dripState(0);
      state.write(5);
      expect(state.value, 5);
    });

    test('1.3 write() with equal value is no-op', () async {
      final state = dripState(0);
      var notifications = 0;
      DripEffect(() {
        state.value;
        notifications++;
      });

      await Future.microtask(() {}); // Flush initial run
      expect(notifications, 1);

      state.write(0);
      await Future.microtask(() {});
      expect(notifications, 1); // Should not notify
    });

    test('1.4 write() with different value notifies subscribers', () async {
      final state = dripState(0);
      var notifications = 0;
      DripEffect(() {
        state.value;
        notifications++;
      });

      await Future.microtask(() {});
      expect(notifications, 1);

      state.write(1);
      await Future.microtask(() {});
      expect(notifications, 2);
    });

    test('1.5 Multiple synchronous writes batch into one notification',
        () async {
      final state = dripState(0);
      var notifications = 0;
      DripEffect(() {
        state.value;
        notifications++;
      });

      await Future.microtask(() {});
      expect(notifications, 1);

      state.write(1);
      state.write(2);
      state.write(3);

      await Future.microtask(() {});
      expect(notifications, 2); // Exactly one more run
    });

    test('1.6 Custom Equality prevents notification', () async {
      // Identity equality for a list (semantically equal but different reference)
      final state = DripState<List<int>>([1], equality: IdentityEquality());
      var notifications = 0;
      DripEffect(() {
        state.value;
        notifications++;
      });

      await Future.microtask(() {});
      expect(notifications, 1);

      // Same values, but different list instance
      state.write([1]);
      await Future.microtask(() {});
      expect(notifications, 2); // Notified because identity changed

      // Same instance
      final current = state.value;
      state.write(current);
      await Future.microtask(() {});
      expect(notifications, 2); // No notification
    });

    test('1.8 Read inside async gap does NOT register dependency', () async {
      final a = dripState(0);
      final b = dripState(0);
      var runCount = 0;

      DripEffect(() async {
        a.value; // Tracked
        runCount++;
        await Future.value();
        b.value; // NOT tracked
      });

      await Future.microtask(() {});
      expect(runCount, 1);

      // Update a -> should trigger re-run
      a.write(1);
      await Future.microtask(() {});
      expect(runCount, 2);

      // Update b -> should NOT trigger re-run
      b.write(1);
      await Future.microtask(() {});
      expect(runCount, 2);
    });
  });
}
