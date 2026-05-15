/// A callback that takes no arguments and returns no value.
typedef VoidCallback = void Function();

/// The common interface for all readable reactive values.
abstract interface class DripReadable<T> {
  /// The current value.
  T get value;

  /// Registers a listener to be notified when the value changes.
  void addListener(VoidCallback listener);

  /// Deregisters a previously registered listener.
  void removeListener(VoidCallback listener);
}
