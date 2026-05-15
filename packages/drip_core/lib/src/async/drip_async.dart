import 'dart:async';

import '../scope/drip_scope.dart';
import '../state/drip_state.dart';
import 'drip_async_value.dart';

/// A reactive async state container.
class DripAsync<T> extends DripState<DripAsyncValue<T>> {
  int _runGeneration = 0;

  /// Creates a new async state.
  /// Initial value is [DripLoading] with no previous data.
  DripAsync({String? debugName, DripScope? scope})
      : super(DripLoading<T>(), debugName: debugName) {
    if (scope != null) {
      scope.registerDisposal(clearAllSubscribers);
    }
  }

  /// Writes a new [DripLoading], preserving [previousData] from current state.
  void setLoading() {
    final current = value;
    if (current is DripLoading<T>) {
      // Retain its previous data (no double-wrap)
      write(DripLoading<T>(previousData: current.previousData));
    } else {
      write(DripLoading<T>(previousData: current.dataOrNull));
    }
  }

  /// Writes [DripData]. Always successful.
  void setData(T value) {
    write(DripData<T>(value));
  }

  /// Writes [DripError], preserving [previousData] from current state.
  void setError(Object error, StackTrace stackTrace) {
    write(DripError<T>(error, stackTrace, previousData: value.dataOrNull));
  }

  /// Executes [computation], transitioning through states.
  /// Uses a generation counter to ensure concurrent calls do not overwrite newer results.
  Future<void> run(Future<T> Function() computation) async {
    final generation = ++_runGeneration;
    setLoading();

    try {
      final result = await computation();
      if (_runGeneration == generation) {
        setData(result);
      }
    } catch (e, st) {
      if (_runGeneration == generation) {
        setError(e, st);
      }
    }
  }

  /// Creates a [DripAsync], immediately calls [run] with the given future,
  /// and registers disposal with [scope].
  static DripAsync<T> fromFuture<T>(Future<T> future, {DripScope? scope}) {
    final asyncState = DripAsync<T>(scope: scope);
    asyncState.run(() => future);
    return asyncState;
  }

  /// Creates a [DripAsync] and immediately begins listening to [stream].
  /// On stream error event: calls [setError]. Does NOT cancel subscription.
  /// On stream done event: retains last state. Does NOT transition to loading.
  static DripAsync<T> fromStream<T>(Stream<T> stream, {DripScope? scope}) {
    final asyncState = DripAsync<T>(scope: scope);

    final subscription = stream.listen(
      (data) => asyncState.setData(data),
      onError: (Object error, StackTrace stackTrace) =>
          asyncState.setError(error, stackTrace),
      onDone: () {},
    );

    if (scope != null) {
      scope.registerDisposal(subscription.cancel);
    } else {
      assert(false,
          'DripAsync.fromStream called without a scope. The stream subscription will leak.');
    }

    return asyncState;
  }
}
