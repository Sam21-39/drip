import 'package:flutter_test/flutter_test.dart';
import 'package:drip_core/drip_core.dart';
import 'package:drip_flutter/drip_flutter.dart';

void main() {
  test('DripReadableX asString formats correctly', () async {
    final state = dripState(42);
    final stringState = state.asString((v) => 'Count: $v');

    expect(stringState.value, 'Count: 42');

    state.write(99);
    await Future.microtask(() {});

    expect(stringState.value, 'Count: 99');
  });

  test('DripReadableX map transforms correctly', () async {
    final state = dripState(2);
    final doubled = state.map((v) => v * 2);

    expect(doubled.value, 4);

    state.write(5);
    await Future.microtask(() {});

    expect(doubled.value, 10);
  });

  test('DripReadableX where filters correctly', () async {
    final state = dripState(1);
    final evens = state.where((v) => v % 2 == 0);

    // Initial evaluation happens unconditionally
    expect(evens.value, 1);

    state.write(2);
    await Future.microtask(() {});
    expect(evens.value, 2);

    state.write(3); // Should be filtered out
    await Future.microtask(() {});
    expect(evens.value, 2); // keeps previous value

    state.write(4);
    await Future.microtask(() {});
    expect(evens.value, 4);
  });
}
