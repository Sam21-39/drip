import 'dart:collection';

/// The internal subscriber interface.
abstract interface class Subscriber {
  /// Notifies the subscriber that its dependency has changed.
  void markStale();
}

/// The abstract base class for all reactive nodes in the DRIP graph.
abstract class DripStateBase {
  /// The version clock for this state. Starts at 0 and increments on mutation.
  int version = 0;

  /// The set of subscribers watching this state.
  /// Using [LinkedHashSet] for deterministic iteration order during propagation.
  final Set<Subscriber> subscribers = LinkedHashSet<Subscriber>();

  /// Adds a subscriber to this state.
  void addSubscriber(Subscriber subscriber) {
    subscribers.add(subscriber);
  }

  /// Removes a subscriber from this state.
  void removeSubscriber(Subscriber subscriber) {
    subscribers.remove(subscriber);
  }

  /// Clears all subscribers. Used during disposal.
  void clearAllSubscribers() {
    subscribers.clear();
  }
}
