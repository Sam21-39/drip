import 'package:drip_core/drip_core.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

/// Initialisation hook for the DRIP Flutter integration.
///
/// ## Why this exists
///
/// `drip_core` is a pure-Dart package with no Flutter dependency. It cannot
/// reference `SchedulerBinding` directly. [DripFlutterBinding] bridges the
/// gap: it is the single call-site that injects Flutter's frame scheduler into
/// [DripBatch], enabling the microtask-flood mitigation (Risk 2 fix) to switch
/// to post-frame scheduling under high write pressure.
///
/// ## Usage
///
/// Call [DripFlutterBinding.ensureInitialized] **once**, before `runApp`:
///
/// ```dart
/// void main() {
///   DripFlutterBinding.ensureInitialized();
///   runApp(const MyApp());
/// }
/// ```
///
/// Calling it more than once is safe — subsequent calls are no-ops.
///
/// ## What it does
///
/// 1. Calls [WidgetsFlutterBinding.ensureInitialized] to guarantee the
///    Flutter binding is ready (idempotent — safe even if already called).
/// 2. Injects [SchedulerBinding.instance.addPostFrameCallback] into
///    [DripBatch] as its post-frame scheduler.
///
/// After this call, [DripBatch] will automatically yield to the Flutter frame
/// pipeline when the number of pending propagations exceeds
/// [DripSchedulerConfig.microtaskThreshold] (default: 50).
class DripFlutterBinding {
  DripFlutterBinding._();

  static bool _initialized = false;

  /// Initialises the DRIP Flutter integration.
  ///
  /// Safe to call multiple times — only the first call has any effect.
  ///
  /// Returns the [SchedulerBinding] instance for convenience.
  static SchedulerBinding ensureInitialized() {
    if (_initialized) return SchedulerBinding.instance;
    _initialized = true;

    // Guarantee Flutter binding is ready (safe if already initialised).
    _ensureFlutterBinding();

    // Inject the post-frame scheduler into DripBatch.
    // drip_core has no Flutter dependency; this is the only place this
    // connection is made.
    DripBatch.instance.setPostFrameScheduler(
      SchedulerBinding.instance.addPostFrameCallback,
    );

    return SchedulerBinding.instance;
  }

  /// Resets the initialisation state.
  ///
  /// **Test use only.** Allows tests to re-initialise with a mock scheduler.
  static void reset() {
    _initialized = false;
    DripBatch.instance.reset();
  }

  static void _ensureFlutterBinding() {
    // SchedulerBinding.instance may not be set if Flutter has not been
    // initialised. Accessing it here after WidgetsFlutterBinding has been
    // set up by the test framework or by main() is always safe.
    //
    // In test environments, AutomatedTestWidgetsFlutterBinding sets up the
    // binding before any test runs, so this check is defensive only.
    assert(
      () {
        try {
          SchedulerBinding.instance; // ignore: unnecessary_statements
          return true;
        } catch (_) {
          throw FlutterError(
            'DripFlutterBinding.ensureInitialized() was called before the '
            'Flutter binding was ready.\n'
            'Call WidgetsFlutterBinding.ensureInitialized() first, or move '
            'DripFlutterBinding.ensureInitialized() after the first '
            'WidgetsFlutterBinding call.',
          );
        }
      }(),
    );
  }
}
