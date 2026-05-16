import 'dart:collection';

/// A reactive list with item-level subscriber granularity.
///
/// Unlike a `DripState<List<T>>` which notifies all subscribers on any mutation,
/// `DripList<T>` maintains a separate set of listeners for each index.
/// Updating the item at index `i` only notifies the listener for that index,
/// enabling zero-rebuild granular updates in `DripListView`.
@Deprecated(
    'Use DripState<List<T>> + DripBuilder. Scheduled for removal in 0.8.0-rc.')
class DripList<T> {
  final List<T> _items;
  final List<Set<void Function()>> _indexListeners;
  final Set<void Function()> _structuralListeners = {};

  /// Creates a reactive list with the given [initial] items.
  DripList(List<T> initial)
      : _items = List<T>.of(initial),
        _indexListeners =
            List.generate(initial.length, (_) => <void Function()>{});

  /// The current number of items in the list.
  int get length => _items.length;

  /// Returns an unmodifiable view of the backing list.
  /// Used for reading the entire list synchronously.
  List<T> get items => UnmodifiableListView<T>(_items);

  /// Returns the item at the given [index].
  T operator [](int index) {
    return _items[index];
  }

  /// Updates the item at the given [index].
  ///
  /// Only the listeners registered for this specific index are notified.
  /// Structural listeners are not notified.
  void operator []=(int index, T value) {
    if (_items[index] == value) return;
    _items[index] = value;
    _notifyIndex(index);
  }

  /// Appends [item] to the end of the list.
  ///
  /// Structural listeners are notified.
  void add(T item) {
    _items.add(item);
    _indexListeners.add(<void Function()>{});
    _notifyStructural();
  }

  /// Inserts [item] at the specified [index].
  ///
  /// Index listeners are shifted accordingly. Structural listeners are notified.
  void insert(int index, T item) {
    _items.insert(index, item);
    _indexListeners.insert(index, <void Function()>{});
    _notifyStructural();
  }

  /// Removes the item at the specified [index].
  ///
  /// Index listeners are shifted down. Structural listeners are notified.
  void removeAt(int index) {
    _items.removeAt(index);
    _indexListeners.removeAt(index);
    _notifyStructural();
  }

  /// Convenience method to update the item at [index] using an [updater] function.
  void update(int index, T Function(T current) updater) {
    this[index] = updater(this[index]);
  }

  /// Replaces the entire list with [newItems].
  ///
  /// Reconciles listener sets and notifies structural listeners.
  void replaceAll(List<T> newItems) {
    _items.clear();
    _items.addAll(newItems);

    if (_indexListeners.length > newItems.length) {
      _indexListeners.removeRange(newItems.length, _indexListeners.length);
    } else if (_indexListeners.length < newItems.length) {
      final diff = newItems.length - _indexListeners.length;
      for (var i = 0; i < diff; i++) {
        _indexListeners.add(<void Function()>{});
      }
    }

    _notifyStructural();
  }

  /// Disposes all internal listener sets.
  ///
  /// Called automatically when the owning `DripNode` is disposed.
  void dispose() {
    _structuralListeners.clear();
    for (final listeners in _indexListeners) {
      listeners.clear();
    }
    _indexListeners.clear();
  }

  /// Registers a listener that is called when the length of the list changes
  /// (e.g., via [add], [insert], [removeAt], [replaceAll]).
  void addStructuralListener(void Function() listener) {
    _structuralListeners.add(listener);
  }

  /// Deregisters a structural listener.
  void removeStructuralListener(void Function() listener) {
    _structuralListeners.remove(listener);
  }

  /// Registers a listener for a specific index. It is notified when `list[index] = value` is called.
  void addIndexListener(int index, void Function() listener) {
    _indexListeners[index].add(listener);
  }

  /// Deregisters an index listener.
  void removeIndexListener(int index, void Function() listener) {
    if (index < _indexListeners.length) {
      _indexListeners[index].remove(listener);
    }
  }

  void _notifyStructural() {
    final listeners = _structuralListeners.toList();
    for (final listener in listeners) {
      listener();
    }
  }

  void _notifyIndex(int index) {
    if (index >= _indexListeners.length) return;
    final listeners = _indexListeners[index].toList();
    for (final listener in listeners) {
      listener();
    }
  }
}
