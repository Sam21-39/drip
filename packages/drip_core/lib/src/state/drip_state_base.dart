import 'dart:collection';
import '../readable/drip_readable.dart';

/// The internal subscriber interface.
abstract interface class Subscriber {
  /// Notifies the subscriber that its dependency has changed.
  void markStale();
}

/// Internal adapter to bridge [VoidCallback] to the core [Subscriber] interface.
class VoidCallbackSubscriber implements Subscriber {
  final VoidCallback callback;
  VoidCallbackSubscriber(this.callback);

  @override
  void markStale() => callback();

  @override
  bool operator ==(Object other) =>
      other is VoidCallbackSubscriber && other.callback == callback;

  @override
  int get hashCode => callback.hashCode;
}

/// The abstract base class for all reactive nodes in the DRIP graph.
abstract class DripStateBase {
  /// The version clock for this state. Starts at 0 and increments on mutation.
  int version = 0;

  /// The set of subscribers watching this state.
  /// Using [LinkedHashSet] for deterministic iteration order during propagation.
  final Set<Subscriber> subscribers = <Subscriber>{};

  /// Adds a subscriber to this state.
  void addSubscriber(Subscriber subscriber) {
    subscribers.add(subscriber);
  }

  /// Removes a subscriber from this state.
  void removeSubscriber(Subscriber subscriber) {
    subscribers.remove(subscriber);
  }

  /// Registers a listener via the public [DripReadable] interface.
  void addListener(VoidCallback listener) {
    addSubscriber(VoidCallbackSubscriber(listener));
  }

  /// Removes a listener via the public [DripReadable] interface.
  void removeListener(VoidCallback listener) {
    removeSubscriber(VoidCallbackSubscriber(listener));
  }

  /// Clears all subscribers. Used during disposal.
  void clearAllSubscribers() {
    subscribers.clear();
  }
}
