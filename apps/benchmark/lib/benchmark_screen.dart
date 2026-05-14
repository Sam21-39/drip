import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as rp;
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import 'services/benchmark_coordinator.dart';
import 'services/rebuild_tracker.dart';
import 'services/solution_controller.dart';
import 'widgets/status_strip.dart';

import 'solutions/drip_benchmark.dart';
import 'solutions/getx_benchmark.dart';
import 'solutions/riverpod_benchmark.dart';
import 'solutions/bloc_benchmark.dart';
import 'solutions/provider_benchmark.dart';
import 'solutions/setstate_benchmark.dart';

class BenchmarkScreen extends rp.ConsumerStatefulWidget {
  const BenchmarkScreen({super.key});

  @override
  rp.ConsumerState<BenchmarkScreen> createState() => _BenchmarkScreenState();
}

class _BenchmarkScreenState extends rp.ConsumerState<BenchmarkScreen> {
  late CounterDrip dripCtrl;
  late CounterGetX getxCtrl;
  late CounterBloc blocCtrl;
  late ProviderCounter providerCtrl;
  
  // SetState uses its own internal state, so we need a GlobalKey to reach it
  final GlobalKey<SetStateBenchmarkState> setStateKey = GlobalKey();

  late BenchmarkCoordinator coordinator;
  bool isRunning = false;
  List<String> ranking = [];

  @override
  void initState() {
    super.initState();
    dripCtrl = CounterDrip();
    getxCtrl = Get.put(CounterGetX());
    blocCtrl = CounterBloc();
    providerCtrl = ProviderCounter();

    // The ordering here matters for the fan-out in the coordinator
    coordinator = BenchmarkCoordinator([]);
  }

  void _initCoordinator() {
    coordinator = BenchmarkCoordinator([
      dripCtrl,
      getxCtrl,
      blocCtrl,
      providerCtrl,
      setStateKey.currentState!, // Riverpod handled separately
      ref.read(riverpodBenchmarkProvider),
    ]);
  }

  void _start() async {
    if (setStateKey.currentState == null) {
       // Wait a frame for the key to be attached
       await Future.delayed(Duration.zero);
    }
    
    _initCoordinator();

    setState(() {
      isRunning = true;
      ranking = [];
    });

    await coordinator.start(onDone: () {
      if (mounted) {
        setState(() {
          isRunning = false;
          ranking = _computeRanking();
        });
      }
    });
  }

  void _reset() {
    dripCtrl.reset();
    getxCtrl.reset();
    blocCtrl.reset();
    providerCtrl.reset();
    setStateKey.currentState?.reset();
    ref.read(counterProvider.notifier).state = 0;
    RebuildTracker.instance.reset();
    
    setState(() {
      isRunning = false;
      ranking = [];
    });
  }

  List<String> _computeRanking() {
    final t = RebuildTracker.instance;
    final ids = ['drip', 'getx', 'riverpod', 'bloc', 'provider', 'setstate'];
    ids.sort((a, b) {
      final cmp = t.wasted(a).compareTo(t.wasted(b));
      return cmp != 0 ? cmp : t.total(a).compareTo(t.total(b));
    });
    return ids;
  }

  int? _getRank(String id) {
    if (ranking.isEmpty) return null;
    return ranking.indexOf(id) + 1;
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: providerCtrl),
      ],
      child: BlocProvider.value(
        value: blocCtrl,
        child: Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                const StatusStrip(),
                _buildControls(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      children: [
                        DripBenchmark(
                          controller: dripCtrl,
                          isRunning: isRunning,
                          rank: _getRank('drip'),
                        ),
                        GetXBenchmark(
                          controller: getxCtrl,
                          isRunning: isRunning,
                          rank: _getRank('getx'),
                        ),
                        RiverpodBenchmark(
                          ref: ref,
                          isRunning: isRunning,
                          rank: _getRank('riverpod'),
                        ),
                        BlocBenchmark(
                          controller: blocCtrl,
                          isRunning: isRunning,
                          rank: _getRank('bloc'),
                        ),
                        ProviderBenchmark(
                          controller: providerCtrl,
                          isRunning: isRunning,
                          rank: _getRank('provider'),
                        ),
                        SetStateBenchmark(
                          key: setStateKey,
                          isRunning: isRunning,
                          rank: _getRank('setstate'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '100M Count Benchmark',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(
            'Comparing real widget rebuilds and engine timings',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: isRunning ? null : _start,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A1C1E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('START BENCHMARK', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton(
              onPressed: isRunning ? null : _reset,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('RESET'),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper to allow Riverpod to be treated as a SolutionController
final riverpodBenchmarkProvider = rp.Provider<SolutionController>((ref) {
  return _RiverpodController(ref);
});

class _RiverpodController implements SolutionController {
  final rp.Ref ref;
  _RiverpodController(this.ref);

  @override
  void onValue(int v) => ref.read(counterProvider.notifier).state = v;

  @override
  void reset() => ref.read(counterProvider.notifier).state = 0;

  @override
  int get currentValue => ref.read(counterProvider);
}
