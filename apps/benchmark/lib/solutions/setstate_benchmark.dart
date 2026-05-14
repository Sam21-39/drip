import 'package:flutter/material.dart';
import '../services/solution_controller.dart';
import '../services/rebuild_tracker.dart';
import '../widgets/solution_card.dart';
import '../widgets/counter_text.dart';
import '../widgets/progress_bar.dart';

class SetStateBenchmark extends StatefulWidget {
  final bool isRunning;
  final int? rank;
  const SetStateBenchmark({
    super.key, 
    required this.isRunning,
    this.rank,
  });

  @override
  SetStateBenchmarkState createState() => SetStateBenchmarkState();
}

class SetStateBenchmarkState extends State<SetStateBenchmark> 
    implements SolutionController {
  
  int _value = 0;

  @override
  void onValue(int v) {
    if (mounted) {
      setState(() => _value = v);
    }
  }

  @override
  void reset() {
    if (mounted) {
      setState(() => _value = 0);
    }
  }

  @override
  int get currentValue => _value;

  @override
  Widget build(BuildContext context) {
    // RebuildTracker.record() called here triggers rebuild of the entire card
    RebuildTracker.instance.record('setstate', _value);
    
    return SolutionCard(
      id: 'setstate',
      isRunning: widget.isRunning,
      rank: widget.rank,
      counter: CounterText(value: _value),
      progressBar: ProgressBar(value: _value, color: Colors.grey),
    );
  }
}
