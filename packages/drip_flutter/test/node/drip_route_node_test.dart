import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drip_flutter/src/node/drip_route_node.dart';

class TestRouteNode extends DripRouteNode {
  int enterCount = 0;
  int leaveCount = 0;
  bool disposed = false;

  @override
  void onRouteEnter() => enterCount++;

  @override
  void onRouteLeave() => leaveCount++;

  @override
  void onDispose() => disposed = true;
}

void main() {
  group('DripRouteNode (DRIP-NODE-05)', () {
    late RouteObserver<ModalRoute<dynamic>> routeObserver;

    setUp(() {
      routeObserver = RouteObserver<ModalRoute<dynamic>>();
    });

    Widget buildApp({required Widget home}) {
      return MaterialApp(
        navigatorObservers: [routeObserver],
        home: home,
      );
    }

    testWidgets('RN-1.1, 1.2, 1.3, 1.4: Route lifecycle integration',
        (tester) async {
      late TestRouteNode createdNode;

      await tester.pumpWidget(buildApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => DripRouteNodeProvider<TestRouteNode>(
                      create: () {
                        createdNode = TestRouteNode();
                        return createdNode;
                      },
                      routeObserver: routeObserver,
                      builder: (context, node) => Scaffold(
                        body: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const Scaffold(body: Text('Third'))),
                            );
                          },
                          child: const Text('Push Third'),
                        ),
                      ),
                    ),
                  ),
                );
              },
              child: const Text('Start'),
            ),
          ),
        ),
      ));

      // Push the route with the node
      await tester.tap(find.text('Start'));
      await tester.pumpAndSettle();

      // RN-1.1: Route pushed initially
      expect(createdNode.enterCount, 1);
      expect(createdNode.leaveCount, 0);

      // Push third route
      await tester.tap(find.text('Push Third'));
      await tester.pumpAndSettle();

      // RN-1.2: First route leaves (another pushed on top)
      expect(createdNode.enterCount, 1);
      expect(createdNode.leaveCount, 1);

      // Pop third route
      var nav = tester.state<NavigatorState>(find.byType(Navigator));
      nav.pop();
      await tester.pumpAndSettle();

      // RN-1.3: First route enters again (returned to via pop)
      expect(createdNode.enterCount, 2);
      expect(createdNode.leaveCount, 1);

      // Pop the route with the node
      nav = tester.state<NavigatorState>(find.byType(Navigator));
      nav.pop();
      await tester.pumpAndSettle();

      // RN-1.4: Node disposed when route is popped completely
      expect(createdNode.leaveCount, 2);
      expect(createdNode.disposed, isTrue);
    });
  });
}
