// ignore_for_file: deprecated_member_use_from_same_package
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drip_flutter/src/list/drip_list.dart';
import 'package:drip_flutter/src/list/drip_list_view.dart';

void main() {
  group('DripListView (DRIP-NODE-07)', () {
    testWidgets('LV-1.1: Initial render shows all items', (tester) async {
      final list = DripList<String>(['A', 'B', 'C']);

      await tester.pumpWidget(MaterialApp(
        home: DripListView<String>(
          list: list,
          itemBuilder: (context, item, index) => Text(item),
        ),
      ));

      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);
    });

    testWidgets('LV-1.2: list[i] = newValue rebuilds ONLY tile i',
        (tester) async {
      final list = DripList<String>(['A', 'B', 'C']);
      final buildCounts = <int, int>{0: 0, 1: 0, 2: 0};

      await tester.pumpWidget(MaterialApp(
        home: DripListView<String>(
          list: list,
          itemBuilder: (context, item, index) {
            buildCounts[index] = (buildCounts[index] ?? 0) + 1;
            return Text(item);
          },
        ),
      ));

      expect(buildCounts[0], 1);
      expect(buildCounts[1], 1);
      expect(buildCounts[2], 1);

      list[1] = 'X';
      await tester.pump();

      expect(find.text('X'), findsOneWidget);
      expect(find.text('B'), findsNothing);

      // Only tile 1 should have rebuilt
      expect(buildCounts[0], 1);
      expect(buildCounts[1], 2);
      expect(buildCounts[2], 1);
    });

    testWidgets('LV-1.3 & LV-1.4: add/remove triggers structural rebuild',
        (tester) async {
      final list = DripList<String>(['A', 'B']);

      await tester.pumpWidget(MaterialApp(
        home: DripListView<String>(
          list: list,
          itemBuilder: (context, item, index) => Text(item),
        ),
      ));

      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(find.text('C'), findsNothing);

      list.add('C');
      await tester.pump();

      expect(find.text('C'), findsOneWidget); // Tile appeared

      list.removeAt(0); // Removes 'A'
      await tester.pump();

      expect(find.text('A'), findsNothing); // Tile gone
      expect(find.text('B'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);
    });

    testWidgets('LV-1.5: Tile listener deregistered when tile is disposed',
        (tester) async {
      final list = DripList<String>(List.generate(100, (i) => 'Item $i'));

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 300,
            child: DripListView<String>(
              list: list,
              itemBuilder: (context, item, index) => SizedBox(
                height: 100, // 3 visible at a time
                child: Text(item),
              ),
            ),
          ),
        ),
      ));

      expect(find.text('Item 0'), findsOneWidget);
      expect(find.text('Item 50'), findsNothing);

      // Scroll down far enough to dispose item 0
      final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));
      scrollable.position.jumpTo(5000.0);
      await tester.pump();

      expect(find.text('Item 0'), findsNothing);
      expect(find.text('Item 50'), findsOneWidget);

      // Now updating list[0] should not throw or cause setState on unmounted tile
      expect(() => list[0] = 'Changed 0', returnsNormally);
      await tester.pump(); // Should not crash
    });

    testWidgets(
        'LV-1.6 & LV-1.7: emptyBuilder renders when empty, replaced on add',
        (tester) async {
      final list = DripList<String>([]);

      await tester.pumpWidget(MaterialApp(
        home: DripListView<String>(
          list: list,
          itemBuilder: (context, item, index) => Text(item),
          emptyBuilder: (context) => const Text('List is empty'),
        ),
      ));

      expect(find.text('List is empty'), findsOneWidget);
      expect(find.byType(ListView), findsNothing);

      list.add('First');
      await tester.pump();

      expect(find.text('List is empty'), findsNothing);
      expect(find.byType(ListView), findsOneWidget);
      expect(find.text('First'), findsOneWidget);
    });

    testWidgets(
        'LV-1.8: 10,000-item list single []= update rebuilds exactly 1 tile',
        (tester) async {
      final list = DripList<String>(List.generate(10000, (i) => 'Item $i'));
      final buildCounts = <int, int>{};

      void trackBuild(int index) {
        if (index == 0 ||
            index == 1 ||
            index == 4999 ||
            index == 5000 ||
            index == 5001 ||
            index == 9999) {
          buildCounts[index] = (buildCounts[index] ?? 0) + 1;
        }
      }

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: DripListView<String>(
            list: list,
            itemBuilder: (context, item, index) {
              trackBuild(index);
              return SizedBox(height: 50, child: Text(item));
            },
          ),
        ),
      ));

      // Initial build puts 0 and some others in view
      expect(buildCounts[0], greaterThan(0));

      // Jump to make 4999, 5000, 5001 visible
      final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));
      scrollable.position.jumpTo(4999 * 50.0);
      await tester.pump();

      // Record baselines
      final baseline5000 = buildCounts[5000] ?? 0;
      final baseline5001 = buildCounts[5001] ?? 0;

      expect(baseline5000, greaterThan(0));
      expect(baseline5001, greaterThan(0));

      // Trigger update on exactly index 5000
      list[5000] = 'Changed 5000';
      await tester.pump();

      // 5000 should have rebuilt (+1), 5001 should NOT (+0)
      expect(buildCounts[5000], baseline5000 + 1);
      expect(buildCounts[5001], baseline5001);

      expect(find.text('Changed 5000'), findsOneWidget);
    });
  });
}
