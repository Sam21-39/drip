import 'package:flutter/material.dart';
import 'package:drip_flutter/drip_flutter.dart';
import '../services/frame_updater.dart';
import '../services/rebuild_tracker.dart';
import '../widgets/number_cube.dart';

class CubeDripController {
  final frame = DripFrame<List<int>>(List<int>.filled(200, 0));

  void update(List<int> vals) {
    frame.update(List<int>.from(vals));
  }
}

class DripBenchmark extends StatefulWidget {
  final bool isRunning;
  const DripBenchmark({super.key, required this.isRunning});

  @override
  State<DripBenchmark> createState() => _DripBenchmarkState();
}

class _DripBenchmarkState extends State<DripBenchmark> {
  late CubeDripController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = CubeDripController();
    if (widget.isRunning) {
      _start();
    }
  }

  @override
  void didUpdateWidget(DripBenchmark oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRunning && !oldWidget.isRunning) {
      _start();
    } else if (!widget.isRunning && oldWidget.isRunning) {
      _stop();
    }
  }

  void _start() {
    FrameUpdater.instance.start((vals) => _ctrl.update(vals));
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
    return DripFrameBuilder<List<int>>(
      frame: _ctrl.frame,
      builder: (ctx, values) {
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
