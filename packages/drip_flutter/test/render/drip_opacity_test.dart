import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drip_core/drip_core.dart';
import 'package:drip_flutter/src/render/drip_opacity.dart';

void main() {
  group('DripOpacity Widget Tests', () {
    testWidgets('O-1.1: Initial opacity applied correctly', (tester) async {
      final opacity = dripState(0.5);
      await tester.pumpWidget(MaterialApp(
        home: Center(
          child: DripOpacity(
            opacity: opacity,
            child: const SizedBox(width: 10, height: 10),
          ),
        ),
      ));

      final renderObject =
          tester.renderObject<DripOpacityRenderBox>(find.byType(DripOpacity));
      expect(renderObject.opacity, 0.5);
    });

    testWidgets('O-1.2: Opacity update without widget rebuild', (tester) async {
      final opacity = dripState(1.0);
      var buildCount = 0;

      await tester.pumpWidget(MaterialApp(
        home: Center(
          child: Builder(
            builder: (context) {
              buildCount++;
              return DripOpacity(
                opacity: opacity,
                child: const SizedBox(width: 10, height: 10),
              );
            },
          ),
        ),
      ));

      expect(buildCount, 1);

      opacity.write(0.2);
      await tester.pump();

      expect(buildCount, 1,
          reason: 'DripOpacity should update without rebuilding parent');
      final renderObject =
          tester.renderObject<DripOpacityRenderBox>(find.byType(DripOpacity));
      expect(renderObject.opacity, 0.2);
    });

    testWidgets('O-1.3: Value below 0.0 clamped to 0.0', (tester) async {
      final opacity = dripState(0.5);
      await tester.pumpWidget(MaterialApp(
        home: Center(
          child: DripOpacity(opacity: opacity),
        ),
      ));

      opacity.write(-0.5);
      await tester.pump();

      final renderObject =
          tester.renderObject<DripOpacityRenderBox>(find.byType(DripOpacity));
      expect(renderObject.opacity, 0.0);
    });

    testWidgets('O-1.4: Value above 1.0 clamped to 1.0', (tester) async {
      final opacity = dripState(0.5);
      await tester.pumpWidget(MaterialApp(
        home: Center(
          child: DripOpacity(opacity: opacity),
        ),
      ));

      opacity.write(1.5);
      await tester.pump();

      final renderObject =
          tester.renderObject<DripOpacityRenderBox>(find.byType(DripOpacity));
      expect(renderObject.opacity, 1.0);
    });

    testWidgets('O-1.5: Binding deregistered on unmount', (tester) async {
      final opacity = dripState(0.8);
      await tester.pumpWidget(MaterialApp(
        home: DripOpacity(opacity: opacity),
      ));

      await tester.pumpWidget(const MaterialApp(home: SizedBox()));

      opacity.write(0.1);
      await tester.pump();
      // No crash = success
    });
  });
}
