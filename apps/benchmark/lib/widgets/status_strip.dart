import 'package:flutter/material.dart';
import '../services/frame_profiler.dart';
import '../services/rebuild_tracker.dart';

class StatusStrip extends StatelessWidget {
  const StatusStrip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.black,
      child: StreamBuilder<void>(
        stream: FrameProfiler.instance.stream,
        builder: (_, __) {
          final f = FrameProfiler.instance;
          final t = RebuildTracker.instance;
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Chip('FPS', f.fps.toStringAsFixed(0)),
              _Chip('LATENCY', '${f.buildMs.toStringAsFixed(1)}ms'),
              _Chip('BUILDS/FR', '${t.widgetsPerFrame}'),
              _Chip('EFFICIENCY', '${t.efficiency.toStringAsFixed(1)}%'),
              _Chip('REBUILDS/SEC', t.rebuildsPerSec.toStringAsFixed(1)),
              _Chip('DROPPED', '${f.dropped}'),
            ],
          );
        },
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final String value;
  const _Chip(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF00D1FF),
            fontSize: 12,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}
