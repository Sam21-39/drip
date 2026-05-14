import 'dart:async';
import 'package:flutter/scheduler.dart';

class FrameProfiler {
  FrameProfiler._();
  static final instance = FrameProfiler._();

  double _fps = 0;
  double _buildMs = 0;
  double _rasterMs = 0;
  int _dropped = 0;

  double get fps => _fps;
  double get buildMs => _buildMs;
  double get rasterMs => _rasterMs;
  int get dropped => _dropped;

  void start() {
    _dropped = 0;
    SchedulerBinding.instance.addTimingsCallback(_onFrame);
  }

  void stop() {
    SchedulerBinding.instance.removeTimingsCallback(_onFrame);
  }

  void _onFrame(List<FrameTiming> timings) {
    for (final t in timings) {
      final buildDuration = t.buildDuration.inMicroseconds / 1000;
      final rasterDuration = t.rasterDuration.inMicroseconds / 1000;
      final totalMs = buildDuration + rasterDuration;

      _buildMs = (_buildMs * 0.85) + (buildDuration * 0.15); // EMA
      _rasterMs = (_rasterMs * 0.85) + (rasterDuration * 0.15);
      _fps = totalMs > 0 ? (1000 / totalMs).clamp(0, 120) : 60;

      // 16.67ms budget for 60fps
      if (totalMs > 16.67) _dropped++;
    }
    _controller.add(null);
  }

  final _controller = StreamController<void>.broadcast();
  Stream<void> get stream => _controller.stream;
}
