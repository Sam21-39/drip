import 'package:drip_core/drip_core.dart';
import 'package:drip_flutter/drip_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test harness for driving [DripNode] lifecycle in unit tests.
class DripNodeTester<T extends DripNode> {
  /// Creates a node tester and instantiates the node.
  DripNodeTester(T Function() create) : node = create();

  /// The managed node instance.
  final T node;

  /// Triggers the node background lifecycle callback.
  void simulateBackground() {
    node.onBackground();
  }

  /// Triggers the node foreground lifecycle callback.
  void simulateForeground() {
    node.onForeground();
  }

  /// Disposes the managed node.
  void dispose() {
    node.dispose();
  }

  /// Registers [dispose] with test teardown.
  void registerTearDown() {
    addTearDown(dispose);
  }
}

/// Test helper for asserting [DripAsync] state transitions.
class DripAsyncTester<T> {
  /// Creates a helper for a specific async source.
  DripAsyncTester(this.source);

  /// Async source under test.
  final DripAsync<T> source;

  /// Waits for one microtask so state writes scheduled by async completions settle.
  Future<void> flush() => Future<void>.microtask(() {});

  /// Returns true when current state is loading.
  bool get isLoading => source.value is DripAsyncLoading<T>;

  /// Returns current data value when present, otherwise null.
  T? get dataOrNull => source.value.dataOrNull;

  /// Returns current error when present, otherwise null.
  Object? get errorOrNull {
    final value = source.value;
    return value is DripAsyncError<T> ? value.error : null;
  }

  /// Asserts the source is in loading state.
  void expectLoading() {
    if (!isLoading) {
      throw StateError('Expected loading state, but found ${source.value}.');
    }
  }

  /// Asserts the source holds [expected] data.
  void expectData(T expected) {
    final value = source.value;
    if (value is! DripAsyncData<T> || value.value != expected) {
      throw StateError('Expected data($expected), but found $value.');
    }
  }

  /// Asserts the source is in error state with [errorType].
  void expectErrorType(Type errorType) {
    final error = errorOrNull;
    if (error == null || error.runtimeType != errorType) {
      throw StateError(
        'Expected error type $errorType, but found ${error?.runtimeType}.',
      );
    }
  }
}
