import 'package:drip_core/drip_core.dart';

/// A live connection between a [DripState<T>] and a specific property on a [RenderObject].
///
/// Implements [DripListener] to receive updates directly from the reactive core.
///
/// **Design Decision:** Using the public [DripListener] interface from drip_core
/// to maintain type safety and avoid closure overhead for every binding.
class DripBinding<T> implements DripListener {
  /// The reactive source for this binding.
  final DripState<T> state;

  /// The closure to apply the new state value to the [RenderObject] property.
  final void Function(T value) apply;

  /// The closure to mark the [RenderObject] as needing paint or layout.
  final void Function() markNeeds;

  bool _isDisposed = false;

  /// Creates a binding and immediately applies the current state value.
  ///
  /// The [markNeeds] closure is NOT called on initialization because the
  /// [RenderObject] is expected to be in its initial configuration or
  /// about to be painted for the first time.
  DripBinding({
    required this.state,
    required this.apply,
    required this.markNeeds,
  }) {
    // 1. Register with state immediately
    state.subscribe(this);

    // 2. Call apply(state.value) immediately to reflect current state
    apply(state.value);
  }

  @override
  void onStateChanged() {
    if (_isDisposed) return;

    // Design Decision: Apply the value first, then trigger the pipeline.
    // All calls happen on the Flutter UI isolate (main thread).
    apply(state.value);
    markNeeds();
  }

  /// Deregisters from the state and prevents further updates.
  ///
  /// After disposal, any notifications from the state will be ignored.
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    state.unsubscribe(this);
  }

  /// Whether this binding has been disposed.
  bool get isDisposed => _isDisposed;
}
