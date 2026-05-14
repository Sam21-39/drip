import 'package:drip_core/drip_core.dart';

void main() {
  print('--- DRIP Core Example ---');

  // 1. Create a simple reactive state
  final counter = dripState(0, debugName: 'Counter');

  // 2. Create a derived computed state
  final isEven = DripComputed(
    () => counter.value % 2 == 0,
    debugName: 'IsEven',
  );

  // 3. Register a side effect
  DripEffect(() {
    print('Counter is ${counter.value} (Even? ${isEven.value})');
  });

  // 4. Update the state (this triggers the effect)
  print('Writing 1...');
  counter.write(1);

  print('Writing 2 and 3 synchronously...');
  // 5. Batch updates (only one effect trigger happens after microtask flush)
  counter.write(2);
  counter.write(3);
}
