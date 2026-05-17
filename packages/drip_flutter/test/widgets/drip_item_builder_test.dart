import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drip_core/drip_core.dart';
import 'package:drip_flutter/drip_flutter.dart';

void main() {
  group('DripItemBuilder Tests', () {
    testWidgets(
        'Standard Mode: Renders initial value and updates on element write',
        (WidgetTester tester) async {
      final items = DripItems<String>(['A', 'B']);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Column(
            children: [
              DripItemBuilder<String>(
                items: items,
                index: 0,
                builder: (context, value) => Text('Item 0: $value'),
              ),
              DripItemBuilder<String>(
                items: items,
                index: 1,
                builder: (context, value) => Text('Item 1: $value'),
              ),
            ],
          ),
        ),
      );

      expect(find.text('Item 0: A'), findsOneWidget);
      expect(find.text('Item 1: B'), findsOneWidget);

      // Mutate element 0 -> should only rebuild the first item builder
      items[0].write('AA');
      await tester.pumpAndSettle();

      expect(find.text('Item 0: AA'), findsOneWidget);
      expect(find.text('Item 1: B'), findsOneWidget);
    });

    testWidgets('Standard Mode: Listener cleanup on widget disposal',
        (WidgetTester tester) async {
      final items = DripItems<String>(['A']);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: DripItemBuilder<String>(
            items: items,
            index: 0,
            builder: (context, value) => Text(value),
          ),
        ),
      );

      expect(items[0].subscribers.length, 1);

      // Unmount the widget
      await tester.pumpWidget(const SizedBox());

      expect(items[0].subscribers.length, 0);
    });

    testWidgets('Standard Mode: didUpdateWidget switches listeners correctly',
        (WidgetTester tester) async {
      final items1 = DripItems<String>(['A']);
      final items2 = DripItems<String>(['X']);

      Widget buildWidget(DripItems<String> items) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: DripItemBuilder<String>(
            items: items,
            index: 0,
            builder: (context, value) => Text(value),
          ),
        );
      }

      await tester.pumpWidget(buildWidget(items1));
      expect(find.text('A'), findsOneWidget);
      expect(items1[0].subscribers.length, 1);
      expect(items2[0].subscribers.length, 0);

      await tester.pumpWidget(buildWidget(items2));
      expect(find.text('X'), findsOneWidget);
      expect(items1[0].subscribers.length, 0);
      expect(items2[0].subscribers.length, 1);
    });

    testWidgets('renderMode: Uses DripText bypassing standard builder rebuilds',
        (WidgetTester tester) async {
      final items = DripItems<String>(['A']);
      int buildCount = 0;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: DripItemBuilder<String>(
            items: items,
            index: 0,
            renderMode: true,
            builder: (context, value) {
              buildCount++;
              return Text(value);
            },
          ),
        ),
      );

      // In renderMode: true, the widget tree returned should be DripText.
      // DripText is a LeafRenderObjectWidget, so the builder function is NEVER called!
      expect(find.byType(DripText), findsOneWidget);
      expect(buildCount, 0); // Builder should be bypassed completely!

      RenderParagraph renderText() =>
          tester.renderObject<RenderParagraph>(find.byType(DripText));

      // Verify direct render-binding text value is correct.
      expect(renderText().text.toPlainText(), 'A');

      // Update state -> direct RenderParagraph update, builder is STILL never called
      items[0].write('B');
      await tester.pumpAndSettle();

      expect(renderText().text.toPlainText(), 'B');
      expect(buildCount, 0);
    });
  });
}
