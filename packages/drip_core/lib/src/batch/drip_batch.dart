import 'dart:collection';

/// A package-private singleton for coalescing synchronous writes.
class DripBatch {
  DripBatch._();

  static final DripBatch instance = DripBatch._();

  bool _scheduled = false;
  final Set<void Function()> _propagations = LinkedHashSet<void Function()>();
  final Set<void Function()> _effects = LinkedHashSet<void Function()>();

  /// Schedules a propagation function to run in the next microtask.
  void schedulePropagate(void Function() fn) {
    _propagations.add(fn);
    _ensureScheduled();
  }

  /// Schedules an effect function to run in the next microtask.
  void scheduleEffect(void Function() fn) {
    _effects.add(fn);
    _ensureScheduled();
  }

  void _ensureScheduled() {
    if (_scheduled) return;
    _scheduled = true;
    Future.microtask(_flush);
  }

  void _flush() {
    _scheduled = false;

    // Snapshot and clear propagations first.
    final propagationsSnapshot = List<void Function()>.from(_propagations);
    _propagations.clear();
    for (final fn in propagationsSnapshot) {
      fn();
    }

    // Snapshot and clear effects after all propagations.
    final effectsSnapshot = List<void Function()>.from(_effects);
    _effects.clear();
    for (final fn in effectsSnapshot) {
      fn();
    }
  }
}
