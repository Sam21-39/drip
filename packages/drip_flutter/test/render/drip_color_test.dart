import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drip_core/drip_core.dart';
import 'package:drip_flutter/src/render/drip_color.dart';

void main() {
  group('DripColor Widget Tests', () {
    testWidgets('C-1.1: Initial color applied correctly', (tester) async {
      final color = dripState<Color>(Colors.red);
      await tester.pumpWidget(MaterialApp(
        home: Center(
          child: SizedBox(
            width: 100,
            height: 100,
            child: DripColor(color: color),
          ),
        ),
      ));

      final renderObject =
          tester.renderObject<DripColorRenderBox>(find.byType(DripColor));
      expect(renderObject.color, Colors.red);
    });

    testWidgets('C-1.2: Color update without widget rebuild', (tester) async {
      final color = dripState<Color>(Colors.blue);
      var buildCount = 0;

      await tester.pumpWidget(MaterialApp(
        home: Center(
          child: Builder(
            builder: (context) {
              buildCount++;
              return DripColor(color: color);
            },
          ),
        ),
      ));

      expect(buildCount, 1);

      color.write(Colors.green);
      await tester.pump();

      expect(buildCount, 1,
          reason: 'DripColor should update without rebuilding parent');
      final renderObject =
          tester.renderObject<DripColorRenderBox>(find.byType(DripColor));
      expect(renderObject.color, Colors.green);
    });

    testWidgets('C-1.4: Binding deregistered on unmount', (tester) async {
      final color = dripState<Color>(Colors.amber);
      await tester.pumpWidget(MaterialApp(
        home: DripColor(color: color),
      ));

      await tester.pumpWidget(const MaterialApp(home: SizedBox()));

      color.write(Colors.black);
      await tester.pump();
      // No crash = success
    });
  });
}
