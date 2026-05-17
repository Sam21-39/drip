import 'package:drip_core/drip_core.dart';
import 'package:drip_flutter/drip_flutter.dart';
import 'package:drip_test/drip_test.dart';
import 'package:flutter_test/flutter_test.dart';

class _LifecycleNode extends DripNode {
  int backgroundCalls = 0;
  int foregroundCalls = 0;
  bool disposed = false;

  _LifecycleNode() : super(debugName: '_LifecycleNode');

  @override
  void onBackground() {
    backgroundCalls++;
  }

  @override
  void onForeground() {
    foregroundCalls++;
  }

  @override
  void onDispose() {
    disposed = true;
  }
}

void main() {
  group('DripNodeTester', () {
    test('drives lifecycle and dispose', () {
      final tester = DripNodeTester(_LifecycleNode.new);

      tester.simulateBackground();
      tester.simulateForeground();
      tester.dispose();

      expect(tester.node.backgroundCalls, 1);
      expect(tester.node.foregroundCalls, 1);
      expect(tester.node.disposed, isTrue);
    });
  });

  group('DripAsyncTester', () {
    test('reports loading to data transition', () async {
      final scope = DripScope(debugName: 'test-scope');
      addTearDown(scope.dispose);

      final source = DripAsync<int>(scope: scope);
      final tester = DripAsyncTester(source);

      final runFuture = source.run(() async => 42);

      expect(tester.isLoading, isTrue);
      await runFuture;
      await tester.flush();

      expect(tester.isLoading, isFalse);
      expect(tester.dataOrNull, 42);
      expect(tester.errorOrNull, isNull);
    });

    test('reports error transition', () async {
      final scope = DripScope(debugName: 'test-scope');
      addTearDown(scope.dispose);

      final source = DripAsync<int>(scope: scope);
      final tester = DripAsyncTester(source);

      await source.run(() async => throw StateError('boom'));
      await tester.flush();

      expect(tester.isLoading, isFalse);
      expect(tester.dataOrNull, isNull);
      expect(tester.errorOrNull, isA<StateError>());
    });
  });
}
