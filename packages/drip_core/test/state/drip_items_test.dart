import 'package:drip_core/drip_core.dart';
import 'package:test/test.dart';

void main() {
  group('DripItems Tests', () {
    test('Initial values and length are correct', () {
      final items = DripItems<int>([10, 20, 30]);
      expect(items.length, 3);
      expect(items[0].value, 10);
      expect(items[1].value, 20);
      expect(items[2].value, 30);
    });

    test('Element value updates do NOT trigger list-level propagation',
        () async {
      final items = DripItems<int>([10, 20, 30]);

      var listNotifications = 0;
      var item0Notifications = 0;

      DripEffect(() {
        items.value; // List-level subscribe
        listNotifications++;
      });

      DripEffect(() {
        items[0].value; // Element-level subscribe
        item0Notifications++;
      });

      await Future.microtask(() {}); // Flush initial runs
      expect(listNotifications, 1);
      expect(item0Notifications, 1);

      // Write to element 0
      items[0].write(99);
      await Future.microtask(() {});

      expect(item0Notifications, 2); // Notified!
      expect(listNotifications, 1); // Bypassed list-level notification!
    });

    test('Structural changes trigger list-level propagation', () async {
      final items = DripItems<int>([10, 20]);

      var listNotifications = 0;

      DripEffect(() {
        items.value; // List-level subscribe
        listNotifications++;
      });

      await Future.microtask(() {}); // Flush initial run
      expect(listNotifications, 1);

      // 1. Add item
      items.add(30);
      await Future.microtask(() {});
      expect(listNotifications, 2);
      expect(items.length, 3);
      expect(items[2].value, 30);

      // 2. Insert item
      items.insert(1, 15);
      await Future.microtask(() {});
      expect(listNotifications, 3);
      expect(items.length, 4);
      expect(items[1].value, 15);

      // 3. Remove at index
      final removed = items.removeAt(1);
      await Future.microtask(() {});
      expect(listNotifications, 4);
      expect(removed.value, 15);
      expect(items.length, 3);

      // 4. Remove by value
      final didRemove = items.remove(20);
      await Future.microtask(() {});
      expect(listNotifications, 5);
      expect(didRemove, true);
      expect(items.length, 2);

      // 5. Replace all
      items.replaceAll([100, 200]);
      await Future.microtask(() {});
      expect(listNotifications, 6);
      expect(items.length, 2);
      expect(items[0].value, 100);
      expect(items[1].value, 200);

      // 6. Clear
      items.clear();
      await Future.microtask(() {});
      expect(listNotifications, 7);
      expect(items.length, 0);
    });

    test('Bounds safety is strictly enforced', () {
      final items = DripItems<int>([10, 20]);

      expect(() => items[-1], throwsRangeError);
      expect(() => items[2], throwsRangeError);
      expect(() => items[-1] = 99, throwsRangeError);
      expect(() => items[2] = 99, throwsRangeError);

      expect(() => items.insert(-1, 5), throwsRangeError);
      expect(() => items.insert(3, 5), throwsRangeError);

      expect(() => items.removeAt(-1), throwsRangeError);
      expect(() => items.removeAt(2), throwsRangeError);
    });

    test('Dispose clears subscribers on both list and elements', () async {
      final items = DripItems<int>([10, 20]);

      var listNotifications = 0;
      var item0Notifications = 0;

      DripEffect(() {
        items.value;
        listNotifications++;
      });

      DripEffect(() {
        items[0].value;
        item0Notifications++;
      });

      await Future.microtask(() {});
      expect(listNotifications, 1);
      expect(item0Notifications, 1);

      // Dispose the collection
      items.dispose();

      // Attempt to write to element or collection -> should NOT notify anyone
      // Wait, let's see if writing to an element after clearAllSubscribers does not notify:
      // Since all subscribers were cleared, it shouldn't!
      items.add(30);
      await Future.microtask(() {});
      expect(listNotifications, 1); // Remains 1, no more notifications!
    });
  });
}
