import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drip_core/drip_core.dart';
import 'package:drip_flutter/drip_flutter.dart';

void main() {
  testWidgets('DripSemantics updates label with debounce', (tester) async {
    final state = dripState(0);
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: DripSemantics(
          value: state,
          label: (v) => 'Count: $v',
          updateInterval: const Duration(milliseconds: 16),
          child: const SizedBox(),
        ),
      ),
    );

    // Initial value
    expect(
      tester.getSemantics(find.byType(SizedBox)),
      matchesSemantics(label: 'Count: 0'),
    );

    // Update state
    state.write(1);

    // Wait for DripBatch
    await tester.pump();

    // Timer hasn't fired yet
    expect(
      tester.getSemantics(find.byType(SizedBox)),
      matchesSemantics(label: 'Count: 0'),
    );

    // Wait for debounce timer (16ms)
    await tester.pump(const Duration(milliseconds: 20));

    // Now it should be updated
    expect(
      tester.getSemantics(find.byType(SizedBox)),
      matchesSemantics(label: 'Count: 1'),
    );
  });
}
