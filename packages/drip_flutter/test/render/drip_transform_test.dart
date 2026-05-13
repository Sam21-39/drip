import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drip_core/drip_core.dart';
import 'package:drip_flutter/src/render/drip_transform.dart';

void main() {
  group('DripTransform Widget Tests', () {
    testWidgets('TR-1.1: Identity matrix applied as initial state',
        (tester) async {
      final transform = dripState(Matrix4.identity());
      await tester.pumpWidget(MaterialApp(
        home: Center(
          child: DripTransform(
            transform: transform,
            child: const SizedBox(width: 10, height: 10),
          ),
        ),
      ));

      final renderObject = tester
          .renderObject<DripTransformRenderBox>(find.byType(DripTransform));
      expect(renderObject.transform, Matrix4.identity());
    });

    testWidgets('TR-1.2: Translation matrix update without rebuild',
        (tester) async {
      final transform = dripState(Matrix4.identity());
      var buildCount = 0;

      await tester.pumpWidget(MaterialApp(
        home: Center(
          child: Builder(
            builder: (context) {
              buildCount++;
              return DripTransform(
                transform: transform,
                child: const SizedBox(width: 10, height: 10),
              );
            },
          ),
        ),
      ));

      expect(buildCount, 1);

      final newTransform = Matrix4.translationValues(10, 20, 0);
      transform.write(newTransform);
      await tester.pump();

      expect(buildCount, 1,
          reason: 'DripTransform should update without rebuilding parent');
      final renderObject = tester
          .renderObject<DripTransformRenderBox>(find.byType(DripTransform));
      expect(renderObject.transform, newTransform);
    });

    testWidgets('TR-1.3: Binding deregistered on unmount', (tester) async {
      final transform = dripState(Matrix4.identity());
      await tester.pumpWidget(MaterialApp(
        home: DripTransform(transform: transform),
      ));

      await tester.pumpWidget(const MaterialApp(home: SizedBox()));

      transform.write(Matrix4.rotationZ(1.0));
      await tester.pump();
      // No crash = success
    });
  });
}
