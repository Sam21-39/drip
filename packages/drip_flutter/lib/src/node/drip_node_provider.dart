import 'package:flutter/widgets.dart';
import 'drip_node.dart';

/// An [InheritedWidget] that provides a [DripNode] to its descendants.
///
/// This is an internal implementation detail. Developers should use
/// [DripNodeProvider] to mount a node, and [DripNodeProvider.of] to read it.
class _DripNodeInheritedWidget<N extends DripNode> extends InheritedWidget {
  final N node;

  const _DripNodeInheritedWidget({
    super.key,
    required this.node,
    required super.child,
  });

  @override
  bool updateShouldNotify(covariant _DripNodeInheritedWidget<N> oldWidget) {
    // The node instance never changes. Reactive updates happen via DripState.
    return false;
  }
}

/// A Flutter widget that mounts, provides, and disposes a [DripNode].
///
/// Use this widget to inject a feature module into the widget tree.
/// It owns the lifecycle of the node:
/// 1. Creates the node on mount via the [create] factory.
/// 2. Listens to app lifecycle events and forwards them to [DripNode.onBackground]
///    and [DripNode.onForeground].
/// 3. Disposes the node when unmounted.
class DripNodeProvider<N extends DripNode> extends StatefulWidget {
  final N Function() create;
  final Widget Function(BuildContext context, N node) builder;

  const DripNodeProvider({
    super.key,
    required this.create,
    required this.builder,
  });

  /// Retrieves the nearest [DripNode] of type [N] from the widget tree.
  ///
  /// Throws a [FlutterError] if no such node is found.
  static N of<N extends DripNode>(BuildContext context) {
    final inherited = context
        .dependOnInheritedWidgetOfExactType<_DripNodeInheritedWidget<N>>();
    if (inherited == null) {
      throw FlutterError(
        'DripNodeProvider.of() called with a context that does not contain a DripNode of type $N.\n'
        'No DripNodeProvider<$N> found in the widget tree. Make sure to wrap your '
        'feature subtree with DripNodeProvider<$N>.',
      );
    }
    return inherited.node;
  }

  @override
  State<DripNodeProvider<N>> createState() => _DripNodeProviderState<N>();
}

class _DripNodeProviderState<N extends DripNode>
    extends State<DripNodeProvider<N>> with WidgetsBindingObserver {
  late final N _node;

  @override
  void initState() {
    super.initState();
    _node = widget.create();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _node.onBackground();
    } else if (state == AppLifecycleState.resumed) {
      _node.onForeground();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _DripNodeInheritedWidget<N>(
      node: _node,
      child: Builder(
        builder: (context) => widget.builder(context, _node),
      ),
    );
  }
}
