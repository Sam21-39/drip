import 'dart:async';

class RebuildRegistry {
  RebuildRegistry._() {
    _controller = StreamController<void>.broadcast();
  }
  static final instance = RebuildRegistry._();

  final Map<String, int> _total = {};
  final Map<String, int> _wasted = {};
  int _tapCount = 0;
  DateTime? startedAt;
  DateTime? endedAt;

  late final StreamController<void> _controller;
  Stream<void> get stream => _controller.stream;

  void record(String id, {required bool valueChanged}) {
    _total[id] = (_total[id] ?? 0) + 1;
    if (!valueChanged) {
      _wasted[id] = (_wasted[id] ?? 0) + 1;
    }
    _controller.add(null);
  }

  void tapFired() {
    _tapCount++;
    _controller.add(null);
  }

  void reset() {
    _total.clear();
    _wasted.clear();
    _tapCount = 0;
    startedAt = null;
    endedAt = null;
    _controller.add(null);
  }

  int total(String id) => _total[id] ?? 0;
  int wasted(String id) => _wasted[id] ?? 0;
  int necessary(String id) => total(id) - wasted(id);
  int get taps => _tapCount;
  double perTap(String id) => taps == 0 ? 0 : total(id) / taps;
  
  int efficiency(String id) {
    final t = total(id);
    if (t == 0) return 100;
    return (necessary(id) / t * 100).round();
  }

  Duration? get elapsed {
    if (startedAt != null) {
      final end = endedAt ?? DateTime.now();
      return end.difference(startedAt!);
    }
    return null;
  }

  int get maxTotal {
    if (_total.isEmpty) return 1;
    return _total.values.fold(1, (max, val) => val > max ? val : max);
  }
}
