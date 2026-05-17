import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drip_core/drip_core.dart';
import 'package:drip_flutter/drip_flutter.dart';

void main() {
  group('DripSelect.two', () {
    testWidgets('Initial combined value rendered', (WidgetTester tester) async {
      final state1 = dripState('Hello');
      final state2 = dripState('World');

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: DripSelect.two<String, String, String>(
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
          child: DripSelect.two<String, String, String>(
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
          child: DripSelect.two<String, String, String>(
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
          child: DripSelect.two<int, int, int>(
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

  group('DripSelect.three', () {
    testWidgets('Initial value rendered', (WidgetTester tester) async {
      final s1 = dripState(1);
      final s2 = dripState(2);
      final s3 = dripState(3);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: DripSelect.three<int, int, int, int>(
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

    testWidgets('Rebuilds, skips equal slices, and cleans listeners',
        (WidgetTester tester) async {
      final s1 = dripState(1);
      final s2 = dripState(2);
      final s3 = dripState(3);
      var buildCount = 0;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: DripSelect.three<int, int, int, int>(
            source1: s1,
            source2: s2,
            source3: s3,
            selector: (a, b, c) => a + b + c,
            builder: (context, value) {
              buildCount++;
              return Text(value.toString());
            },
          ),
        ),
      );

      expect(buildCount, 1);
      expect(s1.subscribers.length, 1);
      expect(s2.subscribers.length, 1);
      expect(s3.subscribers.length, 1);

      s1.write(2);
      await tester.pumpAndSettle();
      expect(find.text('7'), findsOneWidget);
      expect(buildCount, 2);

      s1.write(1);
      s2.write(3);
      await tester.pumpAndSettle();
      expect(buildCount, 2);

      await tester.pumpWidget(const SizedBox());
      expect(s1.subscribers.length, 0);
      expect(s2.subscribers.length, 0);
      expect(s3.subscribers.length, 0);
    });

    testWidgets('didUpdateWidget switches to new sources',
        (WidgetTester tester) async {
      final old1 = dripState(1);
      final old2 = dripState(2);
      final old3 = dripState(3);
      final new1 = dripState(10);
      final new2 = dripState(20);
      final new3 = dripState(30);

      Widget build(DripState<int> a, DripState<int> b, DripState<int> c) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: DripSelect.three<int, int, int, int>(
            source1: a,
            source2: b,
            source3: c,
            selector: (x, y, z) => x + y + z,
            builder: (context, value) => Text(value.toString()),
          ),
        );
      }

      await tester.pumpWidget(build(old1, old2, old3));
      await tester.pumpWidget(build(new1, new2, new3));

      expect(find.text('60'), findsOneWidget);
      expect(old1.subscribers.length, 0);
      expect(old2.subscribers.length, 0);
      expect(old3.subscribers.length, 0);
      expect(new1.subscribers.length, 1);
      expect(new2.subscribers.length, 1);
      expect(new3.subscribers.length, 1);
    });
  });

  group('DripSelect.four', () {
    testWidgets('Initial value, updates, equality skip, and cleanup',
        (WidgetTester tester) async {
      final s1 = dripState(1);
      final s2 = dripState(2);
      final s3 = dripState(3);
      final s4 = dripState(4);
      var buildCount = 0;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: DripSelect.four<int, int, int, int, int>(
            source1: s1,
            source2: s2,
            source3: s3,
            source4: s4,
            selector: (a, b, c, d) => a + b + c + d,
            builder: (context, value) {
              buildCount++;
              return Text(value.toString());
            },
          ),
        ),
      );

      expect(find.text('10'), findsOneWidget);
      expect(buildCount, 1);

      s4.write(5);
      await tester.pumpAndSettle();
      expect(find.text('11'), findsOneWidget);
      expect(buildCount, 2);

      s1.write(2);
      s2.write(1);
      await tester.pumpAndSettle();
      expect(buildCount, 2);

      await tester.pumpWidget(const SizedBox());
      expect(s1.subscribers.length, 0);
      expect(s2.subscribers.length, 0);
      expect(s3.subscribers.length, 0);
      expect(s4.subscribers.length, 0);
    });

    testWidgets('didUpdateWidget switches to new sources',
        (WidgetTester tester) async {
      final old1 = dripState(1);
      final old2 = dripState(2);
      final old3 = dripState(3);
      final old4 = dripState(4);
      final new1 = dripState(10);
      final new2 = dripState(20);
      final new3 = dripState(30);
      final new4 = dripState(40);

      Widget build(
        DripState<int> a,
        DripState<int> b,
        DripState<int> c,
        DripState<int> d,
      ) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: DripSelect.four<int, int, int, int, int>(
            source1: a,
            source2: b,
            source3: c,
            source4: d,
            selector: (w, x, y, z) => w + x + y + z,
            builder: (context, value) => Text(value.toString()),
          ),
        );
      }

      await tester.pumpWidget(build(old1, old2, old3, old4));
      await tester.pumpWidget(build(new1, new2, new3, new4));

      expect(find.text('100'), findsOneWidget);
      expect(old1.subscribers.length, 0);
      expect(old2.subscribers.length, 0);
      expect(old3.subscribers.length, 0);
      expect(old4.subscribers.length, 0);
      expect(new1.subscribers.length, 1);
      expect(new2.subscribers.length, 1);
      expect(new3.subscribers.length, 1);
      expect(new4.subscribers.length, 1);
    });
  });
}
