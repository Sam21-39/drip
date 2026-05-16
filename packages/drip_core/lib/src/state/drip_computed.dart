import '../errors/drip_errors.dart';
import '../tracking/tracking_context.dart';
import '../readable/drip_readable.dart';
import 'drip_state_base.dart';

/// A lazily evaluated, cached derived reactive value.
class DripComputed<T> extends DripStateBase
    implements Subscriber, DripReadable<T> {
  final T Function() _computation;
  final String? debugName;

  T? _cachedValue;
  bool _dirty = true;
  bool _evaluating = false;

  /// Maps source states to the version they had during the last evaluation.
  final Map<DripStateBase, int> _sourcesAtLastEval = {};

  DripComputed(this._computation, {this.debugName}) {
    assert(() {
      if (debugName == null) {
        print(
            'Drip Warning: DripComputed created without debugName. Set debugName for better stack traces.');
      }
      return true;
    }());
  }

  /// Returns the current value, recomputing if any dependency has changed.
  T get value {
    TrackingContext.current?.recordRead(this);

    if (_dirty || _sourcesChanged()) {
      recompute();
    }

    return _cachedValue as T;
  }

  bool _sourcesChanged() {
    if (_sourcesAtLastEval.isEmpty) return true;
    for (final entry in _sourcesAtLastEval.entries) {
      if (entry.key.version != entry.value) return true;
    }
    return false;
  }

  void recompute() {
    if (_evaluating) {
      throw DripCircularDependencyError(debugName);
    }

    _evaluating = true;
    try {
      // Unsubscribe from old sources.
      for (final source in _sourcesAtLastEval.keys) {
        source.removeSubscriber(this);
      }
      _sourcesAtLastEval.clear();

      final context = TrackingContext();
      _cachedValue = TrackingContext.withTracking(context, _computation);

      // Subscribe to new sources and record versions.
      final dependencies = context.collectDependencies();
      for (final dep in dependencies) {
        dep.addSubscriber(this);
        _sourcesAtLastEval[dep] = dep.version;
      }

      _dirty = false;
    } finally {
      _evaluating = false;
    }
  }

  @override
  void markStale() {
    if (_dirty) return;

    _dirty = true;
    version++;

    // Propagate staleness to downstream subscribers.
    final subscribersSnapshot = List<Subscriber>.from(subscribers);
    for (final subscriber in subscribersSnapshot) {
      subscriber.markStale();
    }
  }

  void dispose() {
    for (final source in _sourcesAtLastEval.keys) {
      source.removeSubscriber(this);
    }
    _sourcesAtLastEval.clear();
    clearAllSubscribers();
  }
}
