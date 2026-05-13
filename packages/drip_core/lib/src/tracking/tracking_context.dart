import '../state/drip_state_base.dart';

/// A synchronous container for recording dependencies during computation.
class TrackingContext {
  static TrackingContext? _current;

  /// The currently active tracking context.
  static TrackingContext? get current => _current;

  final Set<DripStateBase> _recordedStates = {};

  /// Records a dependency read. Called by [DripStateBase.value].
  void recordRead(DripStateBase state) {
    _recordedStates.add(state);
  }

  /// Returns the collected dependencies as an unmodifiable set.
  Set<DripStateBase> collectDependencies() => Set.unmodifiable(_recordedStates);

  /// Executes [fn] while this context is active.
  ///
  /// Because [finally] restores the previous context, any `await` inside [fn]
  /// will cause the synchronous stack to unwind, effectively pausing
  /// tracking until the microtask resumes (at which point `current` will
  /// be the previous context or null).
  static T withTracking<T>(TrackingContext context, T Function() fn) {
    final previous = _current;
    _current = context;
    try {
      return fn();
    } finally {
      _current = previous;
    }
  }
}
