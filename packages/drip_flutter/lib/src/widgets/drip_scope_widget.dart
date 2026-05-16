import 'package:flutter/widgets.dart';
import 'package:drip_core/drip_core.dart';

/// Extension to easily bind a [DripScope] to the Flutter widget lifecycle.
extension DripScopeWidgetX on DripScope {
  /// Returns a [StatefulWidget] that mounts this scope and disposes it when
  /// the widget is removed from the tree.
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
