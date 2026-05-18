# DRIP Flutter Two-Pump Audit

Date: 2026-05-18
Scope: `packages/drip_flutter/test/widgets/`

## Policy

For tests that call `DripState.write()` and then assert rendered output, use:

1. `await tester.pump()` to flush `DripBatch` microtasks
2. `await tester.pump()` to process widget/frame updates

`await tester.pumpAndSettle()` is accepted and currently used as a practical
superset in many tests. Phase 6 (`drip_test`) should migrate these to
`pumpDrip()` for explicitness and consistency.

## Compliance Summary

Compliant (no reactive write assertions or uses `pumpAndSettle`/equivalent):

- `drip_async_builder_test.dart`
- `drip_builder_test.dart`
- `drip_item_builder_test.dart`
- `drip_lifecycle_test.dart`
- `drip_scope_widget_test.dart`
- `drip_select_test.dart`

Needs migration to explicit two-pump helper in Phase 6:

- `drip_semantics_test.dart`
  - Uses `state.write(1)` followed by debounce timing pumps.
  - Functionally valid for debounce behavior, but should move to shared
    `pumpDrip()` + debounce-specific pump sequence for consistency.

## Phase 6 Action

Standardize widget tests on `pumpDrip()` from `drip_test` once published.
