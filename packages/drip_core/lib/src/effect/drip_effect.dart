import '../batch/drip_batch.dart';
import '../scope/drip_scope.dart';
import '../state/drip_state_base.dart';
import '../tracking/tracking_context.dart';

/// A side-effect that re-runs automatically when its dependencies change.
class DripEffect implements Subscriber {
  final void Function() _fn;
  final String? debugName;

  bool _isDisposed = false;
  final Map<DripStateBase, int> _sources = {};

  DripEffect(this._fn, {this.debugName, DripScope? scope}) {
    if (scope != null) {
      scope.registerDisposal(dispose);
    }
    run();
  }

  void run() {
    if (_isDisposed) return;

    // Unsubscribe from old sources.
    for (final source in _sources.keys) {
      source.removeSubscriber(this);
    }
    _sources.clear();

    final context = TrackingContext();
    TrackingContext.withTracking(context, _fn);

    // Subscribe to new sources.
    final dependencies = context.collectDependencies();
    for (final dep in dependencies) {
      dep.addSubscriber(this);
      _sources[dep] = dep.version;
    }
  }

  @override
  void markStale() {
    if (_isDisposed) return;
    DripBatch.instance.scheduleEffect(run);
  }

  /// Cancels the effect and unsubscribes from all sources.
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;

    for (final source in _sources.keys) {
      source.removeSubscriber(this);
    }
    _sources.clear();
  }
}
