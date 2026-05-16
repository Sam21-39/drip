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

    // The flush should rethrow with chained stack trace
    Object? capturedError;
    StackTrace? capturedStack;
    final completer = Completer<void>();

    runZonedGuarded(() {
      state.write(1);
    }, (e, stack) {
      capturedError = e;
      capturedStack = stack;
      completer.complete();
    });

    await completer.future;
    expect(capturedError, isA<StateError>());
    expect(
        capturedStack.toString(), contains('--- DripBatch microtask gap ---'));

    // Trace should be cleared after flush
    expect(DripTrace.current, isNull);
  });
}
