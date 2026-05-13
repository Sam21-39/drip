import '../batch/drip_batch.dart';
import '../equality/equality.dart';
import '../tracking/tracking_context.dart';
import 'drip_state_base.dart';

/// A public listener interface for external render-layer subscribers.
abstract interface class DripListener {
  /// Called when the bound state has changed.
  void onStateChanged();
}

/// Internal adapter to bridge [DripListener] to the core [Subscriber] interface.
class _ListenerSubscriber implements Subscriber {
  final DripListener listener;
  _ListenerSubscriber(this.listener);

  @override
  void markStale() => listener.onStateChanged();

  @override
  bool operator ==(Object other) =>
      other is _ListenerSubscriber && other.listener == listener;

  @override
  int get hashCode => listener.hashCode;
}

/// An atomic reactive value with a version clock and equality checking.
class DripState<T> extends DripStateBase {
  T _value;
  final String? debugName;
  final Equality<T> _equality;

  DripState(
    this._value, {
    this.debugName,
    Equality<T>? equality,
  }) : _equality = equality ?? defaultEquality<T>();

  /// The current value of this state.
  /// Records a dependency if a [TrackingContext] is active.
  T get value {
    TrackingContext.current?.recordRead(this);
    return _value;
  }

  /// Updates the value and schedules a propagation if the value has changed.
  void write(T newValue) {
    if (_equality.equals(_value, newValue)) return;

    _value = newValue;
    version++;
    DripBatch.instance.schedulePropagate(propagate);
  }

  /// Subscribes a [DripListener] to this state.
  void subscribe(DripListener listener) {
    addSubscriber(_ListenerSubscriber(listener));
  }

  /// Unsubscribes a [DripListener] from this state.
  void unsubscribe(DripListener listener) {
    removeSubscriber(_ListenerSubscriber(listener));
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
