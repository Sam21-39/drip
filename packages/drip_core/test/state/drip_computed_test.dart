import 'package:drip_core/drip_core.dart';
import 'package:test/test.dart';

void main() {
  group('DripComputed', () {
    test('2.1 Lazy evaluation — not computed until read', () {
      var computeCount = 0;
      final a = dripState(0);
      final c = DripComputed(() {
        computeCount++;
        return a.value * 2;
      });

      expect(computeCount, 0);
      expect(c.value, 0);
      expect(computeCount, 1);
    });

    test('2.2 Cached — not re-evaluated on repeated reads', () {
      var computeCount = 0;
      final a = dripState(0);
      final c = DripComputed(() {
        computeCount++;
        return a.value * 2;
      });

      expect(c.value, 0);
      expect(c.value, 0);
      expect(computeCount, 1);
    });

    test('2.3 Re-evaluates when direct dependency changes', () {
      var computeCount = 0;
      final a = dripState(1);
      final c = DripComputed(() {
        computeCount++;
        return a.value * 2;
      });

      expect(c.value, 2);
      a.write(2);
      expect(c.value, 4);
      expect(computeCount, 2);
    });

    test('2.5 Dynamic dependency re-tracking after condition flip', () {
      final useA = dripState(true);
      final a = dripState('A');
      final b = dripState('B');
      var evalCount = 0;

      final result = DripComputed(() {
        evalCount++;
        return useA.value ? a.value : b.value;
      });

      expect(result.value, 'A');
      expect(evalCount, 1);

      // Change b -> no re-eval because b is not tracked
      b.write('B2');
      expect(result.value, 'A');
      expect(evalCount, 1);

      // Flip condition
      useA.write(false);
      expect(result.value, 'B2');
      expect(evalCount, 2);

      // Now a should not trigger re-eval
      a.write('A2');
      expect(result.value, 'B2');
      expect(evalCount, 2);
    });

    test('2.6 Diamond dependency — source computed exactly once', () async {
      // a -> b, c -> d
      final a = dripState(0);
      var bEvals = 0;
      final b = DripComputed(() {
        bEvals++;
        return a.value + 1;
      });

      var cEvals = 0;
      final c = DripComputed(() {
        cEvals++;
        return a.value + 2;
      });

      var dEvals = 0;
      final d = DripComputed(() {
        dEvals++;
        return b.value + c.value;
      });

      expect(d.value, 3); // initial: b=1, c=2, d=3
      expect(bEvals, 1);
      expect(cEvals, 1);
      expect(dEvals, 1);

      a.write(10);
      await Future.microtask(() {});

      // Even though both b and c become stale, reading d should only
      // trigger one eval of b and c.
      expect(d.value, 23); // b=11, c=12, d=23
      expect(bEvals, 2);
      expect(cEvals, 2);
      expect(dEvals, 2);
    });

    test('2.7 Circular dependency throws DripCircularDependencyError', () {
      late DripComputed<int> c;
      c = DripComputed(() {
        return c.value + 1;
      }, debugName: 'loop');

      expect(() => c.value, throwsA(isA<DripCircularDependencyError>()));
    });
  });
}
