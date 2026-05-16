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
  ///
  /// **Resilient disposal guarantee (Risk 5 fix):** Every disposable is
  /// attempted regardless of whether an earlier one threw. All errors are
  /// collected and re-thrown together as a [DripDisposalError] after the loop
  /// completes. This ensures no resource is silently leaked due to a throw in
  /// an unrelated disposable.
  ///
  /// Invariant 3: Safe to call multiple times — subsequent calls are no-ops.
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;

    final errors = <Object>[];
    final stackTraces = <StackTrace>[];

    // LIFO disposal — iterate reversed so the last-registered is first disposed.
    for (final fn in _disposals.reversed) {
      try {
        fn();
      } catch (e, st) {
        errors.add(e);
        stackTraces.add(st);
      }
    }
    _disposals.clear();

    if (errors.isNotEmpty) {
      throw DripDisposalError(
        errors: errors,
        stackTraces: stackTraces,
        scopeDebugName: debugName,
      );
    }
  }

  void _assertActive() {
    if (_isDisposed) {
      throw DripDisposedScopeError(debugName);
    }
  }
}
