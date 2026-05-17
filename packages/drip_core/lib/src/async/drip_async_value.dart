import 'package:meta/meta.dart';

/// The sealed class representing async state.
@immutable
sealed class DripAsyncValue<T> {
  const DripAsyncValue();

  /// True if and only if this is [DripAsyncLoading].
  bool get isLoading => this is DripAsyncLoading<T>;

  /// True if and only if this is [DripAsyncData].
  bool get hasData => this is DripAsyncData<T>;

  /// True if and only if this is [DripAsyncError].
  bool get hasError => this is DripAsyncError<T>;

  /// Returns true if previousData is non-null in Loading or Error states.
  bool get hasPreviousData {
    final self = this;
    if (self is DripAsyncLoading<T>) return self.previousData != null;
    if (self is DripAsyncError<T>) return self.previousData != null;
    return false;
  }

  /// Returns the current value if [DripAsyncData], or `previousData` if available in other states.
  T? get dataOrNull {
    final self = this;
    if (self is DripAsyncData<T>) return self.value;
    if (self is DripAsyncLoading<T>) return self.previousData;
    if (self is DripAsyncError<T>) return self.previousData;
    return null;
  }

  /// Returns the available data or a fallback if no data is available.
  T getDataOr(T fallback) => dataOrNull ?? fallback;

  /// Transforms the data inside [DripAsyncData] or the `previousData` in other states.
  DripAsyncValue<R> map<R>(R Function(T value) transform) {
    final self = this;
    if (self is DripAsyncData<T>) {
      return DripAsyncData<R>(transform(self.value));
    } else if (self is DripAsyncLoading<T>) {
      final prev = self.previousData;
      return DripAsyncLoading<R>(
        previousData: prev != null ? transform(prev) : null,
      );
    } else if (self is DripAsyncError<T>) {
      final prev = self.previousData;
      return DripAsyncError<R>(
        self.error,
        self.stackTrace,
        previousData: prev != null ? transform(prev) : null,
      );
    }
    throw StateError('Unreachable DripAsyncValue state');
  }
}

/// Represents in-progress computation.
class DripAsyncLoading<T> extends DripAsyncValue<T> {
  final T? previousData;
  const DripAsyncLoading({this.previousData});
}

/// Represents successful completion.
class DripAsyncData<T> extends DripAsyncValue<T> {
  final T value;
  const DripAsyncData(this.value);
}

/// Represents failed computation.
class DripAsyncError<T> extends DripAsyncValue<T> {
  final Object error;
  final StackTrace stackTrace;
  final T? previousData;

  const DripAsyncError(this.error, this.stackTrace, {this.previousData});
}
