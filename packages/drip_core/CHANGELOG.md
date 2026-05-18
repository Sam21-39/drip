## [1.0.1] — 2026-05-18

### Changed
- Documentation and release-readiness polish across README, changelog, and
  package metadata.
- CI/release verification runbook validated for stable `1.0.x` flow.

---

## [1.0.0] — 2026-05-17

### Stable Release
First stable release of drip_core. Semantic versioning is now enforced: no
public symbol will be removed or renamed without a major version bump; no new
required parameters will be added to existing constructors without a major
version bump.

### Public API (frozen)
- `DripState<T>` — mutable reactive value.
- `dripState<T>()` — convenience factory for `DripState<T>`.
- `DripComputed<T>` — lazily evaluated derived reactive value.
- `DripEffect` — side-effect subscriber with no return value.
- `DripReadable<T>` — unified read and subscribe interface.
- `DripScope` — owner and disposer of reactive resources.
- `DripAsync<T>` — async operation state container.
- `DripAsyncValue<T>` — sealed base class for async state.
- `DripAsyncData<T>` — resolved async value.
- `DripAsyncLoading<T>` — in-flight async value with optional previous data.
- `DripAsyncError<T>` — failed async value with optional previous data.
- `DripItems<T>` — index-addressable collection of `DripState<T>` instances.
- `DripTrace` — debug-only mutation stack trace capture.
- `Equality<T>` — equality strategy interface for state comparisons.
- `DefaultEquality<T>` — equality strategy using Dart's `==`.
- `IdentityEquality<T>` — equality strategy using object identity.
- `defaultEquality` — shared default equality instance.
- `DripCircularDependencyError` — thrown for computed cycles.
- `DripDisposedScopeError` — thrown when a disposed scope is used.
- `DripDisposalError` — reports scope disposal callback failures.
- `DripEqualityViolationError` — reports invalid equality/hash contracts.
- `VoidCallback` — callback signature used by subscriptions.

### Added
- `DripItems<T>` — index-addressable collection of `DripState<T>` instances
  with item-level granularity (added in Phase 0, promoted to stable).
- Benchmark suite for write throughput, diamond graph propagation, direct
  subscriber propagation, and scope disposal.
- CI coverage and benchmark enforcement.

### Changed
- All previously internal implementation symbols moved to `src/` and removed
  from public exports: `DripBatch`, `DripSchedulerConfig`, and
  `TrackingContext`.
- Async value variants renamed from `DripLoading`, `DripData`, and `DripError`
  to `DripAsyncLoading`, `DripAsyncData`, and `DripAsyncError`.
- Test coverage raised above the 95% release gate.
- Dartdoc completed on the public API.

### Removed
- Public exports for scheduler and tracking implementation details.

### Performance
- Write throughput: >10M writes/sec (benchmark: `benchmark/write_throughput.dart`).
- Single-propagation-pass: diamond graph computes C once per S write.
- O(n) direct subscriber propagation: 1000 subscribers notified in <50ms.

---

## 0.5.1-alpha (2026-05-16)

### Added
- **`DripItems<T>`**: High-performance, highly-granular reactive collection wrapping elements in `DripState` to isolate value writes from structural mutations.
- **`DripTrace`**: Diagnostic layer for capturing synchronous mutation context.
- **`DripReadableX`**: Extensions `asString`, `map`, and `where` for reactive values.

### Changed
- `DripBatch`: Microtask flush now chains stack traces using `DripTrace` when available.
- `DripState`/`DripComputed`: Constructors now assert presence of `debugName` for better trace diagnostics.

---

## 0.5.0-alpha (2026-05-16)

### Fixed
- **Scheduler benchmark dead code** (`benchmark/scheduler_flood_benchmark.dart`): removed
  the unused `Timer? flushTimer` variable and its always-null `?.cancel()` call, along
  with the now-redundant `dart:async` import. Zero behaviour change — the timer was a
  leftover stub from an earlier design.

### Internal
- Benchmark verified clean under `dart analyze` (zero hints, zero dead-code warnings).

---

## 0.2.0-alpha


### Added
- `DripReadable<T>` — common read + subscribe interface implemented by
  `DripState<T>`, `DripComputed<T>`, and `DripAsync<T>`
- `DripAsyncValue<T>` — sealed class with three variants:
  - `DripLoading<T>` — carries optional `previousData` for refresh patterns
  - `DripData<T>` — carries the successful result value
  - `DripError<T>` — carries error, stackTrace, optional `previousData`
  - Convenience: `isLoading`, `hasData`, `hasError`, `dataOrNull`,
    `getDataOr()`, `map()`, `hasPreviousData`
- `DripAsync<T>` — reactive async state container extending
  `DripState<DripAsyncValue<T>>`
  - `setLoading()` — transitions to loading, preserves previous data
  - `setData(value)` — transitions to data
  - `setError(error, stack)` — transitions to error, preserves previous data
  - `run(computation)` — manages all three transitions automatically with
    generation-counter concurrent-call cancellation guarantee
  - `fromFuture()` — static factory
  - `fromStream()` — static factory with scope-registered subscription

### Changed
- `DripState<T>` — now implements `DripReadable<T>`
- `DripComputed<T>` — now implements `DripReadable<T>`

---

## 0.1.1-alpha (2026-05-14)

### Added
- `DripValue<T>` interface — public readable/subscribable contract shared by `DripState<T>` and `DripComputed<T>`. Enables the Flutter render layer to accept either as a binding source without casting.
- `DripListener` interface and `ListenerSubscriber` adapter — moved to `drip_state_base.dart` for package-wide accessibility.
- `subscribe(DripListener)` / `unsubscribe(DripListener)` on both `DripState<T>` and `DripComputed<T>`.

### Exports (`drip_core.dart`)
- `DripValue` and `DripListener` now exported from the public barrel via `drip_state_base.dart`.

---

## 0.1.0-alpha (2026-05-13)

**Initial Release of the DRIP Reactive Engine.**

### Added
- `DripState<T>` — atomic reactive value with version clock and equality check.
- `DripComputed<T>` — lazy, cached derived value with automatic dependency tracking.
- `DripEffect` — side-effect runner with automatic re-execution on dependency change.
- `DripScope` — lifetime owner with LIFO disposal guarantee.
- `DripBatch` — microtask-based coalescing scheduler (O(1) propagation passes per synchronous block).
- `TrackingContext` — stack-based, synchronous-only dependency registration.
- `Equality<T>` interface with `DefaultEquality` and `IdentityEquality` implementations.
- `DripCircularDependencyError` — thrown on circular computed dependency.
- `DripDisposedScopeError` — thrown on access to a disposed scope.
- Top-level `dripState<T>()` factory function.

### Architecture
- Zero Flutter dependency — usable in Dart CLI and server applications.
- Zero Zone-based tracking — async gaps never register spurious dependencies.
- Pure Dart SDK `>=3.3.0` — no third-party runtime dependencies.

### Testing
- 30+ unit tests covering all invariants.
- CI-gated benchmark tests: write throughput, propagation efficiency, batching.
