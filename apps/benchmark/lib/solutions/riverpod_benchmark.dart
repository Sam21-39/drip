import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/rebuild_tracker.dart';
import '../widgets/solution_card.dart';
import '../widgets/counter_text.dart';
import '../widgets/progress_bar.dart';

final counterProvider = StateProvider<int>((ref) => 0);

class RiverpodBenchmark extends ConsumerWidget {
  final WidgetRef ref;
  final bool isRunning;
  final int? rank;

  const RiverpodBenchmark({
    super.key,
    required this.ref,
    required this.isRunning,
    this.rank,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SolutionCard(
      id: 'riverpod',
      isRunning: isRunning,
      rank: rank,
      counter: Consumer(
        builder: (context, ref, _) {
          final v = ref.watch(counterProvider);
          RebuildTracker.instance.record('riverpod', v);
          return CounterText(value: v);
        },
      ),
      progressBar: Consumer(
        builder: (context, ref, _) {
          final v = ref.watch(counterProvider);
          return ProgressBar(value: v, color: Colors.indigo);
        },
      ),
    );
  }
}
