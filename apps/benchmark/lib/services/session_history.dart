import 'dart:async';

class BenchmarkResult {
  final String id;
  final int totalRebuilds;
  final double efficiency;
  final double avgFps;
  final DateTime timestamp;

  BenchmarkResult({
    required this.id,
    required this.totalRebuilds,
    required this.efficiency,
    required this.avgFps,
    required this.timestamp,
  });
}

class SessionHistory {
  SessionHistory._();
  static final instance = SessionHistory._();

  final List<BenchmarkResult> _history = [];
  List<BenchmarkResult> get history => List.unmodifiable(_history);

  final _ctrl = StreamController<void>.broadcast();
  Stream<void> get stream => _ctrl.stream;

  void addResult(BenchmarkResult result) {
    _history.insert(0, result);
    _ctrl.add(null);
  }

  void clear() {
    _history.clear();
    _ctrl.add(null);
  }
}
