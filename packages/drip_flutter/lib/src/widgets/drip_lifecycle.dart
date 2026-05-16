import 'package:flutter/widgets.dart';
import '../node/drip_node.dart';

/// A widget that explicitly manages the lifecycle of a [DripNode] without
/// injecting it into the widget tree via [InheritedWidget].
///
/// This is the recommended context-free pattern for node management.
/// The node is created during `initState`, disposed during `dispose`, and
/// receives app lifecycle events (`onBackground`, `onForeground`).
///
/// The node is passed directly to the [builder] function. You should pass
/// state references from this node explicitly to descendant widgets.
class DripLifecycle<N extends DripNode> extends StatefulWidget {
  final N Function() create;
  final Widget Function(N node) builder;

  const DripLifecycle({
    super.key,
    required this.create,
    required this.builder,
  });

  @override
  State<DripLifecycle<N>> createState() => _DripLifecycleState<N>();
}

class _DripLifecycleState<N extends DripNode> extends State<DripLifecycle<N>>
    with WidgetsBindingObserver {
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
    return widget.builder(_node);
  }
}
