import 'package:drip_core/drip_core.dart';
import 'package:test/test.dart';

void main() {
  group('DripEffect', () {
    test('3.1 Effect runs immediately on creation', () {
      var runs = 0;
      DripEffect(() => runs++);
      expect(runs, 1);
    });

    test('3.2 Effect re-runs when dependency changes', () async {
      final a = dripState(0);
      var runs = 0;
      DripEffect(() {
        a.value;
        runs++;
      });

      await Future.microtask(() {});
      expect(runs, 1);

      a.write(1);
      await Future.microtask(() {});
      expect(runs, 2);
    });

    test('3.4 Effect is cancelled after dispose()', () async {
      final a = dripState(0);
      var runs = 0;
      final effect = DripEffect(() {
        a.value;
        runs++;
      });

      await Future.microtask(() {});
      expect(runs, 1);

      effect.dispose();
      a.write(1);
      await Future.microtask(() {});
      expect(runs, 1); // No change
    });

    test('3.5 Effect registered with scope is cancelled on scope.dispose()',
        () async {
      final scope = DripScope();
      final a = dripState(0);
      var runs = 0;

      scope.effect(() {
        a.value;
        runs++;
      });

      await Future.microtask(() {});
      expect(runs, 1);

      scope.dispose();
      a.write(1);
      await Future.microtask(() {});
      expect(runs, 1);
    });
  });
}
