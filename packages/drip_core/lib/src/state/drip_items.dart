import '../equality/equality.dart';
import 'drip_state.dart';

/// A highly-granular reactive index-addressable collection of [DripState] elements.
///
/// Under the hood, [DripItems] is a [DripState] that holds a list of [DripState]s:
/// [DripState<List<DripState<T>>>].
///
/// **Reactivity Invariants**:
/// 1. Element writes (`dripItems[index].write(value)` or `dripItems[index] = value`)
///    notify only the subscribers of that individual element. They do **not** schedule
///    propagation for the outer [DripItems] state (no list-level rebuilds).
/// 2. Structural changes (`add`, `insert`, `removeAt`, `replaceAll`, etc.)
///    mutate the collection structurally, notifying all list-level subscribers.
class DripItems<T> extends DripState<List<DripState<T>>> {
  final List<DripState<T>> _list;

  /// Creates a reactive [DripItems] collection with the given [initial] elements.
  DripItems(List<T> initial,
      {String? debugName, Equality<List<DripState<T>>>? equality})
      : _list = initial
            .map((item) => DripState<T>(item,
                debugName: debugName != null ? '${debugName}_item' : null))
            .toList(),
        super(
          initial
              .map((item) => DripState<T>(item,
                  debugName: debugName != null ? '${debugName}_item' : null))
              .toList(),
          debugName: debugName,
          equality: equality,
        );

  /// Returns the number of items in this collection.
  int get length {
    // Records a read on this outer DripItems state
    return value.length;
  }

  /// Checks whether the index is within valid bounds.
  void _checkBounds(int index) {
    if (index < 0 || index >= _list.length) {
      throw RangeError.index(index, _list, 'DripItems');
    }
  }

  /// Returns the reactive [DripState<T>] element at the specified [index].
  ///
  /// **Read tracking**: Accessing an element via operator `[]` does **not** record
  /// a read dependency on the outer list structure. If you need to subscribe to the
  /// structure (e.g. list length, item presence), subscribe to the list state directly
  /// (e.g. via `value`).
  DripState<T> operator [](int index) {
    _checkBounds(index);
    return _list[index];
  }

  /// Updates the value of the [DripState<T>] at the specified [index].
  ///
  /// This operates directly on the element state, which avoids notifying list-level
  /// structural subscribers.
  void operator []=(int index, T newValue) {
    _checkBounds(index);
    _list[index].write(newValue);
  }

  /// Appends [item] to the end of the collection, notifying list-level structural subscribers.
  void add(T item) {
    final newItem = DripState<T>(
      item,
      debugName: debugName != null ? '${debugName}_item_${_list.length}' : null,
    );
    _list.add(newItem);
    write(List<DripState<T>>.of(_list));
  }

  /// Appends all [items] to the collection, notifying list-level structural subscribers.
  void addAll(Iterable<T> items) {
    final newStates = items.map((item) => DripState<T>(
          item,
          debugName:
              debugName != null ? '${debugName}_item_${_list.length}' : null,
        ));
    _list.addAll(newStates);
    write(List<DripState<T>>.of(_list));
  }

  /// Inserts [item] at [index], notifying list-level structural subscribers.
  void insert(int index, T item) {
    if (index < 0 || index > _list.length) {
      throw RangeError.range(
          index, 0, _list.length, 'index', 'DripItems.insert');
    }
    final newItem = DripState<T>(
      item,
      debugName: debugName != null ? '${debugName}_item' : null,
    );
    _list.insert(index, newItem);
    write(List<DripState<T>>.of(_list));
  }

  /// Removes the item at [index], notifying list-level structural subscribers.
  DripState<T> removeAt(int index) {
    _checkBounds(index);
    final removed = _list.removeAt(index);
    write(List<DripState<T>>.of(_list));
    return removed;
  }

  /// Removes the first element matching the given [item] value, notifying list-level structural subscribers.
  bool remove(T item) {
    final index = _list.indexWhere((element) => element.value == item);
    if (index != -1) {
      _list.removeAt(index);
      write(List<DripState<T>>.of(_list));
      return true;
    }
    return false;
  }

  /// Clears all elements from the collection, notifying list-level structural subscribers.
  void clear() {
    _list.clear();
    write(List<DripState<T>>.of(_list));
  }

  /// Replaces the entire collection with [newItems], notifying list-level structural subscribers.
  void replaceAll(List<T> newItems) {
    _list.clear();
    _list.addAll(newItems.map((item) => DripState<T>(
          item,
          debugName: debugName != null ? '${debugName}_item' : null,
        )));
    write(List<DripState<T>>.of(_list));
  }

  /// Disposes this collection and cleans up all element-level subscribers.
  void dispose() {
    clearAllSubscribers();
    for (final element in _list) {
      element.clearAllSubscribers();
    }
    _list.clear();
  }
}
