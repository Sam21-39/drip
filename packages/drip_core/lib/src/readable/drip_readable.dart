import '../state/drip_state_base.dart' show DripListener;

/// The common interface for all readable reactive values.
abstract interface class DripReadable<T> {
  /// The current value.
  T get value;

  /// Registers a listener to be notified when the value changes.
  void subscribe(DripListener listener);

  /// Deregisters a previously registered listener.
  void unsubscribe(DripListener listener);
}
