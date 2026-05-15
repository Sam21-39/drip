import 'package:drip_core/drip_core.dart';

/// A live connection between a [DripReadable<T>] and a specific property on a [RenderObject].
///
/// This binding subscribes to a [DripReadable] and applies changes directly
/// to a [RenderObject] property, bypassing the widget rebuild cycle.
class DripBinding<T> {
  /// The reactive source for this binding.
  final DripReadable<T> source;

  /// The closure to apply the new state value to the [RenderObject] property.
  final void Function(T value) apply;

  /// The closure to mark the [RenderObject] as needing paint or layout.
  final void Function() markNeeds;

  bool _isDisposed = false;

  /// Creates a binding and immediately applies the current state value.
  DripBinding({
    required this.source,
    required this.apply,
    required this.markNeeds,
  }) {
    // 1. Register with source immediately
    source.addListener(_onStateChanged);

    // 2. Call apply(source.value) immediately to reflect current state
    apply(source.value);
  }

  void _onStateChanged() {
    if (_isDisposed) return;

    // Design Decision: Apply the value first, then trigger the pipeline.
    apply(source.value);
    markNeeds();
  }

  /// Deregisters from the source and prevents further updates.
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    source.removeListener(_onStateChanged);
  }

  /// Whether this binding has been disposed.
  bool get isDisposed => _isDisposed;
}
