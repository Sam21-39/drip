import 'dart:async';
import 'package:drip_core/drip_core.dart';
import 'drip_node.dart';

/// A mixin that adds async helpers to [DripNode] subclasses.
mixin DripAsyncNode on DripNode {
  /// Creates a [DripAsync] with [DripLoading] as its initial state.
  /// Automatically scopes it to the node's lifecycle.
  DripAsync<T> asyncState<T>({String? debugName}) {
    final state = DripAsync<T>(debugName: debugName);
    registerDisposal(state.clearAllSubscribers);
    return state;
  }

  /// Creates a [DripAsync], automatically scopes it to the node's lifecycle,
  /// immediately calls [DripAsync.run] with the given computation, and returns the state.
  DripAsync<T> asyncFromFuture<T>(Future<T> Function() computation, {String? debugName}) {
    final state = DripAsync<T>(debugName: debugName);
    registerDisposal(state.clearAllSubscribers);
    state.run(computation);
    return state;
  }

  /// Creates a [DripAsync], automatically scopes it to the node's lifecycle,
  /// begins listening to the [stream], and returns the state.
  DripAsync<T> asyncFromStream<T>(Stream<T> stream, {String? debugName}) {
    final state = DripAsync<T>(debugName: debugName);
    
    final subscription = stream.listen(
      (data) => state.setData(data),
      onError: (Object error, StackTrace stackTrace) => state.setError(error, stackTrace),
      onDone: () {},
    );
    
    registerDisposal(() {
      subscription.cancel();
      state.clearAllSubscribers();
    });
    
    return state;
  }
}
