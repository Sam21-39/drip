import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drip_flutter/drip_flutter.dart';

class _TestNode extends DripNode {
  bool isDisposed = false;
  bool isBackground = false;
  bool isForeground = false;

  @override
  void dispose() {
    isDisposed = true;
    super.dispose();
  }

  @override
  void onBackground() {
    isBackground = true;
  }

  @override
  void onForeground() {
    isForeground = true;
  }
}

void main() {
  testWidgets('DripLifecycle manages node lifecycle', (tester) async {
    late _TestNode nodeRef;

    await tester.pumpWidget(
      DripLifecycle<_TestNode>(
        create: () => _TestNode(),
        builder: (node) {
          nodeRef = node;
          return const SizedBox();
        },
      ),
    );

    expect(nodeRef.isDisposed, false);

    // App goes to background
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    expect(nodeRef.isBackground, true);

    // App comes to foreground
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    expect(nodeRef.isForeground, true);

    // Unmount
    await tester.pumpWidget(const SizedBox());
    expect(nodeRef.isDisposed, true);
  });
}
