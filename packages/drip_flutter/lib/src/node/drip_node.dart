import 'package:drip_core/drip_core.dart';
import '../list/drip_list.dart';

/// Abstract feature module with an owned [DripScope].
///
/// Encapsulates state, computed values, side effects, and dependencies.
/// All reactive resources created via [state], [computed], [effect], and [list]
/// are bound to the node's lifecycle and are automatically disposed when
/// the node is disposed.
abstract class DripNode {
  late final DripScope _scope;

  final Map<Type, Object? Function()> _factories = {};
  final Map<Type, Object?> _singletons = {};
  final Set<Type> _resolvedTypes = {};

  bool _isDisposed = false;

  /// Creates a node and runs its [onInit] lifecycle hook.
  DripNode({String? debugName}) {
    _scope = DripScope(debugName: debugName ?? runtimeType.toString());
    onInit();
  }

  /// Lifecycle hook called at the end of node construction.
  /// Override to register DI bindings and initialize state.
  void onInit() {}

  /// Lifecycle hook called before the node is fully disposed.
  /// Override to perform custom cleanup before reactive resources are destroyed.
  void onDispose() {}

  /// Lifecycle hook called when the application enters the background.
  void onBackground() {}

  /// Lifecycle hook called when the application enters the foreground.
  void onForeground() {}

  /// Creates a [DripState] owned by this node's scope.
  DripState<T> state<T>(T initial, {String? debugName}) {
    return _scope.state<T>(initial, debugName: debugName);
  }

  /// Creates a [DripComputed] owned by this node's scope.
  DripComputed<T> computed<T>(T Function() fn, {String? debugName}) {
    return _scope.computed<T>(fn, debugName: debugName);
  }

  /// Creates a [DripEffect] owned by this node's scope.
  DripEffect effect(void Function() fn, {String? debugName}) {
    return _scope.effect(fn, debugName: debugName);
  }

  /// Creates a [DripList] owned by this node.
  DripList<T> list<T>(List<T> initial) {
    final list = DripList<T>(initial);
    _scope.registerDisposal(list.dispose);
    return list;
  }

  /// Registers a dependency factory for type [T].
  ///
  /// If [singleton] is true (default), the factory is invoked once upon
  /// the first [resolve] call, and the instance is cached.
  /// If [singleton] is false, the factory is invoked on every [resolve] call.
  void register<T>(T Function() factory, {bool singleton = true}) {
    if (_resolvedTypes.contains(T)) {
      throw StateError(
          'Cannot register type $T: it has already been resolved.');
    }
    if (singleton) {
      _factories[T] = () {
        if (!_singletons.containsKey(T)) {
          _singletons[T] = factory();
        }
        return _singletons[T];
      };
    } else {
      _factories[T] = factory;
    }
  }

  /// Resolves the registered dependency for type [T].
  ///
  /// Throws a [StateError] if [T] has not been registered.
  T resolve<T>() {
    final factory = _factories[T];
    if (factory == null) {
      throw StateError(
          '$T not registered in $runtimeType. Call register<$T>(() => ...) in onInit().');
    }
    _resolvedTypes.add(T);
    return factory() as T;
  }

  /// Disposes this node, its scope, and all cached singletons.
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;

    onDispose();
    _scope.dispose();

    _singletons.clear();
    _factories.clear();
    _resolvedTypes.clear();
  }
}
