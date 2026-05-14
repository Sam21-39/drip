import 'package:flutter/material.dart';
import 'package:drip_flutter/drip_flutter.dart';
import '../services/solution_controller.dart';
import '../services/rebuild_tracker.dart';
import '../widgets/solution_card.dart';
import '../widgets/counter_text.dart';
import '../widgets/progress_bar.dart';

class CounterDrip extends SolutionController {
  final frame = DripFrame<int>(0);
  
  @override
  void onValue(int v) => frame.update(v);

  @override
  void reset() => frame.update(0);

  @override
  int get currentValue => frame.value;
}

class DripBenchmark extends StatelessWidget {
  final CounterDrip controller;
  final bool isRunning;
  final int? rank;

  const DripBenchmark({
    super.key,
    required this.controller,
    required this.isRunning,
    this.rank,
  });

  @override
  Widget build(BuildContext context) {
    return SolutionCard(
      id: 'drip',
      isRunning: isRunning,
      rank: rank,
      counter: DripFrameBuilder<int>(
        frame: controller.frame,
        builder: (context, v) {
          RebuildTracker.instance.record('drip', v);
          return CounterText(value: v);
        },
      ),
      progressBar: DripFrameBuilder<int>(
        frame: controller.frame,
        builder: (context, v) {
          return ProgressBar(value: v, color: Colors.blue);
        },
      ),
    );
  }
}
