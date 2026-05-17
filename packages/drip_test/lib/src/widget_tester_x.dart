import 'package:flutter_test/flutter_test.dart';

extension DripWidgetTesterX on WidgetTester {
  /// Flushes DRIP microtask propagation and then processes the next frame.
  ///
  /// This encodes the two-pump contract used by DRIP widget tests:
  /// 1) flush reactive microtasks, 2) build/layout/paint updated widgets.
  Future<void> pumpDrip([Duration? duration]) async {
    await pump(duration);
    await pump();
  }
}
