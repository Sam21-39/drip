import 'package:drip_core/drip_core.dart';
import 'package:test/test.dart';

void main() {
  group('DripBatch', () {
    test('4.1 N synchronous writes -> exactly 1 propagation pass', () async {
      final a = dripState(0);
      var runs = 0;
      DripEffect(() {
        a.value;
        runs++;
      });

      await Future.microtask(() {});
      expect(runs, 1);

      a.write(1);
      a.write(2);
      a.write(3);

      await Future.microtask(() {});
      expect(runs, 2);
    });

    test('4.2 Writes across different states batch together', () async {
      final a = dripState(0);
      final b = dripState(0);
      var runs = 0;
      DripEffect(() {
        a.value;
        b.value;
        runs++;
      });

      await Future.microtask(() {});
      expect(runs, 1);

      a.write(1);
      b.write(1);

      await Future.microtask(() {});
      expect(runs, 2);
    });
  });
}
