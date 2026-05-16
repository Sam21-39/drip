import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drip_core/drip_core.dart';
import 'package:drip_flutter/drip_flutter.dart';

// ---------------------------------------------------------------------------
// Helper: read DripText render object text
// ---------------------------------------------------------------------------
String _dripTextValue(WidgetTester tester) {
  final ro = tester.renderObject<DripRenderParagraph>(find.byType(DripText));
  return ro.text.toPlainText();
}

void main() {
  group('RenderObject Resync — Hot Reload & Full Rebuild (Risk 1)', () {
    // ── DripText ──────────────────────────────────────────────────────────

    testWidgets('HR-1.1: DripText — correct value on initial render',
        (tester) async {
      final text = dripState('hello');
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: DripText(text),
      ));
      expect(_dripTextValue(tester), 'hello');
    });

    testWidgets('HR-1.2: DripText — correct value after state write',
        (tester) async {
      final text = dripState('hello');
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: DripText(text),
      ));
      text.write('world');
      await tester.pump();
      expect(_dripTextValue(tester), 'world');
    });

    testWidgets('HR-1.3: DripText — retains DRIP value after forced rebuild',
        (tester) async {
      final text = dripState('drip');
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

      text.write('drip-updated');
      await tester.pump();

      // Force a parent rebuild that triggers updateRenderObject.
      counter.write(1);
      await tester.pump();

      expect(_dripTextValue(tester), 'drip-updated',
          reason: 'DripText must show DRIP value, not widget tree default');
    });

    testWidgets(
        'HR-1.4: DripText — retains value after reassemble (hot reload)',
        (tester) async {
      final text = dripState('before-hot-reload');
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: DripText(text),
      ));

      text.write('after-hot-reload');
      await tester.pump();

      tester.binding.reassembleApplication();
      await tester.pump();

      expect(_dripTextValue(tester), 'after-hot-reload');
    });

    // ── DripColor ─────────────────────────────────────────────────────────

    testWidgets('HR-2.1: DripColor — correct color on initial render',
        (tester) async {
      final color = dripState(const Color(0xFFFF0000));
      await tester.pumpWidget(DripColor(
        color: color,
        child: const SizedBox(width: 50, height: 50),
      ));
      final ro =
          tester.renderObject<DripColorRenderBox>(find.byType(DripColor));
      expect(ro.color, const Color(0xFFFF0000));
    });

    testWidgets('HR-2.2: DripColor — correct color after state write',
        (tester) async {
      final color = dripState(const Color(0xFFFF0000));
      await tester.pumpWidget(DripColor(
        color: color,
        child: const SizedBox(width: 50, height: 50),
      ));
      color.write(const Color(0xFF00FF00));
      await tester.pump();
      final ro =
          tester.renderObject<DripColorRenderBox>(find.byType(DripColor));
      expect(ro.color, const Color(0xFF00FF00));
    });

    testWidgets('HR-2.3: DripColor — retains value after forced rebuild',
        (tester) async {
      final color = dripState(const Color(0xFFFF0000));
      final counter = dripState(0);
      await tester.pumpWidget(
        DripBuilder<int>(
          source: counter,
          builder: (_, __) => DripColor(
            color: color,
            child: const SizedBox(width: 50, height: 50),
          ),
        ),
      );
      color.write(const Color(0xFF0000FF));
      await tester.pump();
      counter.write(1);
      await tester.pump();
      final ro =
          tester.renderObject<DripColorRenderBox>(find.byType(DripColor));
      expect(ro.color, const Color(0xFF0000FF));
    });

    testWidgets(
        'HR-2.4: DripColor — retains value after reassemble (hot reload)',
        (tester) async {
      final color = dripState(const Color(0xFFFF0000));
      await tester.pumpWidget(DripColor(
        color: color,
        child: const SizedBox(width: 50, height: 50),
      ));
      color.write(const Color(0xFF123456));
      await tester.pump();
      tester.binding.reassembleApplication();
      await tester.pump();
      final ro =
          tester.renderObject<DripColorRenderBox>(find.byType(DripColor));
      expect(ro.color, const Color(0xFF123456));
    });

    // ── DripOpacity ───────────────────────────────────────────────────────

    testWidgets('HR-3.1: DripOpacity — correct value on initial render',
        (tester) async {
      final opacity = dripState(0.5);
      await tester.pumpWidget(DripOpacity(
        opacity: opacity,
        child: const SizedBox(width: 50, height: 50),
      ));
      final ro =
          tester.renderObject<DripOpacityRenderBox>(find.byType(DripOpacity));
      expect(ro.opacity, closeTo(0.5, 0.001));
    });

    testWidgets('HR-3.2: DripOpacity — retains value after forced rebuild',
        (tester) async {
      final opacity = dripState(0.5);
      final counter = dripState(0);
      await tester.pumpWidget(
        DripBuilder<int>(
          source: counter,
          builder: (_, __) => DripOpacity(
            opacity: opacity,
            child: const SizedBox(width: 50, height: 50),
          ),
        ),
      );
      opacity.write(0.9);
      await tester.pump();
      counter.write(1);
      await tester.pump();
      final ro =
          tester.renderObject<DripOpacityRenderBox>(find.byType(DripOpacity));
      expect(ro.opacity, closeTo(0.9, 0.001));
    });

    testWidgets(
        'HR-3.3: DripOpacity — retains value after reassemble (hot reload)',
        (tester) async {
      final opacity = dripState(0.3);
      await tester.pumpWidget(DripOpacity(
        opacity: opacity,
        child: const SizedBox(width: 50, height: 50),
      ));
      opacity.write(0.7);
      await tester.pump();
      tester.binding.reassembleApplication();
      await tester.pump();
      final ro =
          tester.renderObject<DripOpacityRenderBox>(find.byType(DripOpacity));
      expect(ro.opacity, closeTo(0.7, 0.001));
    });

    // ── DripTransform ─────────────────────────────────────────────────────

    testWidgets('HR-4.1: DripTransform — correct value on initial render',
        (tester) async {
      final transform = dripState(Matrix4.identity());
      await tester.pumpWidget(DripTransform(
        transform: transform,
        child: const SizedBox(width: 50, height: 50),
      ));
      final ro = tester
          .renderObject<DripTransformRenderBox>(find.byType(DripTransform));
      expect(ro.transform, Matrix4.identity());
    });

    testWidgets('HR-4.2: DripTransform — retains value after forced rebuild',
        (tester) async {
      final transform = dripState(Matrix4.identity());
      final counter = dripState(0);
      final scaled = Matrix4.diagonal3Values(2, 2, 1);

      await tester.pumpWidget(
        DripBuilder<int>(
          source: counter,
          builder: (_, __) => DripTransform(
            transform: transform,
            child: const SizedBox(width: 50, height: 50),
          ),
        ),
      );
      transform.write(scaled);
      await tester.pump();
      counter.write(1);
      await tester.pump();
      final ro = tester
          .renderObject<DripTransformRenderBox>(find.byType(DripTransform));
      expect(ro.transform, scaled);
    });

    testWidgets(
        'HR-4.3: DripTransform — retains value after reassemble (hot reload)',
        (tester) async {
      final transform = dripState(Matrix4.identity());
      final translated = Matrix4.translationValues(10, 20, 0);

      await tester.pumpWidget(DripTransform(
        transform: transform,
        child: const SizedBox(width: 50, height: 50),
      ));
      transform.write(translated);
      await tester.pump();
      tester.binding.reassembleApplication();
      await tester.pump();
      final ro = tester
          .renderObject<DripTransformRenderBox>(find.byType(DripTransform));
      expect(ro.transform, translated);
    });
  });
}
