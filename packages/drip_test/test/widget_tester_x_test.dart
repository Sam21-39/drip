import 'package:drip_test/drip_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('pumpDrip performs two pump cycles', (tester) async {
    var microtaskFlushed = false;
    Future.microtask(() {
      microtaskFlushed = true;
    });

    await tester.pumpDrip();
    expect(microtaskFlushed, isTrue);
  });

  test('expectZeroRebuilds passes when counter unchanged', () async {
    var counter = 7;
    await expectZeroRebuilds(
      readCount: () => counter,
      act: () async {
        // intentionally no-op
      },
    );
  });

  test('expectZeroRebuilds throws when counter changes', () async {
    var counter = 7;
    await expectLater(
      () => expectZeroRebuilds(
        readCount: () => counter,
        act: () async {
          counter++;
        },
      ),
      throwsA(isA<StateError>()),
    );
  });
}
