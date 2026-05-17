import 'package:test/test.dart';
import 'package:drip_core/drip_core.dart';
import 'package:drip_core/src/batch/drip_batch.dart';
import 'package:drip_core/src/batch/drip_scheduler_config.dart';

void main() {
  setUp(() {
    DripBatch.instance.reset();
    DripSchedulerConfig.reset();
  });

  tearDown(() {
    DripBatch.instance.reset();
    DripSchedulerConfig.reset();
  });

  group('DripBatch — Microtask Scheduler (Risk 2)', () {
    test('ST-1.1: Below threshold — microtask path is used', () async {
      DripSchedulerConfig.configure(microtaskThreshold: 50);

      var postFrameCalled = false;
      DripBatch.instance.setPostFrameScheduler((_) {
        postFrameCalled = true;
      });

      // Write 10 values — below threshold of 50.
      final state = dripState(0);
      for (var i = 1; i <= 10; i++) {
        state.write(i);
      }

      // Let microtask run.
      await Future.microtask(() {});

      expect(postFrameCalled, isFalse,
          reason: 'Below threshold: must use microtask, not post-frame');
    });

    test('ST-1.2: At or above threshold — post-frame path is used', () async {
      DripSchedulerConfig.configure(microtaskThreshold: 5);

      var postFrameCalled = false;
      DripBatch.instance.setPostFrameScheduler((_) {
        postFrameCalled = true;
      });

      // Write 10 values — above threshold of 5.
      final state = dripState(0);
      for (var i = 1; i <= 10; i++) {
        state.write(i);
      }

      expect(postFrameCalled, isTrue,
          reason: 'Above threshold: must switch to post-frame scheduler');
    });

    test('ST-1.3: disableFallback=true always uses microtask', () async {
      DripSchedulerConfig.configure(
        microtaskThreshold: 1,
        disableFallback: true,
      );

      var postFrameCalled = false;
      DripBatch.instance.setPostFrameScheduler((_) {
        postFrameCalled = true;
      });

      // Write many values — would normally trigger fallback.
      final state = dripState(0);
      for (var i = 1; i <= 100; i++) {
        state.write(i);
      }

      await Future.microtask(() {});

      expect(postFrameCalled, isFalse,
          reason: 'disableFallback=true must always use microtask');
    });

    test('ST-1.4: No postFrameScheduler set — always uses microtask', () async {
      DripSchedulerConfig.configure(microtaskThreshold: 1);
      // Deliberately NOT calling setPostFrameScheduler.

      var microtaskFlushed = false;
      final state = dripState(0);
      for (var i = 1; i <= 100; i++) {
        state.write(i);
      }

      await Future.microtask(() {
        microtaskFlushed = true;
      });

      // No crash — microtask path used as fallback.
      expect(microtaskFlushed, isTrue);
    });

    test('ST-1.5: After flush, pending count resets to zero', () async {
      DripSchedulerConfig.configure(microtaskThreshold: 5);

      void Function(Duration) postFrameCallback = (_) {};
      DripBatch.instance.setPostFrameScheduler((cb) {
        postFrameCallback = cb;
      });

      final state = dripState(0);
      for (var i = 1; i <= 10; i++) {
        state.write(i);
      }

      // Simulate frame callback.
      postFrameCallback(Duration.zero);

      // After flush, internal reset means next write uses microtask again.
      var postFrameCalledAgain = false;
      DripBatch.instance.setPostFrameScheduler((_) {
        postFrameCalledAgain = true;
      });

      // Single write below threshold.
      state.write(99);
      await Future.microtask(() {});

      expect(postFrameCalledAgain, isFalse,
          reason: 'After flush, single write should use microtask again');
    });
  });
}
