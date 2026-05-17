import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drip_core/drip_core.dart';
import 'package:drip_flutter/drip_flutter.dart';
import 'package:drip_flutter/src/render/drip_text.dart';
import 'package:drip_flutter/src/render/drip_color.dart';
import 'package:drip_flutter/src/render/drip_opacity.dart';

// ---------------------------------------------------------------------------
// Test-only DripState subclass that counts listener registrations.
// ---------------------------------------------------------------------------
class _CountingState<T> extends DripState<T> {
  int listenerAddCount = 0;

  _CountingState(super.initial);

  @override
  void addListener(VoidCallback listener) {
    listenerAddCount++;
    super.addListener(listener);
  }
}

// ---------------------------------------------------------------------------
// Helper: read text from the DripRenderParagraph backing a DripText widget.
// find.text() only matches Text/EditableText — not LeafRenderObjectWidget.
// ---------------------------------------------------------------------------
String _dripTextValue(WidgetTester tester) {
  final ro = tester.renderObject<DripRenderParagraph>(find.byType(DripText));
  return ro.text.toPlainText();
}

void main() {
  group('DripBinding — Callback Identity (Risk 4)', () {
    testWidgets(
        'CI-1.1: 100 parent rebuilds produce zero additional subscription starts',
        (tester) async {
      final state = _CountingState('initial');
      final parentCounter = dripState(0);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: DripBuilder<int>(
            source: parentCounter,
            builder: (context, _) => DripText(state),
          ),
        ),
      );

      // Initial attach: exactly 1 subscription expected.
      expect(state.listenerAddCount, 1,
          reason: 'Binding must register once on initial attach');

      // Trigger 100 parent rebuilds.
      for (var i = 0; i < 100; i++) {
        parentCounter.write(i + 1);
        await tester.pump();
      }

      // Listener count must still be 1 — no additional subscriptions.
      expect(state.listenerAddCount, 1,
          reason:
              'DripBinding must not re-register on parent rebuilds (Risk 4)');
    });

    testWidgets(
        'CI-1.2: Unmounting and remounting re-creates subscription exactly once',
        (tester) async {
      final state = _CountingState('initial');
      final visible = dripState(true);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: DripBuilder<bool>(
            source: visible,
            builder: (context, show) =>
                show ? DripText(state) : const SizedBox(),
          ),
        ),
      );

      expect(state.listenerAddCount, 1,
          reason: 'Binding must register once on mount');

      // Unmount DripText.
      visible.write(false);
      // Drain the DripBatch microtask so write(false) is fully propagated
      // (_currentValue = false) before the tree is replaced. Without this,
      // write(true) in pump 3 coalesces with the still-pending propagation,
      // delivering only value=true and suppressing the DripBuilder rebuild.
      await tester.pump();
      // pumpWidget replaces the tree, guaranteeing RenderObject.dispose() fires.
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: DripBuilder<bool>(
            source: visible,
            builder: (context, show) =>
                show ? DripText(state) : const SizedBox(),
          ),
        ),
      );
      await tester.pump();

      expect(state.subscribers.isEmpty, isTrue,
          reason: 'No subscribers must remain after unmount');

      // Remount — binding must re-register exactly once.
      visible.write(true);
      // Two pumps are required here because DripBatch uses Future.microtask,
      // which drains AFTER the build phase in flutter_test's FakeAsync:
      //   pump 1: frame runs (DripBuilder not yet dirty) → post-frame microtask
      //           drains → _onChanged fires → setState marks DripBuilder dirty
      //   pump 2: frame runs → DripBuilder rebuilt → DripText remounted →
      //           RO.attach() → _createBinding() → addListener (count = 2)
      await tester.pump();
      await tester.pump();

      expect(state.listenerAddCount, 2,
          reason: 'Re-mount should create exactly one new subscription');
    });
  });

  group('RenderObject Resync — Hot Reload & Rebuild (Risk 1)', () {
    testWidgets('RS-1.1: DripText retains DRIP value after parent rebuild',
        (tester) async {
      final text = dripState('drip-value');
      final counter = dripState(0);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: DripBuilder<int>(
            source: counter,
            builder: (_, __) => DripText(text),
          ),
        ),
      );

      expect(_dripTextValue(tester), 'drip-value');

      // Write a new value then force parent rebuild.
      text.write('updated');
      await tester.pump();
      counter.write(1);
      await tester.pump();

      expect(_dripTextValue(tester), 'updated',
          reason: 'DRIP value must survive parent rebuild');
    });

    testWidgets('RS-1.2: DripColor retains DRIP value after parent rebuild',
        (tester) async {
      final colorState = dripState(const Color(0xFFFF0000));
      final counter = dripState(0);

      await tester.pumpWidget(
        DripBuilder<int>(
          source: counter,
          builder: (_, __) => DripColor(
            color: colorState,
            child: const SizedBox(width: 100, height: 100),
          ),
        ),
      );

      colorState.write(const Color(0xFF00FF00));
      await tester.pump();

      final ro =
          tester.renderObject<DripColorRenderBox>(find.byType(DripColor));
      expect(ro.color, const Color(0xFF00FF00));

      counter.write(1);
      await tester.pump();

      expect(ro.color, const Color(0xFF00FF00),
          reason: 'DripColor must retain DRIP value after parent rebuild');
    });

    testWidgets('RS-1.3: DripOpacity retains DRIP value after parent rebuild',
        (tester) async {
      final opacityState = dripState(0.5);
      final counter = dripState(0);

      await tester.pumpWidget(
        DripBuilder<int>(
          source: counter,
          builder: (_, __) => DripOpacity(
            opacity: opacityState,
            child: const SizedBox(width: 100, height: 100),
          ),
        ),
      );

      opacityState.write(0.8);
      await tester.pump();

      final ro =
          tester.renderObject<DripOpacityRenderBox>(find.byType(DripOpacity));
      expect(ro.opacity, closeTo(0.8, 0.001));

      counter.write(1);
      await tester.pump();

      expect(ro.opacity, closeTo(0.8, 0.001),
          reason: 'DripOpacity must retain DRIP value after parent rebuild');
    });

    testWidgets('RS-1.4: DripText reassemble() re-asserts DRIP value',
        (tester) async {
      final text = dripState('before-reload');

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: DripText(text),
        ),
      );

      text.write('after-reload');
      await tester.pump();

      expect(_dripTextValue(tester), 'after-reload');

      tester.binding.reassembleApplication();
      await tester.pump();

      expect(_dripTextValue(tester), 'after-reload',
          reason:
              'DripText must retain DRIP value after reassemble (hot reload)');
    });

    testWidgets('RS-1.5: DripColor reassemble() re-asserts DRIP value',
        (tester) async {
      final colorState = dripState(const Color(0xFFFF0000));

      await tester.pumpWidget(
        DripColor(
          color: colorState,
          child: const SizedBox(width: 50, height: 50),
        ),
      );

      colorState.write(const Color(0xFF0000FF));
      await tester.pump();

      tester.binding.reassembleApplication();
      await tester.pump();

      final ro =
          tester.renderObject<DripColorRenderBox>(find.byType(DripColor));
      expect(ro.color, const Color(0xFF0000FF),
          reason: 'DripColor must retain DRIP value after reassemble');
    });
  });
}
