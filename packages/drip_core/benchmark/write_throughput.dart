import 'dart:io';

import 'package:drip_core/drip_core.dart';

void main() {
  final state = dripState(0);

  // Warmup JIT
  for (var i = 0; i < 1000000; i++) {
    state.write(i);
  }

  final stopwatch = Stopwatch()..start();

  const iterations = 10000000;
  for (var i = 0; i < iterations; i++) {
    state.write(i);
  }

  stopwatch.stop();
  final elapsedMs = stopwatch.elapsedMilliseconds;
  final opsPerSec = (iterations / elapsedMs) * 1000;
  print('Benchmark Write Throughput: ${opsPerSec.toStringAsFixed(2)} ops/sec');

  final threshold = double.tryParse(
        Platform.environment['DRIP_MIN_WRITE_THROUGHPUT'] ?? '',
      ) ??
      10000000.0;

  if (opsPerSec < threshold) {
    throw StateError(
      'Write throughput ${(opsPerSec / 1000000).toStringAsFixed(2)}M ops/sec '
      'is below required ${(threshold / 1000000).toStringAsFixed(2)}M ops/sec.',
    );
  }

  print('SUCCESS: Throughput passed threshold.');
}
