@Tags(['benchmark'])

import 'package:drip_core/drip_core.dart';
import 'package:test/test.dart';

void main() {
  group('Benchmarks', () {
    test('BENCH-1: DripState.write() performs many writes', () {
      final state = dripState(0);
      final stopwatch = Stopwatch()..start();

      const iterations = 1000000;
      for (var i = 0; i < iterations; i++) {
        state.write(i);
      }

      stopwatch.stop();
      final elapsed = stopwatch.elapsedMicroseconds;
      final opsPerSec = (iterations / elapsed) * 1000000;

      print('BENCH-1: $opsPerSec ops/sec');
      expect(state.value, iterations - 1);
    });

    test('BENCH-2: DripComputed invalidation is O(direct subscribers)',
        () async {
      final a = dripState(0);
      final list = List.generate(1000, (i) => DripComputed(() => a.value + i));

      var notifications = 0;
      // Only watch 10 of them
      for (var i = 0; i < 10; i++) {
        DripEffect(() {
          list[i].value;
          notifications++;
        });
      }

      await Future.microtask(() {}); // Initial runs
      expect(notifications, 10);

      a.write(1);
      await Future.microtask(() {});

      // Even though 1000 computeds are stale, only 10 effects should re-run
      expect(notifications, 20);
    });

    test('BENCH-3: 1000 synchronous writes -> 1 propagation pass', () async {
      final a = dripState(0);
      var runs = 0;
      DripEffect(() {
        a.value;
        runs++;
      });

      await Future.microtask(() {});
      expect(runs, 1);

      for (var i = 0; i < 1000; i++) {
        a.write(i);
      }

      await Future.microtask(() {});
      expect(runs, 2);
    });
  });
}
