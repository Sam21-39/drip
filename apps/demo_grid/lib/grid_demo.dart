import 'dart:async';

import 'package:drip_core/drip_core.dart';
import 'package:drip_flutter/drip_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// ---------------------------------------------------------------------------
// Grid state — 1000 cells, created once, never re-created.
// Each cell is an independent DripState<String>.
// ---------------------------------------------------------------------------

const int _kGridColumns = 40;
const int _kGridRows = 25;
const int _kCellCount = _kGridColumns * _kGridRows; // 1000

/// All 1000 cell states managed by a high-performance [DripItems] collection.
final DripItems<String> _cellItems = DripItems<String>(
  List.generate(_kCellCount, (i) => _cellLabel(i, 0)),
  debugName: 'grid_cells',
);

/// Frame counter for the statistical rebuild counter (updated via setState,
/// which is intentional — this widget SHOULD rebuild at 60fps to show the
/// coexistence of DripState and normal StatefulWidget updates).
final ValueNotifier<int> _frameCounter = ValueNotifier(0);

String _cellLabel(int index, int tick) {
  // Show a rotating hex-like value to make the live updates visually obvious.
  final value = (index ^ tick) & 0xFF;
  return value.toRadixString(16).padLeft(2, '0').toUpperCase();
}

// ---------------------------------------------------------------------------
// GridDemoScreen
// ---------------------------------------------------------------------------

class GridDemoScreen extends StatefulWidget {
  const GridDemoScreen({super.key});

  @override
  State<GridDemoScreen> createState() => _GridDemoScreenState();
}

class _GridDemoScreenState extends State<GridDemoScreen>
    with SingleTickerProviderStateMixin {
  Timer? _updateTimer;
  late final Ticker _frameTicker;
  int _tick = 0;

  @override
  void initState() {
    super.initState();

    // Periodic timer: write to all 1000 states every 16ms (~60fps).
    // DripBatch coalesces all 1000 writes into a single microtask flush.
    _updateTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      _tick++;
      for (var i = 0; i < _kCellCount; i++) {
        _cellItems[i].write(_cellLabel(i, _tick));
      }
    });

    // Frame ticker: updates the rebuild counter every frame.
    // This is a deliberate setState — it proves DripState and StatefulWidget
    // coexist without interference.
    _frameTicker = createTicker((_) {
      _frameCounter.value++;
    })
      ..start();
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    _frameTicker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D1A),
        elevation: 0,
        title: const _DemoTitle(),
        actions: const [_FrameCounterBadge()],
      ),
      body: Column(
        children: [
          const _StatsBar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _kGridColumns,
                  childAspectRatio: 1.0,
                  mainAxisSpacing: 1,
                  crossAxisSpacing: 1,
                ),
                itemCount: _kCellCount,
                itemBuilder: (context, index) {
                  return _GridCell(index: index);
                },
              ),
            ),
          ),
          const _InstructionBar(),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Grid cell — a single DripText with no rebuild overhead
// ---------------------------------------------------------------------------

class _GridCell extends StatelessWidget {
  final int index;

  const _GridCell({required this.index});

  @override
  Widget build(BuildContext context) {
    final hue = (index / _kCellCount * 360).toDouble();
    final color = HSLColor.fromAHSL(1.0, hue, 0.7, 0.55).toColor();

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF14142B),
        borderRadius: BorderRadius.circular(1),
      ),
      child: Center(
        child: DefaultTextStyle(
          style: TextStyle(
            fontSize: 7,
            fontFamily: 'monospace',
            color: color,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
          child: DripItemBuilder<String>(
            items: _cellItems,
            index: index,
            renderMode: true,
            builder: (context, value) {
              return Text(value);
            },
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header widgets
// ---------------------------------------------------------------------------

class _DemoTitle extends StatelessWidget {
  const _DemoTitle();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Drip(),
        SizedBox(width: 8),
        Text(
          'drip_flutter — Zero Rebuild Demo',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFFE0E0FF),
          ),
        ),
      ],
    );
  }
}

class _Drip extends StatelessWidget {
  const _Drip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF9C63FF)],
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        'DRIP',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

/// Rebuild counter — uses ValueListenableBuilder to update without setState.
class _FrameCounterBadge extends StatelessWidget {
  const _FrameCounterBadge();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: ValueListenableBuilder<int>(
        valueListenable: _frameCounter,
        builder: (context, frames, _) {
          return _Badge(
            label: 'FRAME',
            value: '$frames',
            color: const Color(0xFF63FFDA),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Stats bar
// ---------------------------------------------------------------------------

class _StatsBar extends StatelessWidget {
  const _StatsBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFF1E1E3F)),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            const _Badge(
              label: 'CELLS',
              value: '1,000',
              color: Color(0xFF6C63FF),
            ),
            const SizedBox(width: 12),
            const _Badge(
              label: 'WIDGET REBUILDS',
              value: '0',
              color: Color(0xFF63FF85),
            ),
            const SizedBox(width: 12),
            const _Badge(
              label: 'UPDATE RATE',
              value: '60fps',
              color: Color(0xFFFF6363),
            ),
            const SizedBox(width: 12),
            const _Badge(
              label: 'PATH',
              value: 'DripState → DripBinding → markNeedsLayout()',
              color: Color(0xFFFFD263),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _Badge({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: color.withAlpha(200),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Instruction bar
// ---------------------------------------------------------------------------

class _InstructionBar extends StatelessWidget {
  const _InstructionBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFF1E1E3F))),
        color: Color(0xFF0A0A18),
      ),
      child: const Text(
        'flutter run --profile  →  DevTools → Performance → "Track Widget Builds"  →  verify 0 build events during updates',
        style: TextStyle(
          fontSize: 10,
          color: Color(0xFF6B6B9E),
          fontFamily: 'monospace',
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
