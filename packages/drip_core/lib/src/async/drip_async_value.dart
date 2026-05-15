import 'package:meta/meta.dart';

/// The sealed class representing async state.
@immutable
sealed class DripAsyncValue<T> {
  const DripAsyncValue();

  /// True if and only if this is [DripLoading].
  bool get isLoading => this is DripLoading<T>;

  /// True if and only if this is [DripData].
  bool get hasData => this is DripData<T>;

  /// True if and only if this is [DripError].
  bool get hasError => this is DripError<T>;

  /// Returns true if previousData is non-null in Loading or Error states.
  bool get hasPreviousData {
    final self = this;
    if (self is DripLoading<T>) return self.previousData != null;
    if (self is DripError<T>) return self.previousData != null;
    return false;
  }

  /// Returns the current value if [DripData], or [previousData] if available in other states.
  T? get dataOrNull {
    final self = this;
    if (self is DripData<T>) return self.value;
    if (self is DripLoading<T>) return self.previousData;
    if (self is DripError<T>) return self.previousData;
    return null;
  }

  /// Returns the available data or a fallback if no data is available.
  T getDataOr(T fallback) => dataOrNull ?? fallback;

  /// Transforms the data inside [DripData] or the [previousData] in other states.
  DripAsyncValue<R> map<R>(R Function(T value) transform) {
    final self = this;
    if (self is DripData<T>) {
      return DripData<R>(transform(self.value));
    } else if (self is DripLoading<T>) {
      final prev = self.previousData;
      return DripLoading<R>(
        previousData: prev != null ? transform(prev) : null,
      );
    } else if (self is DripError<T>) {
      final prev = self.previousData;
      return DripError<R>(
        self.error,
        self.stackTrace,
        previousData: prev != null ? transform(prev) : null,
      );
    }
    throw StateError('Unreachable DripAsyncValue state');
  }
}

/// Represents in-progress computation.
class DripLoading<T> extends DripAsyncValue<T> {
  final T? previousData;
  const DripLoading({this.previousData});
}

/// Represents successful completion.
class DripData<T> extends DripAsyncValue<T> {
  final T value;
  const DripData(this.value);
}

/// Represents failed computation.
class DripError<T> extends DripAsyncValue<T> {
  final Object error;
  final StackTrace stackTrace;
  final T? previousData;

  const DripError(this.error, this.stackTrace, {this.previousData});
}
