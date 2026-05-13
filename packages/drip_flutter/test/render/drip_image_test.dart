import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drip_core/drip_core.dart';
import 'package:drip_flutter/src/render/drip_image.dart';

void main() {
  // 1x1 transparent GIF bytes
  final transparentImage = Uint8List.fromList([
    0x47,
    0x49,
    0x46,
    0x38,
    0x39,
    0x61,
    0x01,
    0x00,
    0x01,
    0x00,
    0x80,
    0x00,
    0x00,
    0xff,
    0xff,
    0xff,
    0x00,
    0x00,
    0x00,
    0x21,
    0xf9,
    0x04,
    0x01,
    0x00,
    0x00,
    0x00,
    0x00,
    0x2c,
    0x00,
    0x00,
    0x00,
    0x00,
    0x01,
    0x00,
    0x01,
    0x00,
    0x00,
    0x02,
    0x02,
    0x44,
    0x01,
    0x00,
    0x3b
  ]);

  group('DripImage Widget Tests', () {
    testWidgets('I-1.1: Initial image renders and updates without rebuild',
        (tester) async {
      final img1 = MemoryImage(transparentImage);
      final img2 = MemoryImage(transparentImage);
      final state = dripState<ImageProvider>(img1);
      var buildCount = 0;

      await tester.pumpWidget(MaterialApp(
        home: Center(
          child: Builder(
            builder: (context) {
              buildCount++;
              return DripImage(
                state,
                width: 100,
                height: 100,
              );
            },
          ),
        ),
      ));

      expect(buildCount, 1);
      state.write(img2);
      await tester.pump();

      expect(buildCount, 1,
          reason: 'DripImage should update without rebuilding parent');
    });

    testWidgets('I-1.2: Properties update RenderObject correctly',
        (tester) async {
      final img = MemoryImage(transparentImage);
      final state = dripState<ImageProvider>(img);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Align(
            // Use Align to provide loose constraints
            alignment: Alignment.topLeft,
            child: DripImage(
              state,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ));

      final renderObject =
          tester.renderObject<DripImageRenderBox>(find.byType(DripImage));
      expect(renderObject.size.width, 100);
      expect(renderObject.size.height, 100);

      // Update widget properties
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: DripImage(
              state,
              width: 200,
              height: 200,
              fit: BoxFit.fill,
            ),
          ),
        ),
      ));

      expect(renderObject.size.width, 200);
      expect(renderObject.size.height, 200);
    });
  });
}
