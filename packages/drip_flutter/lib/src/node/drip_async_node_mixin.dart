import 'dart:async';
import 'package:drip_core/drip_core.dart';
import 'drip_node.dart';

/// A mixin that adds async helpers to [DripNode] subclasses.
///
/// These helpers automatically register the [DripAsync] state with the
/// node's [DripScope] for automatic disposal.
mixin DripAsyncNodeMixin on DripNode {
  /// Executes a computation and returns a scoped [DripAsync] state.
  DripAsync<T> runAsync<T>(Future<T> Function() computation,
      {String? debugName}) {
    final state = DripAsync<T>(debugName: debugName, scope: scope);
    state.run(computation);
    return state;
  }

  /// Watches a stream and returns a scoped [DripAsync] state.
  DripAsync<T> watchStream<T>(Stream<T> stream, {String? debugName}) {
    return DripAsync.fromStream<T>(stream, scope: scope);
  }
}
