import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drip_flutter/drip_flutter.dart';

void main() {
  group('DripFrame & DripFrameBuilder Tests', () {
    testWidgets('F-1.1: DripFrameBuilder renders initial frame.value',
        (tester) async {
      final frame = DripFrame<String>('Initial');

      await tester.pumpWidget(MaterialApp(
        home: DripFrameBuilder<String>(
          frame: frame,
          builder: (context, value) =>
              Text(value, textDirection: TextDirection.ltr),
        ),
      ));

      expect(find.text('Initial'), findsOneWidget);
    });

    testWidgets('F-1.2: frame.update() triggers setState and rebuild',
        (tester) async {
      final frame = DripFrame<int>(0);
      var buildCount = 0;

      await tester.pumpWidget(MaterialApp(
        home: DripFrameBuilder<int>(
          frame: frame,
          builder: (context, value) {
            buildCount++;
            return Text('Value: $value', textDirection: TextDirection.ltr);
          },
        ),
      ));

      expect(buildCount, 1);
      expect(find.text('Value: 0'), findsOneWidget);

      frame.update(1);
      await tester.pump();

      expect(buildCount, 2);
      expect(find.text('Value: 1'), findsOneWidget);
    });

    testWidgets('F-1.3: frame.update() with same value is no-op',
        (tester) async {
      final frame = DripFrame<int>(10);
      var buildCount = 0;

      await tester.pumpWidget(MaterialApp(
        home: DripFrameBuilder<int>(
          frame: frame,
          builder: (context, value) {
            buildCount++;
            return Text('Value: $value', textDirection: TextDirection.ltr);
          },
        ),
      ));

      expect(buildCount, 1);

      frame.update(10); // Same value
      await tester.pump();

      expect(buildCount, 1,
          reason: 'Builder should not be called if value has not changed');
    });

    testWidgets('F-1.4: Listener deregistered on widget dispose',
        (tester) async {
      final frame = DripFrame<int>(0);

      await tester.pumpWidget(MaterialApp(
        home: DripFrameBuilder<int>(
          frame: frame,
          builder: (context, value) => Text('$value'),
        ),
      ));

      expect(frame.listenerCount, 1);

      // Remove the widget
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));

      expect(frame.listenerCount, 0);
    });

    testWidgets(
        'F-1.5: DripFrameBuilder with new frame instance updates correctly',
        (tester) async {
      final frame1 = DripFrame<int>(1);
      final frame2 = DripFrame<int>(2);

      await tester.pumpWidget(MaterialApp(
        home: DripFrameBuilder<int>(
          frame: frame1,
          builder: (context, value) =>
              Text('Val: $value', textDirection: TextDirection.ltr),
        ),
      ));

      expect(find.text('Val: 1'), findsOneWidget);
      expect(frame1.listenerCount, 1);
      expect(frame2.listenerCount, 0);

      // Swap frame
      await tester.pumpWidget(MaterialApp(
        home: DripFrameBuilder<int>(
          frame: frame2,
          builder: (context, value) =>
              Text('Val: $value', textDirection: TextDirection.ltr),
        ),
      ));

      expect(find.text('Val: 2'), findsOneWidget);
      expect(frame1.listenerCount, 0);
      expect(frame2.listenerCount, 1);
    });
  });
}
