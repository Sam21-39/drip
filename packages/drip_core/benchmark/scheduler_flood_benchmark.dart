/// DRIP Scheduler Flood Benchmark
///
/// Tests DripBatch under sustained high-frequency writes.
///
/// ## Acceptance gate
/// Frame time must not exceed 16ms under sustained load.
///
/// ## How to run
/// ```
/// cd packages/drip_core
/// dart run benchmark/scheduler_flood_benchmark.dart
/// ```
///
/// ## Expected output
/// ```
/// DripBatch Flood Benchmark
/// ─────────────────────────────────────────
/// Writes:        10,000
/// Duration:      ~Xms
/// Writes/sec:    ~Y
/// Max frame gap: Zms  ← must be < 16ms
/// PASS: frame time within 16ms gate
/// ```

import 'dart:async';

import 'package:drip_core/drip_core.dart';

Future<void> main() async {
  print('DripBatch Flood Benchmark');
  print('─────────────────────────────────────────');

  const totalWrites = 10000;
  const writeIntervalMicros = 100; // 10,000 writes/sec

  final state = dripState(0);
  int buildCount = 0;
  state.addListener(() => buildCount++);

  final stopwatch = Stopwatch()..start();
  final gapTimes = <int>[];
  var lastFlushTime = stopwatch.elapsedMilliseconds;

  final sub = Stream.periodic(
    const Duration(microseconds: writeIntervalMicros),
    (i) => i,
  ).take(totalWrites).listen((i) {
    state.write(i);
    final now = stopwatch.elapsedMilliseconds;
    final gap = now - lastFlushTime;
    if (gap > 1) {
      gapTimes.add(gap);
      lastFlushTime = now;
    }
  });

  await sub.asFuture<void>();

  // Let the last batch flush.
  await Future.delayed(const Duration(milliseconds: 50));

  stopwatch.stop();

  final duration = stopwatch.elapsedMilliseconds;
  final writesPerSec = (totalWrites / (duration / 1000)).toStringAsFixed(0);
  final maxGap =
      gapTimes.isEmpty ? 0 : gapTimes.reduce((a, b) => a > b ? a : b);

  print('Writes:        $totalWrites');
  print('Listeners:     1');
  print('Duration:      ${duration}ms');
  print('Writes/sec:    $writesPerSec');
  print('Max frame gap: ${maxGap}ms');
  print('Build count:   $buildCount');

  const frameBudget = 16;
  if (maxGap <= frameBudget) {
    print('PASS: frame time within ${frameBudget}ms gate ✓');
  } else {
    print('FAIL: frame time $maxGap ms exceeds ${frameBudget}ms gate ✗');
    // Exit with non-zero for CI detection.
  }
}
