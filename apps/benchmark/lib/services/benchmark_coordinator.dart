import 'dart:async';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'rebuild_tracker.dart';
import 'frame_profiler.dart';
import 'benchmark_isolate.dart';
import 'solution_controller.dart';

class BenchmarkCoordinator {
  final List<SolutionController> solutions;

  BenchmarkCoordinator(this.solutions);

  Future<void> start({required VoidCallback onDone}) async {
    for (final s in solutions) {
      s.reset();
    }
    RebuildTracker.instance.reset();
    FrameProfiler.instance.start();

    await _startIsolate(
      onValue: (v) {
        for (final s in solutions) {
          s.onValue(v);
        }
      },
      onDone: () {
        FrameProfiler.instance.stop();
        onDone();
      },
    );
  }

  Future<void> _startIsolate({
    required void Function(int) onValue,
    required VoidCallback onDone,
  }) async {
    final recv = ReceivePort();
    await Isolate.spawn(benchmarkIsolate, recv.sendPort);

    final completer = Completer<void>();

    recv.listen((msg) {
      if (msg == -1) {
        onDone();
        recv.close();
        completer.complete();
      } else {
        onValue(msg as int);
      }
    });

    return completer.future;
  }
}
