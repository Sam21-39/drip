/// A debug-only diagnostic layer that captures synchronous call context at the
/// moment of state mutation and makes it available when the microtask flush runs.
///
/// Under normal execution, when a state change produces an unexpected UI result,
/// the stack trace is truncated at the `DripBatch` microtask boundary.
/// `DripTrace` bridges this gap by capturing the trace at the call site and
/// chaining it if an effect throws during the flush.
class DripTrace {
  static bool _enabled = false;
  static bool _autoEnabled = false;
  static StackTrace? _current;

  // Static initializer block to auto-enable in debug mode.
  static void _init() {
    assert(() {
      _autoEnabled = true;
      _enabled = true;
      return true;
    }());
  }

  /// Enables DripTrace manually.
  /// Note: DripTrace is automatically enabled in debug mode.
  static void enable() {
    _enabled = true;
  }

  /// Disables DripTrace to save performance overhead.
  /// Automatically disabled in profile and release builds.
  static void disable() {
    _enabled = false;
    _current = null;
  }

  /// The active trace context. Null if not enabled or no write is active.
  static StackTrace? get current => _current;

  /// Internal: Sets the current trace.
  static void setCurrent(StackTrace? trace) {
    _current = trace;
  }

  /// Internal: Returns true if enabled.
  static bool get isEnabled {
    if (!_autoEnabled) _init();
    return _enabled;
  }
}
