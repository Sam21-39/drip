import 'package:flutter/widgets.dart';
import 'drip_node.dart';
import 'drip_node_provider.dart';

/// A [DripNode] variant whose lifecycle is additionally bound to a navigation route.
abstract class DripRouteNode extends DripNode {
  DripRouteNode({super.debugName});

  /// Called when the route this node is associated with becomes the active route
  /// (either pushed onto the navigator stack, or returned to via pop).
  void onRouteEnter() {}

  /// Called when the route is no longer active (another route is pushed on top,
  /// or this route is popped).
  void onRouteLeave() {}
}

/// A [DripNodeProvider] variant that binds a [DripRouteNode] to a [RouteObserver].
class DripRouteNodeProvider<N extends DripRouteNode>
    extends DripNodeProvider<N> {
  final RouteObserver<ModalRoute<dynamic>> routeObserver;

  const DripRouteNodeProvider({
    super.key,
    required super.create,
    required super.builder,
    required this.routeObserver,
  });

  @override
  State<DripNodeProvider<N>> createState() => _DripRouteNodeProviderState<N>();
}

class _DripRouteNodeProviderState<N extends DripRouteNode>
    extends State<DripRouteNodeProvider<N>> {
  late final N _node;

  @override
  void initState() {
    super.initState();
    // Create the node here to own its lifecycle at this level
    _node = widget.create();
  }

  @override
  Widget build(BuildContext context) {
    // We compose the original DripNodeProvider to handle the InheritedWidget
    // and standard lifecycle events (background/foreground, dispose).
    return DripNodeProvider<N>(
      create: () => _node,
      builder: (context, node) {
        return _RouteObserverWrapper<N>(
          node: node,
          routeObserver: widget.routeObserver,
          child: widget.builder(context, node),
        );
      },
    );
  }
}

class _RouteObserverWrapper<N extends DripRouteNode> extends StatefulWidget {
  final N node;
  final RouteObserver<ModalRoute<dynamic>> routeObserver;
  final Widget child;

  const _RouteObserverWrapper({
    required this.node,
    required this.routeObserver,
    required this.child,
  });

  @override
  State<_RouteObserverWrapper<N>> createState() =>
      _RouteObserverWrapperState<N>();
}

class _RouteObserverWrapperState<N extends DripRouteNode>
    extends State<_RouteObserverWrapper<N>> with RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) {
      widget.routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    widget.routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPush() {
    widget.node.onRouteEnter();
  }

  @override
  void didPopNext() {
    widget.node.onRouteEnter();
  }

  @override
  void didPushNext() {
    widget.node.onRouteLeave();
  }

  @override
  void didPop() {
    widget.node.onRouteLeave();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
