/// Configuration for the [DripBatch] scheduler.
///
/// Provides the threshold at which [DripBatch] switches from microtask
/// scheduling to a post-frame callback to prevent microtask queue flooding
/// under high-frequency writes (Risk 2 fix).
///
/// Configure at app startup via [DripSchedulerConfig.configure]:
///
/// ```dart
/// DripSchedulerConfig.configure(microtaskThreshold: 100);
/// ```
class DripSchedulerConfig {
  DripSchedulerConfig._();

  static DripSchedulerConfig _instance = DripSchedulerConfig._();

  /// The global scheduler configuration instance.
  static DripSchedulerConfig get instance => _instance;

  /// Replaces the global instance with new settings.
  ///
  /// Should be called once during app initialization before any state writes.
  static void configure({
    int microtaskThreshold = 50,
    bool disableFallback = false,
  }) {
    _instance = DripSchedulerConfig._()
      .._microtaskThreshold = microtaskThreshold
      .._disableFallback = disableFallback;
  }

  /// Resets to default configuration. Useful in tests.
  static void reset() {
    _instance = DripSchedulerConfig._();
  }

  int _microtaskThreshold = 50;
  bool _disableFallback = false;

  /// The number of pending propagations above which [DripBatch] switches to
  /// a post-frame callback instead of a microtask.
  ///
  /// Default: 50. Set to a very large value to effectively disable the fallback
  /// without setting [disableFallback] to true.
  int get microtaskThreshold => _microtaskThreshold;

  /// When true, the post-frame fallback is never used — [DripBatch] always
  /// schedules via microtask regardless of pending count.
  ///
  /// Use this only if your write patterns are always bounded and you have
  /// confirmed that microtask flooding cannot occur in your app.
  bool get disableFallback => _disableFallback;
}
