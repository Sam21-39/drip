import 'dart:async';

class RebuildTracker {
  RebuildTracker._();
  static final instance = RebuildTracker._();

  final _total = <String, int>{};
  final _wasted = <String, int>{};
  final _lastValue = <String, int>{};
  final _timestamps = <String, List<int>>{}; // epoch ms per rebuild

  // Call this from inside build() — nowhere else
  void record(String id, int renderedValue) {
    final prev = _lastValue[id];
    final changed = prev != renderedValue;

    _total[id] = (_total[id] ?? 0) + 1;
    if (!changed) _wasted[id] = (_wasted[id] ?? 0) + 1;
    _lastValue[id] = renderedValue;

    (_timestamps[id] ??= []).add(DateTime.now().millisecondsSinceEpoch);

    _controller.add(null); // notify UI
  }

  void reset() {
    _total.clear();
    _wasted.clear();
    _lastValue.clear();
    _timestamps.clear();
    _controller.add(null);
  }

  int total(String id) => _total[id] ?? 0;
  int wasted(String id) => _wasted[id] ?? 0;
  int necessary(String id) => total(id) - wasted(id);
  
  double efficiency(String id) {
    final t = total(id);
    return t == 0 ? 100.0 : (necessary(id) / t * 100);
  }

  // Rebuilds per second over last 30 samples
  double rebuildsPerSec(String id) {
    final ts = _timestamps[id];
    if (ts == null || ts.length < 2) return 0;
    final window = ts.length > 30 ? ts.sublist(ts.length - 30) : ts;
    final spanMs = window.last - window.first;
    if (spanMs <= 0) return 0;
    return (window.length - 1) / spanMs * 1000;
  }

  final _controller = StreamController<void>.broadcast();
  Stream<void> get stream => _controller.stream;
}
