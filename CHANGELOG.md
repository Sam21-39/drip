## 0.5.1-alpha (2026-05-16)

### Added
- **`DripTrace`**: Debug-only diagnostic layer that captures synchronous call context at state mutation and chains stack traces across `DripBatch` microtask boundaries.
- **`DripSemantics`**: Accessibility bridge widget that synchronizes `DripReadable<T>` to the Flutter semantics tree with a configurable debounce (default 200ms).
- **`DripLifecycle`**: Context-free widget for managing `DripNode` lifecycles without `InheritedWidget`.
- **`DripScope.asWidget()`**: Helper method to bind a `DripScope`'s lifetime to the widget tree.
- **`DripReadableX`**: Ergonomic extension methods `asString()`, `map()`, and `where()` on `DripReadable<T>`.

### Deprecated
- `DripNodeProvider`, `context.node()`, `DripRouteNode`, `DripList`, and `DripListView` are deprecated to comply with the context-free paradigm and stability standards.

---

## 0.5.0-alpha (2026-05-16)

### Fixed — `drip_flutter`
- **`DripRenderParagraph` remount subscription bug** (CI-1.2): Split `unbindState()` into
  two methods — `detachBinding()` (preserves `_source` for remount) and `unbindState()`
  (full teardown on source swap or final disposal). Fixes missing `addListener` call when
  Flutter reuses the same `RenderObject` instance across unmount/remount cycles.
- **`flutter_test` two-pump contract**: `DripBatch` delivers notifications via
  `Future.microtask`, which drains *after* `flutter_test`'s build phase. Tests that write a
  reactive value and immediately assert a widget rebuild now use two `await tester.pump()`
  calls: the first drains the microtask and marks the element dirty; the second runs the
  frame that rebuilds the widget.

### Fixed — `drip_core`
- **Benchmark dead code**: removed the never-assigned `Timer? flushTimer` variable and the
  unreachable `?.cancel()` call from `scheduler_flood_benchmark.dart`.

---

## 0.3.0-alpha (2026-05-15)


### Added — Node System (`drip_flutter`)
- `DripNode`, `DripNodeProvider`, `DripRouteNode`, `DripList`, `DripListView`

### Changed
- All render widgets (`DripText`, `DripOpacity`, `DripColor`, `DripTransform`, `DripImage`) now accept `DripValue<T>` instead of `DripState<T>` — `DripComputed<T>` values can be passed directly without casting.
- `DripNodeProvider` builder context now correctly resolves its own `InheritedWidget`.

### Fixed
- `DripNodeProvider.of()` error message now contains the actual runtime type name.

---

## 0.1.1-alpha (2026-05-14)

### Added (`drip_core`)
- `DripValue<T>` — shared readable/subscribable interface for `DripState` and `DripComputed`.
- `DripListener` / `ListenerSubscriber` — public subscription API for cross-package use.

---

## 0.2.0-alpha (2026-05-13)

- `drip_flutter` initial release: `DripBinding`, `DripText`, `DripOpacity`, `DripColor`, `DripTransform`, `DripImage`, `DripFrame`, `DripFrameBuilder`.

---

## 0.1.0-alpha (2026-05-13)

- `drip_core` initial release: `DripState`, `DripComputed`, `DripEffect`, `DripScope`, `DripBatch`.
