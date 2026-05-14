import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/solution_controller.dart';
import '../services/rebuild_tracker.dart';
import '../widgets/solution_card.dart';
import '../widgets/counter_text.dart';
import '../widgets/progress_bar.dart';

class CounterGetX extends GetxController implements SolutionController {
  var value = 0.obs;
  
  @override
  void onValue(int v) => value.value = v;
  
  @override
  void reset() => value.value = 0;

  @override
  int get currentValue => value.value;
}

class GetXBenchmark extends StatelessWidget {
  final CounterGetX controller;
  final bool isRunning;
  final int? rank;

  const GetXBenchmark({
    super.key,
    required this.controller,
    required this.isRunning,
    this.rank,
  });

  @override
  Widget build(BuildContext context) {
    return SolutionCard(
      id: 'getx',
      isRunning: isRunning,
      rank: rank,
      counter: Obx(() {
        final v = controller.value.value;
        RebuildTracker.instance.record('getx', v);
        return CounterText(value: v);
      }),
      progressBar: Obx(() {
        return ProgressBar(value: controller.value.value, color: Colors.purple);
      }),
    );
  }
}
