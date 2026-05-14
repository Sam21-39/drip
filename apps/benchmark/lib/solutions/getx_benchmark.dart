import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/frame_updater.dart';
import '../services/rebuild_tracker.dart';
import '../widgets/number_cube.dart';

class CubeGetXController extends GetxController {
  final values = <int>[].obs;
  void updateValues(List<int> vals) => values.assignAll(vals);
}

class GetXBenchmark extends StatefulWidget {
  final bool isRunning;
  const GetXBenchmark({super.key, required this.isRunning});

  @override
  State<GetXBenchmark> createState() => _GetXBenchmarkState();
}

class _GetXBenchmarkState extends State<GetXBenchmark> {
  late CubeGetXController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.put(CubeGetXController());
    if (widget.isRunning) {
      _start();
    }
  }

  @override
  void didUpdateWidget(GetXBenchmark oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRunning && !oldWidget.isRunning) {
      _start();
    } else if (!widget.isRunning && oldWidget.isRunning) {
      _stop();
    }
  }

  void _start() {
    FrameUpdater.instance.start((vals) => _ctrl.updateValues(vals));
  }

  void _stop() {
    FrameUpdater.instance.stop();
  }

  @override
  void dispose() {
    _stop();
    Get.delete<CubeGetXController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final list = _ctrl.values;
      RebuildTracker.instance.record();
      return GridView.builder(
        padding: EdgeInsets.zero,
        itemCount: list.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 10,
          childAspectRatio: 1,
        ),
        itemBuilder: (_, i) {
          RebuildTracker.instance.record();
          return NumberCube(value: list[i], index: i);
        },
      );
    });
  }
}
