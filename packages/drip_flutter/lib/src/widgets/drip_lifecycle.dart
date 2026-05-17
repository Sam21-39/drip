import 'package:flutter/widgets.dart';
import '../node/drip_node.dart';

/// A high-level reactive lifecycle container that explicitly manages the mounting,
/// unmounting, scoping, and dependency injection boundaries of a [DripNode]
/// in a type-safe, context-free manner.
///
/// ### Core Architecture Philosophy
///
/// In traditional Flutter development, feature modules and state controllers are
/// often injected into the widget tree via `InheritedWidget` (e.g., using traditional
/// inherited providers or similar). While convenient, this couples business logic to the
/// widget tree structure and forces descendant widgets to resolve dependencies dynamically
/// via `BuildContext` lookups. This runtime lookup can lead to silent failures,
/// out-of-order execution, and deeply nested boilerplate code.
///
/// [DripLifecycle] solves this by establishing an explicit, context-free boundary:
///
/// 1. **Mounting**: When [DripLifecycle] is inserted into the tree, the [create]
///    callback is executed exactly once during `State.initState` to construct
///    the [DripNode] instance.
/// 2. **Context-Free DI & Resolution**: Instead of storing the node inside an
///    `InheritedWidget`, the created node is supplied directly to the [builder]
///    callback. Descendant widgets receive dependencies via standard Dart constructor
///    parameters or parameter forwarding. This guarantees that all state and dependency
///    lookups are statically typed, resolved at compile-time, and completely independent
///    of widget tree hierarchy.
/// 3. **Unmounting & Disposal**: When [DripLifecycle] is removed from the widget tree
///    (unmounted), `State.dispose` is invoked. The internal [DripNode] (and its owned
///    `DripScope`) is closed. This automatically unregisters all reactive listeners,
///    LIFO-clears child subscriptions, and disposes of all internal timers and resources
///    to eliminate memory leaks.
/// 4. **Rebuilding Isolation**: [DripLifecycle] itself does not listen to state
///    changes and will never trigger rebuilds of its descendant tree. Descendant widgets
///    should bind selectively to granular states using `DripBuilder` or direct
///    render-level bindings (such as `DripText`), isolating state mutations from
///    widget-level build cycles.
/// 5. **App Lifecycle Syncing**: The node automatically registers with the local
///    `WidgetsBindingObserver` to forward platform-level lifecycle notifications to
///    the node's `onBackground()` and `onForeground()` hooks.
///
/// ### Example Usage
///
/// ```dart
/// class CounterNode extends DripNode {
///   late final counter = state<int>(0, debugName: 'counter');
///
///   void increment() => counter.write(counter.value + 1);
/// }
///
/// class CounterScreen extends StatelessWidget {
///   const CounterScreen({super.key});
///
///   @override
///   Widget build(BuildContext context) {
///     return DripLifecycle<CounterNode>(
///       create: () => CounterNode(),
///       builder: (node) {
///         return Column(
///           children: [
///             DripBuilder<int>(
///               source: node.counter,
///               builder: (context, value) => Text('Count: $value'),
///             ),
///             ElevatedButton(
///               onPressed: node.increment,
///               child: const Text('Increment'),
///             ),
///           ],
///         );
///       },
///     );
///   }
/// }
/// ```
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
