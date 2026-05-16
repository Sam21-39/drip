import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drip_core/drip_core.dart';
import 'package:drip_flutter/drip_flutter.dart';

void main() {
  testWidgets('DripScope.asWidget disposes scope when unmounted',
      (tester) async {
    final scope = DripScope();

    // We can test if a scope is disposed by trying to add an effect
    // Wait, DripScope doesn't expose an isDisposed property.
    // But if it's disposed, effect throws StateError.

    await tester.pumpWidget(
      scope.asWidget(child: const SizedBox()),
    );

    // It's active
    expect(() => scope.effect(() {}), returnsNormally);

    // Unmount
    await tester.pumpWidget(const SizedBox());

    // It's disposed
    expect(() => scope.effect(() {}), throwsA(isA<DripDisposedScopeError>()));
  });
}
