import 'dart:async';

import 'package:meta/meta.dart';

import '../debug/drip_trace.dart';
import 'drip_scheduler_config.dart';

/// Signature for a post-frame callback registrar.
///
/// `drip_flutter` injects [SchedulerBinding.instance.addPostFrameCallback]
/// here at startup so that [DripBatch] can yield to the frame pipeline under
/// high write pressure without importing Flutter into `drip_core`.
typedef PostFrameScheduler = void Function(void Function(Duration) callback);

/// A package-private singleton for coalescing synchronous writes.
///
/// ## Microtask pressure control (Risk 2 fix)
///
/// Under normal write volumes, propagation is scheduled via [Future.microtask].
/// When the number of pending propagations reaches or exceeds
/// [DripSchedulerConfig.microtaskThreshold], and a [postFrameScheduler] has
/// been injected, [DripBatch] switches to scheduling via a post-frame callback.
/// This yields to the Flutter frame pipeline, preventing jank caused by
/// microtask queue saturation.
///
/// If no [postFrameScheduler] is set (e.g., in pure-Dart environments),
/// microtask scheduling is always used regardless of threshold.
class DripBatch {
  DripBatch._();

  static final DripBatch instance = DripBatch._();

  bool _scheduled = false;
  bool _usingPostFrame = false;

  /// Tracks pending propagation count for threshold detection.
  int _pendingCount = 0;

  final Set<void Function()> _propagations = <void Function()>{};
  final Set<void Function()> _effects = <void Function()>{};

  /// Optional post-frame scheduler injected by `drip_flutter`.
  ///
  /// Set via [setPostFrameScheduler] during Flutter app initialization.
  /// When null, [DripBatch] always uses microtask scheduling.
  PostFrameScheduler? _postFrameScheduler;

  /// Injects the post-frame scheduler.
  ///
  /// Call this once during Flutter app startup:
  /// ```dart
  /// DripBatch.instance.setPostFrameScheduler(
  ///   SchedulerBinding.instance.addPostFrameCallback,
  /// );
  /// ```
  void setPostFrameScheduler(PostFrameScheduler scheduler) {
    _postFrameScheduler = scheduler;
  }

  /// Schedules a propagation function to run in the next batch.
  void schedulePropagate(void Function() fn) {
    _propagations.add(fn);
    _pendingCount++;
    _ensureScheduled();
  }

  /// Schedules an effect function to run in the next batch.
  void scheduleEffect(void Function() fn) {
    _effects.add(fn);
    _ensureScheduled();
  }

  void _ensureScheduled() {
    final config = DripSchedulerConfig.instance;
    final shouldUsePostFrame = !config.disableFallback &&
        _pendingCount >= config.microtaskThreshold &&
        _postFrameScheduler != null;

    if (_usingPostFrame) {
      // Already committed to post-frame — nothing to do.
      return;
    }

    if (shouldUsePostFrame) {
      // Threshold crossed — register post-frame (upgrade or first schedule).
      _usingPostFrame = true;
      _scheduled = true;
      _postFrameScheduler!((Duration _) => _flush());
      return;
    }

    if (_scheduled) {
      // Already scheduled via microtask — no upgrade needed.
      return;
    }

    // First write, below threshold: use microtask.
    _scheduled = true;
    Future.microtask(_flush);
  }

  void _flush() {
    _scheduled = false;
    _usingPostFrame = false;
    _pendingCount = 0;

    final propagationsSnapshot = List<void Function()>.from(_propagations);
    _propagations.clear();
    for (final fn in propagationsSnapshot) {
      fn();
    }

    try {
      final effectsSnapshot = List<void Function()>.from(_effects);
      _effects.clear();
      for (final fn in effectsSnapshot) {
        try {
          fn();
        } catch (e, stackTrace) {
          if (DripTrace.isEnabled && DripTrace.current != null) {
            Error.throwWithStackTrace(
              e,
              StackTrace.fromString(
                '${stackTrace.toString()}\n'
                '--- DripBatch microtask gap ---\n'
                '${DripTrace.current.toString()}',
              ),
            );
          } else {
            rethrow;
          }
        }
      }
    } finally {
      if (DripTrace.isEnabled) {
        DripTrace.setCurrent(null);
      }
    }
  }

  /// Forces a synchronous flush of all pending propagations and effects.
  /// Used in tests to verify error handling without microtask timing issues.
  @visibleForTesting
  void debugFlush() => _flush();

  /// Resets internal state. Used in tests only.
  void reset() {
    _scheduled = false;
    _usingPostFrame = false;
    _pendingCount = 0;
    _propagations.clear();
    _effects.clear();
  }
}
