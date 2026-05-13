import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:drip_core/drip_core.dart';
import 'package:drip_flutter/drip_flutter.dart';

/// A 1000-cell grid demonstrating zero-rebuild performance.
///
/// Every cell updates its content every 16ms, but the [GridDemo] widget
/// and the [GridView] itself never rebuild.
class GridDemo extends StatefulWidget {
  const GridDemo({super.key});

  @override
  State<GridDemo> createState() => _GridDemoState();
}

class _GridDemoState extends State<GridDemo> {
  static const int rows = 25;
  static const int cols = 40;
  static const int totalCells = rows * cols;

  // Static list of states to survive rebuilds if they were to happen
  static final List<DripState<String>> cells = List.generate(
    totalCells,
    (i) => dripState('0'),
  );

  Timer? _timer;
  int _appBuildCount = 0;

  @override
  void initState() {
    super.initState();
    // Update all 1000 cells every frame (approx 60fps)
    _timer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      final random = Random();
      for (final cell in cells) {
        // DripBatch automatically coalesces these 1000 writes
        cell.write(random.nextInt(100).toString());
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _appBuildCount++;
    return Scaffold(
      appBar: AppBar(
        title: const Text('DRIP Grid Benchmark'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'App Rebuilds: $_appBuildCount',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.greenAccent,
                  ),
                ),
                const Text(
                  'Expected: 1',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFF121212),
        padding: const EdgeInsets.all(2),
        child: GridView.builder(
          // Non-scrolling for this bench
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: 1,
            mainAxisSpacing: 1,
          ),
          itemCount: totalCells,
          itemBuilder: (context, i) {
            return Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(1),
              ),
              child: DripText(
                cells[i],
                style: const TextStyle(
                  fontSize: 8,
                  color: Colors.white70,
                  fontFamily: 'Courier',
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
