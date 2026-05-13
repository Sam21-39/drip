## 0.1.1-alpha (2026-05-13)

### Added
- `DripListener` interface for external render-layer subscribers.
- `subscribe`/`unsubscribe` methods on `DripState<T>` for cross-package listener registration.

## 0.1.0-alpha (2026-05-13)

**Initial Release of the DRIP Reactive Engine.**

### Added
- `DripState<T>` — atomic reactive value with version clock and equality check
- `DripComputed<T>` — lazy, cached derived value with automatic dependency tracking
- `DripEffect` — side-effect runner with automatic re-execution on dependency change
- `DripScope` — lifetime owner with LIFO disposal guarantee
- `DripBatch` — microtask-based coalescing scheduler (O(1) propagation passes)
- `TrackingContext` — stack-based, synchronous-only dependency registration
- `Equality<T>` interface with `DefaultEquality` and `IdentityEquality` implementations
- `DripCircularDependencyError` — thrown on circular computed dependency
- `DripDisposedScopeError` — thrown on access to disposed scope
- Top-level `dripState<T>()` factory function

### Architecture
- Zero Flutter dependency — usable in Dart CLI and server applications
- Zero Zone-based tracking — async gaps never register spurious dependencies
- Pure Dart SDK `>=3.3.0` — no third-party runtime dependencies

### Testing
- 30+ unit tests covering all invariants
- CI-gated benchmark tests: write throughput, propagation efficiency, batching
