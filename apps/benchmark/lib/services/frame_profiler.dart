import 'dart:async';
import 'package:flutter/scheduler.dart';
import 'rebuild_tracker.dart';

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

  bool _listening = false;

  void start() {
    if (_listening) return;
    _listening = true;
    SchedulerBinding.instance.addTimingsCallback(_onTimings);
  }

  void stop() {
    _listening = false;
    SchedulerBinding.instance.removeTimingsCallback(_onTimings);
  }

  void _onTimings(List<FrameTiming> timings) {
    for (final t in timings) {
      final b = t.buildDuration.inMicroseconds / 1000.0;
      final r = t.rasterDuration.inMicroseconds / 1000.0;
      _buildMs = _buildMs * 0.85 + b * 0.15; // exponential moving avg
      _rasterMs = _rasterMs * 0.85 + r * 0.15;
      _fps = (b + r) > 0 ? (1000 / (b + r)).clamp(1, 120) : 60.0;
      if ((b + r) > 16.67) _dropped++;

      RebuildTracker.instance.onFrameEnd();
    }
    _ctrl.add(null);
  }

  final _ctrl = StreamController<void>.broadcast();
  Stream<void> get stream => _ctrl.stream;
}
