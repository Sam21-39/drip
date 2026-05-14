import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/solution_controller.dart';
import '../services/rebuild_tracker.dart';
import '../widgets/solution_card.dart';
import '../widgets/counter_text.dart';
import '../widgets/progress_bar.dart';

class CounterBloc extends Cubit<int> implements SolutionController {
  CounterBloc() : super(0);
  
  @override
  void onValue(int v) => emit(v);
  
  @override
  void reset() => emit(0);

  @override
  int get currentValue => state;
}

class BlocBenchmark extends StatelessWidget {
  final CounterBloc controller;
  final bool isRunning;
  final int? rank;

  const BlocBenchmark({
    super.key,
    required this.controller,
    required this.isRunning,
    this.rank,
  });

  @override
  Widget build(BuildContext context) {
    return SolutionCard(
      id: 'bloc',
      isRunning: isRunning,
      rank: rank,
      counter: BlocBuilder<CounterBloc, int>(
        builder: (context, state) {
          RebuildTracker.instance.record('bloc', state);
          return CounterText(value: state);
        },
      ),
      progressBar: BlocBuilder<CounterBloc, int>(
        builder: (context, state) {
          return ProgressBar(value: state, color: Colors.blueAccent);
        },
      ),
    );
  }
}
