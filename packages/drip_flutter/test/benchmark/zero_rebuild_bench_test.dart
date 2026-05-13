@Tags(['benchmark'])
library;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drip_core/drip_core.dart';
import 'package:drip_flutter/drip_flutter.dart';

Finder findDripText(String text) {
  return find.byElementPredicate((element) {
    if (element.widget is DripText && element.renderObject is RenderParagraph) {
      final rp = element.renderObject as RenderParagraph;
      return rp.text.toPlainText() == text;
    }
    return false;
  });
}

void main() {
  group('Zero Rebuild Benchmark', () {
    testWidgets('ZR-1: 1000 DripText updates — exactly zero widget rebuilds',
        (tester) async {
      // Setup
      final states = List.generate(1000, (i) => dripState('Cell $i'));
      var buildCount = 0;

      await tester.pumpWidget(MaterialApp(
        home: Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) {
              buildCount++;
              return SingleChildScrollView(
                child: Column(
                  children: states.map((s) => DripText(s)).toList(),
                ),
              );
            },
          ),
        ),
      ));

      // Record buildCount after initial pump
      final initialBuildCount = buildCount;
      expect(initialBuildCount, greaterThan(0));

      // Action: Write a new value to every one of the 1000 states
      final stopwatch = Stopwatch()..start();
      for (var i = 0; i < 1000; i++) {
        states[i].write('New Value $i');
      }

      // Coalesce and flush updates to render objects
      await tester.pump();
      stopwatch.stop();

      // Assert
      expect(buildCount, initialBuildCount,
          reason:
              'DRIP-FL-11: Rebuild count must NOT increase after state writes');

      // Verify values updated (check a sample to save test time, or all if feasible)
      for (var i = 0; i < 1000; i += 100) {
        expect(findDripText('New Value $i'), findsOneWidget);
      }

      debugPrint(
          'ZR-2: 1000 writes + pump duration: ${stopwatch.elapsedMilliseconds}ms');
    });

    testWidgets(
        'ZR-3: Mount 1000 DripText, unmount all, verify no subscriber leaks',
        (tester) async {
      final states = List.generate(1000, (i) => dripState('S $i'));

      await tester.pumpWidget(MaterialApp(
        home: Directionality(
          textDirection: TextDirection.ltr,
          child: ListView(
            children: states.map((s) => DripText(s)).toList(),
          ),
        ),
      ));

      // Unmount all
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));

      // Since we can't access private _subscribers directly, we check for errors
      // when writing to the now "dead" states.
      for (var i = 0; i < 1000; i++) {
        states[i].write('Dead $i');
      }
      await tester.pump();

      // Success is no crash/assertion failure.
    });

    testWidgets('ZR-4: 100 rapid sequential writes to single DripText',
        (tester) async {
      final state = dripState('Init');
      var buildCount = 0;

      await tester.pumpWidget(MaterialApp(
        home: Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) {
              buildCount++;
              return DripText(state);
            },
          ),
        ),
      ));

      for (var i = 0; i < 100; i++) {
        state.write('Update $i');
      }

      await tester.pump();

      expect(buildCount, 1);
      expect(findDripText('Update 99'), findsOneWidget);
    });
  });
}
