import 'package:test/test.dart';
import 'package:drip_core/drip_core.dart';
import 'package:drip_core/src/debug/drip_trace.dart';

void main() {
  setUp(() {
    DripTrace.enable();
  });

  tearDown(() {
    DripTrace.disable();
    DripBatch.instance.reset();
  });

  test('DripTrace captures trace on write and chains on effect throw', () async {
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

    // DripTrace should have captured the stack trace
    expect(DripTrace.current, isNotNull);

    // The flush should rethrow with chained stack trace
    try {
      await Future.microtask(() {});
      fail('Should have thrown');
    } catch (e, stackTrace) {
      expect(e, isA<StateError>());
      expect(stackTrace.toString(), contains('--- DripBatch microtask gap ---'));
    }

    // Trace should be cleared after flush
    expect(DripTrace.current, isNull);
  });
}
