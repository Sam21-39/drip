import '../batch/drip_batch.dart';
import '../equality/equality.dart';
import '../errors/drip_errors.dart';
import '../tracking/tracking_context.dart';
import '../readable/drip_readable.dart';
import '../debug/drip_trace.dart';
import 'drip_state_base.dart';

/// An atomic reactive value with a version clock and equality checking.
class DripState<T> extends DripStateBase implements DripReadable<T> {
  T _value;
  final String? debugName;
  final Equality<T> _equality;

  DripState(
    this._value, {
    this.debugName,
    Equality<T>? equality,
  }) : _equality = equality ?? defaultEquality<T>() {
    assert(() {
      if (debugName == null) {
        print(
            'Drip Warning: DripState created without debugName. Set debugName for better stack traces.');
      }
      return true;
    }());
  }

  /// The current value of this state.
  /// Records a dependency if a [TrackingContext] is active.
  T get value {
    TrackingContext.current?.recordRead(this);
    return _value;
  }

  /// Updates the value and schedules a propagation if the value has changed.
  ///
  /// **Equality contract assertion (Risk 3, debug mode only):**
  /// If the current and new values are considered equal by this state's
  /// equality function (`a == b` → true), their hash codes must also match.
  /// A violation indicates that type [T] implements `==` without a consistent
  /// `hashCode` override, which silently corrupts DRIP's deduplication logic.
  ///
  /// This check is performed via [assert] and is completely absent in release
  /// builds — zero production overhead.
  void write(T newValue) {
    // Debug-mode equality/hashCode contract check.
    // Runs only when the values are declared equal — that is the only path
    // where a hashCode mismatch can corrupt the graph.
    assert(() {
      final currentValue = _value;
      if (_equality.equals(currentValue, newValue)) {
        if (currentValue.hashCode != newValue.hashCode) {
          throw DripEqualityViolationError(
            valueType: T,
            hashCodeA: currentValue.hashCode,
            hashCodeB: newValue.hashCode,
          );
        }
      }
      return true;
    }());

    if (_equality.equals(_value, newValue)) return;

    if (DripTrace.isEnabled) {
      DripTrace.setCurrent(StackTrace.current);
    }

    _value = newValue;
    version++;
    DripBatch.instance.schedulePropagate(propagate);
  }

  void propagate() {
    // Iterate over a snapshot to avoid concurrent modification during notification.
    final subscribersSnapshot = List<Subscriber>.from(subscribers);
    for (final subscriber in subscribersSnapshot) {
      subscriber.markStale();
    }
  }
}

/// Shorthand constructor for [DripState].
DripState<T> dripState<T>(T value, {String? debugName}) =>
    DripState<T>(value, debugName: debugName);
