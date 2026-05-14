import 'package:flutter_test/flutter_test.dart';
import 'package:drip_flutter/src/list/drip_list.dart';

void main() {
  group('DripList (DRIP-NODE-06)', () {
    test('L-1.1: add() increases length and notifies structural listeners', () {
      final list = DripList<int>([1, 2]);
      var structuralCount = 0;
      list.addStructuralListener(() => structuralCount++);

      list.add(3);

      expect(list.length, 3);
      expect(list.items, [1, 2, 3]);
      expect(structuralCount, 1);
    });

    test('L-1.2: removeAt() decreases length and notifies structural listeners',
        () {
      final list = DripList<int>([1, 2, 3]);
      var structuralCount = 0;
      list.addStructuralListener(() => structuralCount++);

      list.removeAt(1);

      expect(list.length, 2);
      expect(list.items, [1, 3]);
      expect(structuralCount, 1);
    });

    test('L-1.3: []= notifies only the index listener for that index', () {
      final list = DripList<int>([1, 2, 3]);
      var count0 = 0, count1 = 0, count2 = 0;
      var structuralCount = 0;

      list.addIndexListener(0, () => count0++);
      list.addIndexListener(1, () => count1++);
      list.addIndexListener(2, () => count2++);
      list.addStructuralListener(() => structuralCount++);

      list[1] = 10;

      expect(count0, 0);
      expect(count1, 1);
      expect(count2, 0);
      expect(structuralCount, 0); // structural not notified
      expect(list[1], 10);
    });

    test('L-1.4: []= with equal value is no-op', () {
      final list = DripList<int>([1, 2, 3]);
      var count1 = 0;
      list.addIndexListener(1, () => count1++);

      list[1] = 2; // same value

      expect(count1, 0);
    });

    test(
        'L-1.5: insert() at index 0 shifts all existing index listeners up by 1',
        () {
      final list = DripList<int>([1, 2]);
      var count0 = 0, count1 = 0;

      list.addIndexListener(0, () => count0++);
      list.addIndexListener(1, () => count1++);

      list.insert(0, 0);
      // Items are now [0, 1, 2]

      // Update new index 1 (which was previously 0). The listener should have shifted.
      list[1] = 10;
      expect(count0, 1);

      // Update new index 2 (which was previously 1).
      list[2] = 20;
      expect(count1, 1);
    });

    test('L-1.6: removeAt() index shifts remaining index listeners down', () {
      final list = DripList<int>([1, 2, 3]);
      var count1 = 0, count2 = 0;

      list.addIndexListener(1, () => count1++);
      list.addIndexListener(2, () => count2++);

      list.removeAt(0);
      // Items are now [2, 3]

      // Update new index 0 (was 1)
      list[0] = 20;
      expect(count1, 1);

      // Update new index 1 (was 2)
      list[1] = 30;
      expect(count2, 1);
    });

    test('L-1.7: replaceAll() with shorter list removes excess listener sets',
        () {
      final list = DripList<int>([1, 2, 3]);
      list.addIndexListener(2, () {}); // should be removed

      list.replaceAll([10]);

      expect(list.length, 1);
      // Should not throw out of range on index 0
      list[0] = 20;

      // Modifying non-existent index should throw RangeError from underlying list
      expect(() => list[1] = 30, throwsRangeError);
    });

    test(
        'L-1.8: replaceAll() with longer list adds listener sets for new indices',
        () {
      final list = DripList<int>([1]);
      list.replaceAll([10, 20, 30]);

      var count2 = 0;
      list.addIndexListener(2, () => count2++);

      list[2] = 300;
      expect(count2, 1);
    });

    test('L-1.9: update() applies function and notifies index listener', () {
      final list = DripList<int>([10]);
      var count0 = 0;
      list.addIndexListener(0, () => count0++);

      list.update(0, (val) => val + 5);

      expect(list[0], 15);
      expect(count0, 1);
    });

    test('L-1.10: dispose() clears all listener sets', () {
      final list = DripList<int>([1]);
      var structuralCount = 0;
      var indexCount = 0;

      list.addStructuralListener(() => structuralCount++);
      list.addIndexListener(0, () => indexCount++);

      list.dispose();

      // These should not trigger listeners
      list.add(2);
      list[0] = 10;

      expect(structuralCount, 0);
      expect(indexCount, 0);
    });
  });
}
