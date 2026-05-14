import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/solution_controller.dart';
import '../services/rebuild_tracker.dart';
import '../widgets/solution_card.dart';
import '../widgets/counter_text.dart';
import '../widgets/progress_bar.dart';

class ProviderCounter extends ChangeNotifier implements SolutionController {
  int _value = 0;
  int get value => _value;
  
  @override
  void onValue(int v) {
    _value = v;
    notifyListeners();
  }

  @override
  void reset() {
    _value = 0;
    notifyListeners();
  }

  @override
  int get currentValue => _value;
}

class ProviderBenchmark extends StatelessWidget {
  final ProviderCounter controller;
  final bool isRunning;
  final int? rank;

  const ProviderBenchmark({
    super.key,
    required this.controller,
    required this.isRunning,
    this.rank,
  });

  @override
  Widget build(BuildContext context) {
    return SolutionCard(
      id: 'provider',
      isRunning: isRunning,
      rank: rank,
      counter: Consumer<ProviderCounter>(
        builder: (context, counter, _) {
          RebuildTracker.instance.record('provider', counter.value);
          return CounterText(value: counter.value);
        },
      ),
      progressBar: Consumer<ProviderCounter>(
        builder: (context, counter, _) {
          return ProgressBar(value: counter.value, color: Colors.blueGrey);
        },
      ),
    );
  }
}
