import 'package:flutter/material.dart';
import '../services/frame_updater.dart';
import '../services/rebuild_tracker.dart';
import '../widgets/number_cube.dart';

class SetStateBenchmark extends StatefulWidget {
  final bool isRunning;
  const SetStateBenchmark({super.key, required this.isRunning});

  @override
  State<SetStateBenchmark> createState() => _SetStateBenchmarkState();
}

class _SetStateBenchmarkState extends State<SetStateBenchmark> {
  List<int> _values = List<int>.filled(200, 0);

  @override
  void initState() {
    super.initState();
    if (widget.isRunning) {
      _start();
    }
  }

  @override
  void didUpdateWidget(SetStateBenchmark oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRunning && !oldWidget.isRunning) {
      _start();
    } else if (!widget.isRunning && oldWidget.isRunning) {
      _stop();
    }
  }

  void _start() {
    FrameUpdater.instance.start((vals) {
      if (mounted) {
        setState(() {
          _values = List<int>.from(vals);
        });
      }
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
    RebuildTracker.instance.record();
    return _CubeGrid(values: _values);
  }
}

class _CubeGrid extends StatelessWidget {
  final List<int> values;
  const _CubeGrid({required this.values});

  @override
  Widget build(BuildContext context) {
    RebuildTracker.instance.record();
    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 10,
        childAspectRatio: 1,
      ),
      itemCount: 200,
      itemBuilder: (_, i) {
        RebuildTracker.instance.record();
        return NumberCube(value: values[i], index: i);
      },
    );
  }
}
