import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drip_core/drip_core.dart';
import 'package:drip_flutter/drip_flutter.dart';

void main() {
  group('DripSelect2', () {
    testWidgets('Initial combined value rendered', (WidgetTester tester) async {
      final state1 = dripState('Hello');
      final state2 = dripState('World');

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: DripSelect2<String, String, String>(
            source1: state1,
            source2: state2,
            selector: (a, b) => '$a $b',
            builder: (context, value) => Text(value),
          ),
        ),
      );

      expect(find.text('Hello World'), findsOneWidget);
    });

    testWidgets('Rebuilds when either source changes',
        (WidgetTester tester) async {
      final state1 = dripState('Hello');
      final state2 = dripState('World');
      int buildCount = 0;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: DripSelect2<String, String, String>(
            source1: state1,
            source2: state2,
            selector: (a, b) => '$a $b',
            builder: (context, value) {
              buildCount++;
              return Text(value);
            },
          ),
        ),
      );

      expect(buildCount, 1);

      state1.write('Hi');
      await tester.pumpAndSettle();
      expect(find.text('Hi World'), findsOneWidget);
      expect(buildCount, 2);

      state2.write('Flutter');
      await tester.pumpAndSettle();
      expect(find.text('Hi Flutter'), findsOneWidget);
      expect(buildCount, 3);
    });

    testWidgets('Coalesces multiple source updates into one rebuild',
        (WidgetTester tester) async {
      final state1 = dripState('A');
      final state2 = dripState('B');
      int buildCount = 0;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: DripSelect2<String, String, String>(
            source1: state1,
            source2: state2,
            selector: (a, b) => '$a$b',
            builder: (context, value) {
              buildCount++;
              return Text(value);
            },
          ),
        ),
      );

      expect(buildCount, 1);

      // Mutate both sequentially; internal microtask batching should coalesce
      state1.write('C');
      state2.write('D');

      await tester.pumpAndSettle();

      expect(find.text('CD'), findsOneWidget);
      expect(buildCount, 2); // Exactly one rebuild for both changes
    });

    testWidgets('Equality skip works', (WidgetTester tester) async {
      final state1 = dripState(10);
      final state2 = dripState(20);
      int buildCount = 0;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: DripSelect2<int, int, int>(
            source1: state1,
            source2: state2,
            selector: (a, b) => a + b,
            builder: (context, value) {
              buildCount++;
              return Text(value.toString());
            },
          ),
        ),
      );

      expect(buildCount, 1);

      // Mutate sources such that sum is same
      state1.write(15);
      state2.write(15);
      await tester.pumpAndSettle();

      expect(buildCount, 1); // No rebuild because 15+15 == 10+20
    });
  });

  group('DripSelect3', () {
    testWidgets('Initial value rendered', (WidgetTester tester) async {
      final s1 = dripState(1);
      final s2 = dripState(2);
      final s3 = dripState(3);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: DripSelect3<int, int, int, int>(
            source1: s1,
            source2: s2,
            source3: s3,
            selector: (a, b, c) => a + b + c,
            builder: (context, value) => Text(value.toString()),
          ),
        ),
      );

      expect(find.text('6'), findsOneWidget);
    });
  });
}
