/// A controlled structural rebuild boundary.
///
/// Unlike `DripState`, [DripFrame] is intentionally outside the reactive graph.
/// It is designed for structural changes (adding/removing widgets) that
/// genuinely require a standard Flutter build cycle.
///
/// Updates to [DripFrame] are synchronous and immediate, triggering `setState`
/// in the associated [DripFrameBuilder].
class DripFrame<T> {
  T _value;
  final Set<void Function(T value)> _listeners = {};

  /// Creates a [DripFrame] with an initial value.
  DripFrame(this._value);

  /// Returns the current value of the frame.
  ///
  /// This getter does NOT register with any [TrackingContext].
  T get value => _value;

  /// Updates the frame value and notifies listeners synchronously.
  ///
  /// If the new value is equal to the current value, this is a no-op.
  /// No batching or microtask coalescing is performed here; updates
  /// trigger Flutter rebuilds immediately.
  void update(T newValue) {
    if (_value == newValue) return;
    _value = newValue;

    // Notify listeners synchronously.
    // Note: To avoid concurrent modification during iteration, we copy the set.
    final listenersSnapshot = List<void Function(T)>.from(_listeners);
    for (final listener in listenersSnapshot) {
      listener(_value);
    }
  }

  /// Subscribes a listener to frame updates.
  void addListener(void Function(T value) listener) {
    _listeners.add(listener);
  }

  /// Unsubscribes a listener from frame updates.
  void removeListener(void Function(T value) listener) {
    _listeners.remove(listener);
  }

  /// The number of active listeners.
  int get listenerCount => _listeners.length;
}
