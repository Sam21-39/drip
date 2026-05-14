import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/frame_updater.dart';
import '../services/rebuild_tracker.dart';
import '../widgets/number_cube.dart';

final cubeProvider = StateProvider<List<int>>(
  (ref) => List<int>.filled(200, 0),
);

class RiverpodBenchmark extends ConsumerStatefulWidget {
  final bool isRunning;
  const RiverpodBenchmark({super.key, required this.isRunning});

  @override
  ConsumerState<RiverpodBenchmark> createState() => _RiverpodBenchmarkState();
}

class _RiverpodBenchmarkState extends ConsumerState<RiverpodBenchmark> {
  @override
  void initState() {
    super.initState();
    if (widget.isRunning) {
      _start();
    }
  }

  @override
  void didUpdateWidget(RiverpodBenchmark oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRunning && !oldWidget.isRunning) {
      _start();
    } else if (!widget.isRunning && oldWidget.isRunning) {
      _stop();
    }
  }

  void _start() {
    FrameUpdater.instance.start((vals) {
      ref.read(cubeProvider.notifier).state = List<int>.from(vals);
    });
  }

  void _stop() {
    FrameUpdater.instance.stop();
  }

  @override
  void dispose() {
    _stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (ctx, ref, _) {
        final values = ref.watch(cubeProvider);
        RebuildTracker.instance.record();
        return GridView.builder(
          padding: EdgeInsets.zero,
          itemCount: 200,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 10,
            childAspectRatio: 1,
          ),
          itemBuilder: (_, i) {
            RebuildTracker.instance.record();
            return NumberCube(value: values[i], index: i);
          },
        );
      },
    );
  }
}
