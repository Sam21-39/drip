import 'package:drip_core/drip_core.dart';

/// A live connection between a [DripReadable<T>] and a specific property on
/// a [RenderObject].
///
/// ## Callback identity stability (Risk 4 fix)
///
/// A [DripBinding] instance is the stable subscription key, not an inline
/// lambda. The listener registered with [source] is [_onStateChanged] — a
/// method on this object. Because [DripBinding] is created once per
/// [RenderObject] *attach* event (not per *build* event), the subscription
/// survives unlimited parent rebuilds as long as the [RenderObject] itself
/// remains in the tree.
///
/// The correct lifecycle is:
/// - **attach** (`RenderObject.attach`) → create [DripBinding] → subscription starts.
/// - **updateRenderObject** (parent rebuild) → call [reapply] only — no new
///   subscription, no teardown.
/// - **detach/unmount** → call [dispose] → subscription removed.
///
/// This guarantees zero subscription restarts across normal parent rebuilds.
class DripBinding<T> {
  /// The reactive source for this binding.
  final DripReadable<T> source;

  /// Applies a state value to the [RenderObject] property.
  final void Function(T value) apply;

  /// Marks the [RenderObject] as needing paint or layout.
  final void Function() markNeeds;

  bool _isDisposed = false;

  /// Creates a binding and immediately applies the current state value.
  ///
  /// Do NOT call this on every widget rebuild — call it only from the
  /// [RenderObject]'s `attach()` override. Use [reapply] in `updateRenderObject`.
  DripBinding({
    required this.source,
    required this.apply,
    required this.markNeeds,
  }) {
    source.addListener(_onStateChanged);
    // Immediately assert DRIP's value onto the RenderObject.
    apply(source.value);
  }

  /// Re-asserts the current DRIP state value onto the [RenderObject] without
  /// touching the subscription.
  ///
  /// Call this from `updateRenderObject` after any property sync to overwrite
  /// whatever Flutter wrote from the widget tree.
  void reapply() {
    if (_isDisposed) return;
    apply(source.value);
    markNeeds();
  }

  void _onStateChanged() {
    if (_isDisposed) return;
    apply(source.value);
    markNeeds();
  }

  /// Deregisters from [source] and prevents further updates.
  ///
  /// Call from the [RenderObject]'s `dispose()` override, not from
  /// `updateRenderObject`.
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    source.removeListener(_onStateChanged);
  }

  /// Whether this binding has been disposed.
  bool get isDisposed => _isDisposed;
}
