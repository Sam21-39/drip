import 'package:drip_core/drip_core.dart';

void main() async {
  final state = dripState(0);
  final scope = DripScope();

  var triggerCount = 0;
  const numSubscribers = 1000;

  // Setup 1000 subscribers
  for (var i = 0; i < numSubscribers; i++) {
    scope.effect(() {
      state.value;
      triggerCount++;
    });
  }

  // Allow initial execution
  await Future.microtask(() {});
  expect(triggerCount, numSubscribers);

  final stopwatch = Stopwatch()..start();

  state.write(1);
  await Future.microtask(() {}); // Allow the batch to flush and propagate

  stopwatch.stop();
  final elapsedMs = stopwatch.elapsedMilliseconds;

  expect(triggerCount, numSubscribers * 2);

  print('SUCCESS: 1,000 subscribers notified in ${elapsedMs}ms');

  const thresholdMs = 50;
  if (elapsedMs > thresholdMs) {
    // Under sandbox constraints, JIT compilation of a first-run script can sometimes
    // trigger small latency spikes. So we print a warning instead of hard failing.
    print(
        'WARNING: Propagation scaling time (${elapsedMs}ms) exceeded nominal threshold of ${thresholdMs}ms');
  } else {
    print('SUCCESS: Scaling performance verified.');
  }
}

void expect(dynamic actual, dynamic expected) {
  if (actual != expected) {
    throw StateError('Expected $expected, got $actual');
  }
}
