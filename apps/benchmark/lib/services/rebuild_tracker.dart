import 'dart:async';

class RebuildTracker {
  RebuildTracker._();
  static final instance = RebuildTracker._();

  String _activeId = '';
  int _totalWidgetBuilds = 0;
  int _totalFrameBuilds = 0;
  int _thisFrameWidgetBuilds = 0;

  final _widgetBuildsHistory = <int>[]; // last 60 frames

  // Called inside every build()
  void record() {
    _totalWidgetBuilds++;
    _thisFrameWidgetBuilds++;
    _notifyStream();
  }

  // Called by FrameProfiler once per frame boundary
  void onFrameEnd() {
    if (_thisFrameWidgetBuilds > 0) {
      _totalFrameBuilds++;
      _widgetBuildsHistory.add(_thisFrameWidgetBuilds);
      if (_widgetBuildsHistory.length > 60) _widgetBuildsHistory.removeAt(0);
    }
    _thisFrameWidgetBuilds = 0;
    _notifyStream();
  }

  void activate(String id) {
    _activeId = id;
    reset();
  }

  void reset() {
    _totalWidgetBuilds = 0;
    _totalFrameBuilds = 0;
    _thisFrameWidgetBuilds = 0;
    _widgetBuildsHistory.clear();
    _notifyStream();
  }

  String get activeId => _activeId;
  int get totalWidgets => _totalWidgetBuilds;
  int get totalFrames => _totalFrameBuilds;

  int get widgetsPerFrame => _widgetBuildsHistory.isEmpty ? 0 : _widgetBuildsHistory.last;

  // Efficiency: (Expected Builds / Actual Builds)
  // Expected = frames * (1 boundary + 200 cubes)
  double get efficiency {
    if (_totalWidgetBuilds == 0) return 100.0;
    final expected = _totalFrameBuilds * 201;
    if (expected >= _totalWidgetBuilds) return 100.0;
    return (expected / _totalWidgetBuilds) * 100.0;
  }

  double get rebuildsPerSec {
    if (_totalFrameBuilds == 0) return 0;
    return _totalWidgetBuilds / (_totalFrameBuilds / 60.0);
  }

  List<int> get sparkline => List.unmodifiable(_widgetBuildsHistory);

  final _ctrl = StreamController<void>.broadcast();
  Stream<void> get stream => _ctrl.stream;
  void _notifyStream() => _ctrl.add(null);
}
