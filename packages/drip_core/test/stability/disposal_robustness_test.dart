import 'package:test/test.dart';
import 'package:drip_core/drip_core.dart';

void main() {
  group('DripScope — Disposal Robustness (Risk 5)', () {
    // Helper that records which disposable indices were called.
    (DripScope scope, List<bool> called) _buildScope({
      required int count,
      required Set<int> throwAt, // 1-indexed
    }) {
      final scope = DripScope(debugName: 'test-scope');
      final called = List<bool>.filled(count, false);

      for (var i = 0; i < count; i++) {
        final index = i; // capture
        scope.registerDisposal(() {
          called[index] = true;
          if (throwAt.contains(index + 1)) {
            throw StateError('Disposable ${index + 1} failed');
          }
        });
      }
      return (scope, called);
    }

    test('D-1.1: All 10 disposables called even when #5 throws', () {
      final (scope, called) = _buildScope(count: 10, throwAt: {5});

      DripDisposalError? caught;
      try {
        scope.dispose();
      } on DripDisposalError catch (e) {
        caught = e;
      }

      // Every disposable was called.
      expect(called, everyElement(isTrue));

      // Exactly one error collected.
      expect(caught, isNotNull);
      expect(caught!.errors.length, 1);
    });

    test('D-1.2: All 10 disposables called when #3, #6, #9 throw', () {
      final (scope, called) = _buildScope(count: 10, throwAt: {3, 6, 9});

      DripDisposalError? caught;
      try {
        scope.dispose();
      } on DripDisposalError catch (e) {
        caught = e;
      }

      expect(called, everyElement(isTrue));
      expect(caught, isNotNull);
      expect(caught!.errors.length, 3);
    });

    test('D-1.3: No error thrown when all disposables succeed', () {
      final (scope, called) = _buildScope(count: 5, throwAt: {});

      expect(() => scope.dispose(), returnsNormally);
      expect(called, everyElement(isTrue));
    });

    test('D-1.4: DripDisposalError contains stack traces for each error', () {
      final (scope, _) = _buildScope(count: 3, throwAt: {2});

      DripDisposalError? caught;
      try {
        scope.dispose();
      } on DripDisposalError catch (e) {
        caught = e;
      }

      expect(caught!.stackTraces.length, 1);
      expect(caught.stackTraces.first, isA<StackTrace>());
    });

    test('D-1.5: DripDisposalError.toString() names the scope and count', () {
      final (scope, _) = _buildScope(count: 4, throwAt: {1, 3});

      DripDisposalError? caught;
      try {
        scope.dispose();
      } on DripDisposalError catch (e) {
        caught = e;
      }

      final msg = caught.toString();
      expect(msg, contains('2 disposal(s) failed'));
      expect(msg, contains('"test-scope"'));
    });

    test('D-1.6: Dispose is idempotent — second call is a no-op (Invariant 3)',
        () {
      final scope = DripScope();
      var callCount = 0;
      scope.registerDisposal(() => callCount++);

      scope.dispose();
      scope.dispose(); // must not throw or re-run disposals

      expect(callCount, 1);
    });

    test('D-1.7: Disposals run in LIFO order', () {
      final scope = DripScope();
      final order = <int>[];
      scope.registerDisposal(() => order.add(1));
      scope.registerDisposal(() => order.add(2));
      scope.registerDisposal(() => order.add(3));

      scope.dispose();

      expect(order, [3, 2, 1]);
    });
  });
}
