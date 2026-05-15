import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drip_core/drip_core.dart';
import 'package:drip_flutter/drip_flutter.dart';

class CustomEquality<T> implements Equality<T> {
  final bool Function(T, T) comparer;
  CustomEquality(this.comparer);
  @override
  bool equals(T a, T b) => comparer(a, b);
}

void main() {
  group('DripSelect', () {
    testWidgets('DS-1.1: Initial combined value rendered', (WidgetTester tester) async {
      final state1 = dripState('Hello');
      final state2 = dripState('World');

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: DripSelect<(String, String)>(
            select: () => (state1.value, state2.value),
            builder: (context, value) => Text('${value.$1} ${value.$2}'),
          ),
        ),
      );

      expect(find.text('Hello World'), findsOneWidget);
    });

    testWidgets('DS-1.2 & DS-1.3: Rebuilds when sources change', (WidgetTester tester) async {
      final state1 = dripState('Hello');
      final state2 = dripState('World');
      int buildCount = 0;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: DripSelect<(String, String)>(
            select: () => (state1.value, state2.value),
            builder: (context, value) {
              buildCount++;
              return Text('${value.$1} ${value.$2}');
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

    testWidgets('DS-1.4: Does NOT rebuild when non-selected state changes', (WidgetTester tester) async {
      final state1 = dripState('Hello');
      final state2 = dripState('World');
      final unrelated = dripState('Unrelated');
      int buildCount = 0;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: DripSelect<(String, String)>(
            select: () => (state1.value, state2.value),
            builder: (context, value) {
              buildCount++;
              return Text('${value.$1} ${value.$2}');
            },
          ),
        ),
      );

      expect(buildCount, 1);

      unrelated.write('Changed');
      await tester.pumpAndSettle();

      expect(buildCount, 1); // Should not rebuild
    });

    testWidgets('DS-1.5: Does NOT rebuild when sources change to same combined result', (WidgetTester tester) async {
      final firstName = dripState('John');
      final lastName = dripState('Doe');
      int buildCount = 0;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: DripSelect<String>(
            select: () => '${firstName.value} ${lastName.value}',
            builder: (context, value) {
              buildCount++;
              return Text(value);
            },
          ),
        ),
      );

      expect(buildCount, 1);

      // Mutate sources such that combined result is the same
      // Wait, if first name is 'John ' and last name is 'Doe', wait... let's just make one change 
      // where combined result evaluates to same string? Not easy with simple concat.
      // Let's do length.
      final strState = dripState('abc');
      int buildCountLen = 0;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: DripSelect<int>(
            select: () => strState.value.length,
            builder: (context, value) {
              buildCountLen++;
              return Text(value.toString());
            },
          ),
        ),
      );

      expect(buildCountLen, 1);

      strState.write('xyz'); // same length
      await tester.pumpAndSettle();

      expect(buildCountLen, 1); // No rebuild because length is still 3!
    });

    testWidgets('DS-1.6: Internal DripComputed disposed on widget unmount', (WidgetTester tester) async {
      final state = dripState('Hello');

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: DripSelect<String>(
            select: () => state.value,
            builder: (context, value) => Text(value),
          ),
        ),
      );

      expect(state.subscribers.length, 1);

      await tester.pumpWidget(const SizedBox());

      expect(state.subscribers.length, 0);
    });

    testWidgets('DS-1.7: Works with Dart 3 record types as combined value', (WidgetTester tester) async {
      final state1 = dripState('A');
      final state2 = dripState('B');

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: DripSelect<(String, String)>(
            select: () => (state1.value, state2.value),
            builder: (context, value) => Text(value.$1 + value.$2),
          ),
        ),
      );

      expect(find.text('AB'), findsOneWidget);
    });

    testWidgets('DS-1.8: Custom Equality prevents rebuild for custom equal records', (WidgetTester tester) async {
      final state1 = dripState('a');
      int buildCount = 0;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: DripSelect<String>(
            select: () => state1.value,
            equality: CustomEquality((a, b) => a.toLowerCase() == b.toLowerCase()),
            builder: (context, value) {
              buildCount++;
              return Text(value);
            },
          ),
        ),
      );

      expect(buildCount, 1);

      state1.write('A'); // Same under custom equality
      await tester.pumpAndSettle();

      expect(buildCount, 1);
    });
  });
}
