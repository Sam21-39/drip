import 'package:meta/meta.dart';
import 'package:drip_core/drip_core.dart';

/// Abstract feature module with an owned [DripScope].
///
/// [DripNode] is a convenience base class for grouping related reactive state,
/// computed values, effects, and dependencies behind a shared lifecycle. It is
/// not a required DRIP pattern, and there is no performance difference between
/// using a node and using a plain Dart class that owns a [DripScope]. The node
/// adds only a default scope, standardized [onInit] and [onDispose] hooks, and a
/// debug name based on the runtime type unless one is provided.
///
/// The two examples below are equivalent:
///
/// ```dart
/// class CounterNode extends DripNode {
///   late final count = state(0, debugName: 'count');
///   late final doubled = computed(() => count.value * 2);
///
///   void increment() => count.write(count.value + 1);
/// }
///
/// class CounterModel {
///   final scope = DripScope(debugName: 'CounterModel');
///   late final count = scope.state(0, debugName: 'count');
///   late final doubled = scope.computed(() => count.value * 2);
///
///   void increment() => count.write(count.value + 1);
///   void dispose() => scope.dispose();
/// }
/// ```
abstract class DripNode {
  late final DripScope _scope;

  /// The internal scope for this node.
  @protected
  DripScope get scope => _scope;

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

  /// Registers a disposal callback bounded to this node's scope.
  void registerDisposal(void Function() fn) {
    _scope.registerDisposal(fn);
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
