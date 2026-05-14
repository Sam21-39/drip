// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:demo_grid/grid_demo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Grid Demo smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MaterialApp(home: GridDemoScreen()));

    // Verify that the title is present.
    expect(find.text('drip_flutter — Zero Rebuild Demo'), findsOneWidget);

    // Verify that we have some grid cells (DripText widgets).
    // Note: Since they update via DripState, we can just check for their existence.
    expect(find.byType(GridView), findsOneWidget);
  });
}
