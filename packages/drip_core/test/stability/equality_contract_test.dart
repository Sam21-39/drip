// ignore_for_file: hash_and_equals

import 'package:test/test.dart';
import 'package:drip_core/drip_core.dart';

// ---------------------------------------------------------------------------
// Test models
// ---------------------------------------------------------------------------

/// Correct implementation — == and hashCode are consistent.
class CorrectModel {
  final int id;
  const CorrectModel(this.id);

  @override
  bool operator ==(Object other) => other is CorrectModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// Buggy == without hashCode override.
/// Two instances with the same id are equal but have different hash codes
/// because Object.hashCode uses identity.
class MissingHashCode {
  final int id;
  const MissingHashCode(this.id);

  @override
  bool operator ==(Object other) => other is MissingHashCode && other.id == id;

  // hashCode deliberately NOT overridden → uses Object.hashCode (identity).
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('DripState — Equality Contract Assertion (Risk 3)', () {
    test('EC-1.1: Correct == and hashCode — no error thrown', () {
      final state = dripState(CorrectModel(1));
      // Writing the same logical value (equal, same hashCode) → skipped silently.
      expect(
        () => state.write(CorrectModel(1)),
        returnsNormally,
      );
    });

    test('EC-1.2: Different values — no equality check triggered', () {
      final state = dripState(CorrectModel(1));
      // Writing a different logical value → equality check skipped (values not equal).
      expect(
        () => state.write(CorrectModel(2)),
        returnsNormally,
      );
    });

    test(
        'EC-1.3: MissingHashCode — equal instances with different identity '
        'hash codes throw DripEqualityViolationError in debug mode', () {
      final a = MissingHashCode(42);
      final b = MissingHashCode(42);

      // a == b is true, but a.hashCode != b.hashCode (Object identity hashes)
      expect(a == b, isTrue);

      // Only test if they actually have different hash codes (they will in practice
      // since Object.hashCode is identity-based, but we guard the test).
      if (a.hashCode == b.hashCode) {
        // Fluke: same identity hash — skip to avoid false positive.
        return;
      }

      final state = dripState(a);
      expect(
        () => state.write(b),
        throwsA(isA<DripEqualityViolationError>()),
      );
    });

    test(
        'EC-1.4: DripEqualityViolationError message names the type and '
        'both hash codes', () {
      final a = MissingHashCode(99);
      final b = MissingHashCode(99);

      if (a.hashCode == b.hashCode) return; // guard for hash collision

      final state = dripState(a);

      DripEqualityViolationError? caught;
      try {
        state.write(b);
      } on DripEqualityViolationError catch (e) {
        caught = e;
      }

      expect(caught, isNotNull);
      final msg = caught.toString();
      expect(msg, contains('MissingHashCode'));
      expect(msg, contains(a.hashCode.toString()));
      expect(msg, contains(b.hashCode.toString()));
    });

    test('EC-1.5: Primitive types — no false positive', () {
      final state = dripState(42);
      // Same int value — primitives always satisfy the contract.
      expect(() => state.write(42), returnsNormally);
    });

    test('EC-1.6: String type — no false positive', () {
      final state = dripState('hello');
      expect(() => state.write('hello'), returnsNormally);
    });

    test('EC-1.7: Writing a genuinely different value never triggers the check',
        () {
      // The assert only fires when _equality.equals(a, b) is TRUE.
      // When values differ, equality is false and the check is skipped.
      final state = dripState(MissingHashCode(1));
      // Different id → not equal → no contract check → no error.
      expect(
        () => state.write(MissingHashCode(2)),
        returnsNormally,
      );
    });
  });
}
