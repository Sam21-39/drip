import 'dart:async';
import 'package:flutter/material.dart';
import 'services/rebuild_tracker.dart';
import 'services/frame_profiler.dart';
import 'services/session_history.dart';
import 'widgets/solution_buttons.dart';
import 'widgets/status_strip.dart';
import 'widgets/active_stats.dart';

import 'solutions/drip_benchmark.dart';
import 'solutions/getx_benchmark.dart';
import 'solutions/riverpod_benchmark.dart';
import 'solutions/bloc_benchmark.dart';
import 'solutions/provider_benchmark.dart';
import 'solutions/setstate_benchmark.dart';

class BenchmarkScreen extends StatefulWidget {
  const BenchmarkScreen({super.key});

  @override
  State<BenchmarkScreen> createState() => _BenchmarkScreenState();
}

class _BenchmarkScreenState extends State<BenchmarkScreen> {
  String _activeId = 'drip';
  bool _isRunning = false;
  int _secondsRemaining = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    FrameProfiler.instance.start();
    RebuildTracker.instance.activate(_activeId);
  }

  @override
  void dispose() {
    _timer?.cancel();
    FrameProfiler.instance.stop();
    super.dispose();
  }

  void _onSelect(String id) {
    if (_isRunning) return;
    setState(() {
      _activeId = id;
      RebuildTracker.instance.activate(id);
    });
  }

  void _toggleBenchmark() {
    if (_isRunning) {
      _stopBenchmark();
    } else {
      _startBenchmark();
    }
  }

  void _startBenchmark() {
    RebuildTracker.instance.reset();
    setState(() {
      _isRunning = true;
      _secondsRemaining = 30;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _stopBenchmark();
        }
      });
    });
  }

  void _stopBenchmark() {
    _timer?.cancel();
    _timer = null;

    // Save result to history
    final t = RebuildTracker.instance;
    final f = FrameProfiler.instance;
    if (t.totalWidgets > 0) {
      SessionHistory.instance.addResult(BenchmarkResult(
        id: _activeId,
        totalRebuilds: t.totalWidgets,
        efficiency: t.efficiency,
        avgFps: f.fps,
        timestamp: DateTime.now(),
      ));
    }

    setState(() {
      _isRunning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    const brandColor = Color(0xFF00D1FF);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0B),
      body: SafeArea(
        child: Column(
          children: [
            const StatusStrip(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                children: [
                  SolutionButtons(
                    activeId: _activeId,
                    onSelect: _onSelect,
                    isRunning: _isRunning,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _toggleBenchmark,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _isRunning ? Colors.redAccent : brandColor,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            _isRunning ? 'STOP BENCHMARK' : 'START 30s RACE',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, letterSpacing: 1),
                          ),
                        ),
                      ),
                      if (_isRunning) ...[
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${_secondsRemaining}s',
                            style: const TextStyle(
                              color: brandColor,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const ActiveStats(),
            const Divider(height: 1, color: Colors.white10),
            Expanded(
              flex: 3,
              child: _buildActiveSolution(),
            ),
            const Divider(height: 1, color: Colors.white10),
            Expanded(
              flex: 2,
              child: _buildHistory(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveSolution() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: switch (_activeId) {
        'drip' =>
          DripBenchmark(key: const ValueKey('drip'), isRunning: _isRunning),
        'getx' =>
          GetXBenchmark(key: const ValueKey('getx'), isRunning: _isRunning),
        'riverpod' => RiverpodBenchmark(
            key: const ValueKey('riverpod'), isRunning: _isRunning),
        'bloc' =>
          BlocBenchmark(key: const ValueKey('bloc'), isRunning: _isRunning),
        'provider' => ProviderBenchmark(
            key: const ValueKey('provider'), isRunning: _isRunning),
        'setstate' => SetStateBenchmark(
            key: const ValueKey('setstate'), isRunning: _isRunning),
        _ => const SizedBox.shrink(),
      },
    );
  }

  Widget _buildHistory() {
    return Container(
      color: const Color(0xFF141417),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              'SESSION HISTORY',
              style: TextStyle(
                  color: Colors.white38,
                  fontSize: 10,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: StreamBuilder<void>(
              stream: SessionHistory.instance.stream,
              builder: (context, snapshot) {
                final history = SessionHistory.instance.history;
                if (history.isEmpty) {
                  return const Center(
                    child: Text('No results yet',
                        style: TextStyle(color: Colors.white10)),
                  );
                }

                // Calculate ranks based on efficiency
                final rankedList = List<BenchmarkResult>.from(history)
                  ..sort((a, b) => b.efficiency.compareTo(a.efficiency));

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: history.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: Colors.white10),
                  itemBuilder: (context, index) {
                    final res = history[index];
                    final rank = rankedList.indexOf(res) + 1;
                    final isTop3 = rank <= 3;

                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          _HistoryTag(res.id, isTop3: isTop3, rank: rank),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${res.totalRebuilds} rebuilds',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: isTop3
                                        ? const Color(0xFF00D1FF)
                                        : Colors.white,
                                  ),
                                ),
                                Text(
                                  'Efficiency: ${res.efficiency.toStringAsFixed(1)}% • ${res.avgFps.toStringAsFixed(0)} FPS',
                                  style: const TextStyle(
                                      color: Colors.white38, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            _formatTime(res.timestamp),
                            style: const TextStyle(
                                color: Colors.white24, fontSize: 10),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _HistoryTag extends StatelessWidget {
  final String id;
  final bool isTop3;
  final int rank;
  const _HistoryTag(this.id, {this.isTop3 = false, this.rank = 0});

  @override
  Widget build(BuildContext context) {
    const brandColor = Color(0xFF00D1FF);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isTop3) ...[
          _getMedal(rank),
          const SizedBox(width: 6),
        ],
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isTop3 ? brandColor.withValues(alpha: 0.2) : Colors.white10,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            id.toUpperCase(),
            style: TextStyle(
              color: isTop3 ? brandColor : Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _getMedal(int rank) {
    switch (rank) {
      case 1:
        return const Text('🥇', style: TextStyle(fontSize: 14));
      case 2:
        return const Text('🥈', style: TextStyle(fontSize: 14));
      case 3:
        return const Text('🥉', style: TextStyle(fontSize: 14));
      default:
        return const SizedBox.shrink();
    }
  }
}
