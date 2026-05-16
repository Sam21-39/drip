import 'dart:async';
import 'package:test/test.dart';
import 'package:drip_core/drip_core.dart';

void main() {
  setUp(() {
    DripTrace.enable();
  });

  tearDown(() {
    DripTrace.disable();
    DripBatch.instance.reset();
  });

  test('DripTrace captures trace on write and chains on effect throw',
      () async {
    final state = dripState(0, debugName: 'counter');
    bool effectRan = false;

    DripEffect(() {
      effectRan = true;
      if (state.value == 1) {
        throw StateError('Effect error');
      }
    });

    // Flush initial effect
    await Future.microtask(() {});
    expect(effectRan, true);

    state.write(1);

    // The flush should rethrow with chained stack trace
    try {
      DripBatch.instance.debugFlush();
      fail('Should have thrown');
    } catch (e, stack) {
      expect(e, isA<StateError>());
      expect(stack.toString(), contains('--- DripBatch microtask gap ---'));
    }

    // Trace should be cleared after flush
    expect(DripTrace.current, isNull);
  });
}
