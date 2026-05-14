import 'dart:math';
import 'package:flutter/scheduler.dart';

typedef ValuesCallback = void Function(List<int> values);

class FrameUpdater {
  FrameUpdater._();
  static final instance = FrameUpdater._();

  bool _running = false;
  ValuesCallback? _onUpdate;
  final _rand = Random();

  // Pre-allocated — no GC pressure per frame
  final _values = List<int>.filled(200, 0);

  void start(ValuesCallback onUpdate) {
    _onUpdate = onUpdate;
    _running = true;
    _scheduleNext();
  }

  void stop() {
    _running = false;
    _onUpdate = null;
  }

  void _scheduleNext() {
    SchedulerBinding.instance.scheduleFrameCallback((_) {
      if (!_running) return;

      // Generate 200 real random ints
      for (int i = 0; i < 200; i++) {
        _values[i] = _rand.nextInt(1000);
      }

      _onUpdate?.call(_values);
      _scheduleNext(); // chain to next vsync
    });
  }
}
