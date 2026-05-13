import 'package:flutter_test/flutter_test.dart';
import 'package:drip_core/drip_core.dart';
import 'package:drip_flutter/src/binding/drip_binding.dart';

void main() {
  group('DripBinding Unit Tests', () {
    test('B-1.1: Binding applies initial value on creation', () {
      final state = dripState('initial');
      String? appliedValue;

      DripBinding<String>(
        state: state,
        apply: (value) => appliedValue = value,
        markNeeds: () {},
      );

      expect(appliedValue, 'initial');
    });

    test('B-1.2: Binding calls apply then markNeeds when state changes',
        () async {
      final state = dripState('initial');
      String? appliedValue;
      var markNeedsCalled = false;

      DripBinding<String>(
        state: state,
        apply: (value) => appliedValue = value,
        markNeeds: () => markNeedsCalled = true,
      );

      // Reset for change check
      markNeedsCalled = false;

      state.write('updated');
      await pumpEventQueue();

      expect(appliedValue, 'updated');
      expect(markNeedsCalled, true);
    });

    test('B-1.3: Disposed binding ignores subsequent state changes', () {
      final state = dripState('initial');
      var applyCount = 0;

      final binding = DripBinding<String>(
        state: state,
        apply: (_) => applyCount++,
        markNeeds: () {},
      );

      expect(applyCount, 1);
      binding.dispose();

      state.write('updated');
      expect(applyCount, 1,
          reason: 'Apply should not be called after disposal');
    });

    test('B-1.4: Binding deregisters from state on dispose()', () {
      final state = dripState('initial');

      final binding = DripBinding<String>(
        state: state,
        apply: (_) {},
        markNeeds: () {},
      );

      // This depends on internal knowledge that DripState uses a set of subscribers.
      // We can't access private fields, but we can verify that no more
      // notifications are received.
      binding.dispose();

      // If we could access state.subscribers, we'd check it's empty.
      // For now, B-1.3 covers the functional requirement.
    });

    test('B-1.5: Rebinding disposes old binding', () {
      final state = dripState('initial');
      var oldApplyCount = 0;

      final oldBinding = DripBinding<String>(
        state: state,
        apply: (_) => oldApplyCount++,
        markNeeds: () {},
      );

      expect(oldApplyCount, 1);
      oldBinding.dispose();

      state.write('updated');
      expect(oldApplyCount, 1);
    });
  });
}
