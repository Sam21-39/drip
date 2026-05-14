import 'package:flutter/material.dart';
import '../services/frame_profiler.dart';

class StatusStrip extends StatelessWidget {
  const StatusStrip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFF1A1C1E),
      child: StreamBuilder<void>(
        stream: FrameProfiler.instance.stream,
        builder: (_, __) {
          final f = FrameProfiler.instance;
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Chip('FPS', f.fps.toStringAsFixed(0)),
              _Chip('Frame', '${f.buildMs.toStringAsFixed(1)}ms'),
              _Chip('Raster', '${f.rasterMs.toStringAsFixed(1)}ms'),
              _Chip('Dropped', '${f.dropped}'),
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
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}
