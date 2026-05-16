import 'package:drip_core/drip_core.dart';

/// Ergonomic extension methods for [DripReadable].
extension DripReadableX<T> on DripReadable<T> {
  /// Creates a computed value that maps this value to a string.
  ///
  /// If [format] is provided, it is used to format the value.
  DripComputed<String> asString([String Function(T value)? format]) {
    return DripComputed(() {
      final val = value;
      return format != null ? format(val) : val.toString();
    });
  }

  /// Creates a computed value that maps this value to a new value of type [R].
  DripComputed<R> map<R>(R Function(T value) fn) {
    return DripComputed(() => fn(value));
  }

  /// Creates a computed value that updates only when [guard] returns true.
  ///
  /// On the very first read, the value is always evaluated and cached
  /// regardless of the guard, to establish the initial state. Subsequent
  /// evaluations will only update the cached value if the guard passes.
  DripComputed<T> where(bool Function(T value) guard) {
    T? lastValue;
    bool hasValue = false;

    return DripComputed(() {
      final current = value;
      if (!hasValue || guard(current)) {
        lastValue = current;
        hasValue = true;
      }
      return lastValue as T;
    });
  }
}
