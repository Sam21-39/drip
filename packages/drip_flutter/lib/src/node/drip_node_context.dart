import 'package:flutter/widgets.dart';
import 'drip_node.dart';
import 'drip_node_provider.dart';

/// Ergonomic extension for looking up a [DripNode] from the widget tree.
extension DripNodeContextExtension on BuildContext {
  /// Retrieves the nearest [DripNode] of type [N] from the widget tree.
  ///
  /// This is equivalent to `DripNodeProvider.of<N>(this)`.
  /// Throws a [FlutterError] if no such node is found.
  N node<N extends DripNode>() {
    return DripNodeProvider.of<N>(this);
  }

  /// Retrieves the nearest [DripNode] of type [N] from the widget tree,
  /// or returns null if no such node is found.
  ///
  /// Useful for optional feature nodes that may or may not be present.
  N? maybeNode<N extends DripNode>() {
    // We cannot use DripNodeProvider.of because it throws if not found.
    // Instead we do the InheritedWidget lookup directly but don't throw.
    // We have to rely on DripNodeProvider.of internally or repeat lookup,
    // but _DripNodeInheritedWidget is private. We can just use a helper
    // function on DripNodeProvider or do a try-catch.
    try {
      return DripNodeProvider.of<N>(this);
    } catch (e) {
      if (e is FlutterError && e.message.contains('No DripNodeProvider')) {
        return null;
      }
      rethrow;
    }
  }
}
