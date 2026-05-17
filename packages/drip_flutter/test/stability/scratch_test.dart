import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drip_core/drip_core.dart';
import 'package:drip_flutter/drip_flutter.dart';
import 'package:drip_flutter/src/render/drip_text.dart';

class _CountingState<T> extends DripState<T> {
  int listenerAddCount = 0;

  _CountingState(super.initial);

  @override
  void addListener(VoidCallback listener) {
    listenerAddCount++;
    print("addListener called, total: $listenerAddCount");
    super.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    print("removeListener called");
    super.removeListener(listener);
  }
}

// Subclass to add logging
class LogDripText extends DripText {
  LogDripText(super.state);

  @override
  DripRenderParagraph createRenderObject(BuildContext context) {
    print("LogDripText.createRenderObject called");
    return super.createRenderObject(context);
  }
}

void main() {
  testWidgets('scratch test', (tester) async {
    final state = _CountingState('initial');
    final visible = dripState(true);

    print("--- pump 1 ---");
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: DripBuilder<bool>(
          source: visible,
          builder: (context, show) =>
              show ? LogDripText(state) : const SizedBox(),
        ),
      ),
    );

    print("--- pump 2 ---");
    visible.write(false);
    await tester.pump(); // drain DripBatch microtask before replacing the tree
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: DripBuilder<bool>(
          source: visible,
          builder: (context, show) =>
              show ? LogDripText(state) : const SizedBox(),
        ),
      ),
    );
    await tester.pump();

    print("--- pump 3 ---");
    visible.write(true);
    await tester.pump(); // drains microtask → _onChanged → setState
    await tester.pump(); // rebuilds DripBuilder → DripText remounts
    print("--- done ---");
  });
}
