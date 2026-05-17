# DRIP Architecture Contract

> Every AI session loads this file first.
> Every PR is judged against it.
> These invariants do not change without a major version bump.

---

## Invariants That Must Never Be Violated

**1. No async dependency tracking.**
`DripState.read()` inside an async gap (`Future.then`, `await`, `Timer`)
MUST NOT register a dependency in any active `DripComputed` or `DripEffect`.
Dependency tracking is synchronous-only, by design.

**2. No setState() — ever.**
The framework NEVER calls `setState()` on any Flutter `State` object.
The render layer is reached only through `RenderObject` property setters
and `markNeedsPaint()` / `markNeedsLayout()`.

**3. Disposal is idempotent.**
`DripScope.dispose()` MUST be safe to call multiple times.
No throws. No duplicate side effects.

**4. No references survive disposal.**
A disposed `DripScope` MUST NOT hold references to any `DripState`,
`DripComputed`, or `DripEffect`. The GC must collect the entire scope
graph after disposal.

**5. One propagation pass per synchronous frame.**
All `DripState.write()` calls within a single synchronous stack frame
MUST produce exactly one propagation pass via `DripBatch`,
regardless of how many states changed.

**6. Native bridge: no method channels after init.**
`DripNative` values MUST NOT require method channels after app initialization.
Init may use a channel once (to register FFI callback pointers).
All subsequent synchronization is via shared memory.

**7. Bindings don't outlive their RenderObject.**
When a widget is unmounted, its `DripBinding` MUST deregister from
`DripState` within the same call to `unmount()`.
No binding may survive its `RenderObject`.

---

## Layer Map

```
┌─────────────────────────────────────────┐
│         Application / DripNode          │  ← Feature modules, DI, lifecycle
├─────────────────────────────────────────┤
│        drip_flutter                     │  ← DripText, DripOpacity, DripFrame
│        (Render layer)                   │     Binds DripState → RenderObject
├─────────────────────────────────────────┤
│        drip_core                        │  ← DripState, DripComputed,
│        (Pure Dart reactive engine)      │     DripEffect, DripScope, DripBatch
├─────────────────────────────────────────┤
│        drip_core_native (optional)      │  ← FFI shared memory bridge
│        (Native state bridge)            │     Android WorkManager, iOS BGTask
└─────────────────────────────────────────┘
```

## Naming Convention

| Concept | Dart API | Notes |
|---|---|---|
| Atomic reactive value | `DripState<T>` | |
| Derived reactive value | `DripComputed<T>` | Lazy, cached, version-clocked |
| Side effect | `DripEffect` | Runs once, re-runs on dependency change |
| Lifetime owner | `DripScope` | Owns and disposes its children |
| Batched scheduler | `DripBatch` | Microtask-based, deduplicates |
| RenderObject binding | `DripBinding<T>` | Internal — not public API |
| Direct text binding | `DripText` | Replaces `Text` for reactive strings |
| Opacity binding | `DripOpacity` | Paint-only — no layout |
| Transform binding | `DripTransform` | Paint-only — no layout |
| Structural rebuild | `DripFrame<T>` | Explicit opt-in for widget rebuilds |
| Feature module | `DripNode` | Owns scope, state, DI |
| Native primitive | `DripNative<T>` | FFI shared memory |

## What DRIP Is Not

- Not a replacement for `StatefulWidget` everywhere — `DripFrame` exists for cases where rebuilds are correct.
- Not a global store — all state is scoped to a `DripScope` or `DripNode`.
- Not magic — every update path is explicit and traceable.
