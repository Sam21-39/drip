import 'package:drip_core/drip_core.dart';

void main() async {
  final a = dripState(0);

  // Create a wide diamond layer
  const width = 100;
  final middleLayer = List.generate(
    width,
    (i) => DripComputed(() => a.value + i),
  );

  var evalCount = 0;
  final c = DripComputed(() {
    evalCount++;
    var sum = 0;
    for (final node in middleLayer) {
      sum += node.value;
    }
    return sum;
  });

  // Initial evaluation
  expect(c.value, (width * (width - 1)) ~/ 2);
  expect(evalCount, 1);

  // Write to a
  a.write(1);

  // Batched JIT schedules propagation for the next microtask
  await Future.microtask(() {});

  // Lazy evaluation and batching ensures reading c.value triggers
  // exactly ONE re-evaluation of c, even though all 100 middle layer nodes are stale!
  final expectedValue = width * 1 + (width * (width - 1)) ~/ 2;
  expect(c.value, expectedValue);
  expect(evalCount, 2);

  print('SUCCESS: Diamond correctness verified. Eval count: $evalCount');
}

void expect(dynamic actual, dynamic expected) {
  if (actual != expected) {
    throw StateError('Expected $expected, got $actual');
  }
}
