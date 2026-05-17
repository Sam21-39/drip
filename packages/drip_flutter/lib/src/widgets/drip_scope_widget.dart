import 'package:flutter/widgets.dart';
import 'package:drip_core/drip_core.dart';

/// Extension to easily bind a [DripScope] to the Flutter widget lifecycle.
extension DripScopeWidgetX on DripScope {
  /// Binds the lifecycle of this [DripScope] directly to a Flutter widget's lifecycle,
  /// automatically disposing the scope when the widget is unmounted.
  ///
  /// ### Mounting, Unmounting, and Memory Management
  ///
  /// A [DripScope] holds registrations, reactive states, computed values, and active
  /// listeners. Managing the lifetime of these resources is critical to preventing
  /// memory leaks:
  ///
  /// - **Mounting**: When the returned [Widget] is mounted, it retains a reference
  ///   to this [DripScope].
  /// - **Unmounting**: When the widget is permanently unmounted from the element tree,
  ///   its state's `dispose()` method is triggered, which immediately calls [dispose]
  ///   on this [DripScope].
  ///
  /// ### Scoping, DI, and Rebuilding
  ///
  /// - **Scoping & DI**: This extension provides a low-level bridge for context-free
  ///   scoping of pure Dart reactive states. It allows a business logic controller
  ///   or dependency container (which operates entirely outside Flutter) to sync its
  ///   lifetime with a specific screen or sub-tree.
  /// - **Rebuilding**: The wrapper widget does not listen to state changes, ensuring
  ///   that state updates do not trigger unnecessary widget rebuilding cycles. Descendants
  ///   retain fine-grained control over rebuilding boundaries.
  ///
  /// ### Example Usage
  ///
  /// ```dart
  /// class SearchController {
  ///   final scope = DripScope();
  ///   late final query = DripState<String>('', scope: scope);
  ///   late final results = DripComputed<List<String>>(() {
  ///     return searchDatabase(query.value);
  ///   }, scope: scope);
  /// }
  ///
  /// class SearchScreen extends StatefulWidget {
  ///   const SearchScreen({super.key});
  ///
  ///   @override
  ///   State<SearchScreen> createState() => _SearchScreenState();
  /// }
  ///
  /// class _SearchScreenState extends State<SearchScreen> {
  ///   final controller = SearchController();
  ///
  ///   @override
  ///   Widget build(BuildContext context) {
  ///     // Binds the lifecycle of controller.scope to the widget tree.
  ///     // When SearchScreen is unmounted, controller.scope is automatically disposed.
  ///     return controller.scope.asWidget(
  ///       child: Column(
  ///         children: [
  ///           TextField(
  ///             onChanged: controller.query.write,
  ///           ),
  ///           Expanded(
  ///             child: DripBuilder<List<String>>(
  ///               source: controller.results,
  ///               builder: (context, list) => ListView(
  ///                 children: list.map((item) => Text(item)).toList(),
  ///               ),
  ///             ),
  ///           ),
  ///         ],
  ///       ),
  ///     );
  ///   }
  /// }
  /// ```
  Widget asWidget({required Widget child}) {
    return _DripScopeWidget(scope: this, child: child);
  }
}

/// The internal widget used by [DripScope.asWidget].
class _DripScopeWidget extends StatefulWidget {
  final DripScope scope;
  final Widget child;

  const _DripScopeWidget({
    required this.scope,
    required this.child,
  });

  @override
  State<_DripScopeWidget> createState() => _DripScopeWidgetState();
}

class _DripScopeWidgetState extends State<_DripScopeWidget> {
  @override
  void dispose() {
    widget.scope.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
