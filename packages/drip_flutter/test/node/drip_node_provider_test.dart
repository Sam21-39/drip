// ignore_for_file: deprecated_member_use_from_same_package
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drip_core/drip_core.dart';
import 'package:drip_flutter/src/node/drip_node.dart';
import 'package:drip_flutter/src/node/drip_node_provider.dart';
import 'package:drip_flutter/src/node/drip_node_context.dart';

class TestNodeA extends DripNode {
  bool onInitCalled = false;
  bool onDisposeCalled = false;
  bool onBackgroundCalled = false;
  bool onForegroundCalled = false;

  late DripState<int> count;

  @override
  void onInit() {
    onInitCalled = true;
    count = state(0);
  }

  @override
  void onDispose() {
    onDisposeCalled = true;
  }

  @override
  void onBackground() {
    onBackgroundCalled = true;
  }

  @override
  void onForeground() {
    onForegroundCalled = true;
  }
}

class TestNodeB extends DripNode {}

void main() {
  group('DripNodeProvider (DRIP-NODE-04, 08)', () {
    testWidgets('NP-1.1: Node created when provider mounts', (tester) async {
      TestNodeA? createdNode;
      await tester.pumpWidget(
        DripNodeProvider<TestNodeA>(
          create: () {
            createdNode = TestNodeA();
            return createdNode!;
          },
          builder: (context, node) => const SizedBox(),
        ),
      );

      expect(createdNode, isNotNull);
      expect(createdNode!.onInitCalled, isTrue);
      expect(createdNode!.count.value, 0);
    });

    testWidgets('NP-1.2: Node disposed when provider unmounts', (tester) async {
      TestNodeA? createdNode;
      await tester.pumpWidget(
        DripNodeProvider<TestNodeA>(
          create: () {
            createdNode = TestNodeA();
            return createdNode!;
          },
          builder: (context, node) => const SizedBox(),
        ),
      );

      expect(createdNode!.onDisposeCalled, isFalse);

      // Unmount the provider by pumping a different widget
      await tester.pumpWidget(const SizedBox());

      expect(createdNode!.onDisposeCalled, isTrue);
    });

    testWidgets(
        'NP-1.3 & NP-1.4: Provider.of and context.node return correct node',
        (tester) async {
      late TestNodeA buildNode;
      late TestNodeA contextNode;
      late TestNodeA ofNode;

      await tester.pumpWidget(
        DripNodeProvider<TestNodeA>(
          create: () => TestNodeA(),
          builder: (context, node) {
            buildNode = node;
            contextNode = context.node<TestNodeA>();
            ofNode = DripNodeProvider.of<TestNodeA>(context);
            return const SizedBox();
          },
        ),
      );

      expect(identical(buildNode, contextNode), isTrue);
      expect(identical(buildNode, ofNode), isTrue);
    });

    testWidgets('NP-1.5: Missing provider throws descriptive FlutterError',
        (tester) async {
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            expect(
              () => context.node<TestNodeA>(),
              throwsA(isA<FlutterError>().having(
                (e) => e.message,
                'message',
                contains('TestNodeA'),
              )),
            );
            return const SizedBox();
          },
        ),
      );
    });

    testWidgets('NP-1.6 & NP-1.7: App lifecycle states forward to node hooks',
        (tester) async {
      TestNodeA? createdNode;
      await tester.pumpWidget(
        DripNodeProvider<TestNodeA>(
          create: () {
            createdNode = TestNodeA();
            return createdNode!;
          },
          builder: (context, node) => const SizedBox(),
        ),
      );

      expect(createdNode!.onBackgroundCalled, isFalse);
      expect(createdNode!.onForegroundCalled, isFalse);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      expect(createdNode!.onBackgroundCalled, isTrue);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      expect(createdNode!.onForegroundCalled, isTrue);
    });

    testWidgets(
        'NP-1.8: Two nested providers of different node types both resolvable',
        (tester) async {
      late TestNodeA resolvedA;
      late TestNodeB resolvedB;

      await tester.pumpWidget(
        DripNodeProvider<TestNodeA>(
          create: () => TestNodeA(),
          builder: (context, nodeA) => DripNodeProvider<TestNodeB>(
            create: () => TestNodeB(),
            builder: (context, nodeB) {
              resolvedA = context.node<TestNodeA>();
              resolvedB = context.node<TestNodeB>();
              return const SizedBox();
            },
          ),
        ),
      );

      expect(resolvedA, isA<TestNodeA>());
      expect(resolvedB, isA<TestNodeB>());
    });

    testWidgets('NP context.maybeNode returns null when missing',
        (tester) async {
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            expect(context.maybeNode<TestNodeA>(), isNull);
            return const SizedBox();
          },
        ),
      );
    });
  });
}
