import '../effect/drip_effect.dart';
import '../errors/drip_errors.dart';
import '../state/drip_computed.dart';
import '../state/drip_state.dart';

/// Lifetime owner of reactive resources.
class DripScope {
  final String? debugName;
  final DripScope? _parent;

  bool _isDisposed = false;
  final List<void Function()> _disposals = [];

  DripScope({this.debugName, DripScope? parent}) : _parent = parent {
    if (_parent != null) {
      _parent.registerDisposal(dispose);
    }
  }

  /// Registers a disposal function to be called when this scope is disposed.
  /// Disposals are executed in LIFO order.
  void registerDisposal(void Function() fn) {
    _assertActive();
    _disposals.add(fn);
  }

  /// Creates a [DripState] owned by this scope.
  DripState<T> state<T>(T initial, {String? debugName}) {
    final s = DripState<T>(initial, debugName: debugName);
    registerDisposal(s.clearAllSubscribers);
    return s;
  }

  /// Creates a [DripComputed] owned by this scope.
  DripComputed<T> computed<T>(T Function() fn, {String? debugName}) {
    final c = DripComputed<T>(fn, debugName: debugName);
    registerDisposal(c.dispose);
    return c;
  }

  /// Creates a [DripEffect] owned by this scope.
  DripEffect effect(void Function() fn, {String? debugName}) {
    return DripEffect(fn, debugName: debugName, scope: this);
  }

  /// Returns null in Phase 1. Full DI in Phase 3.
  T? resolve<T>() {
    // TODO(Phase 3): implement scoped DI
    return null;
  }

  /// Disposes all registered resources in LIFO order.
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;

    // LIFO disposal.
    for (final fn in _disposals.reversed) {
      try {
        fn();
      } catch (e) {
        // Log error but continue with other disposals.
        print('Error during DripScope disposal: $e');
      }
    }
    _disposals.clear();
  }

  void _assertActive() {
    if (_isDisposed) {
      throw DripDisposedScopeError(debugName);
    }
  }
}
