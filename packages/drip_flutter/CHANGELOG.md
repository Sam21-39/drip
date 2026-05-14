## Unreleased

---

## 0.3.0-alpha (2026-05-15)

### Added — Node System
- `DripNode` — abstract feature module with an owned `DripScope`. Extend to create a named, scoped business-logic unit. All state, computed values, and effects are automatically disposed when the node is disposed.
- `DripNode.register<T>` / `DripNode.resolve<T>` — scoped dependency injection. Singleton by default; no global service locators.
- `DripNode` lifecycle: `onInit`, `onDispose`, `onBackground`, `onForeground`.
- `DripNodeProvider<N>` — `StatefulWidget` + `InheritedWidget` that creates a node on mount, forwards app-lifecycle events, and disposes it on unmount. Uses a `Builder` child to ensure the context passed to `builder` sits below the `InheritedWidget` so `context.node<N>()` resolves correctly.
- `DripRouteNode` — `DripNode` subclass with route-lifecycle hooks (`onRouteEnter`, `onRouteLeave`). Integrates with Flutter's `RouteObserver`.
- `BuildContext.node<N>()` / `BuildContext.maybeNode<N>()` — ergonomic node lookup extensions.

### Added — List System
- `DripList<T>` — reactive list with item-level subscriber granularity. Updating index `i` notifies only the subscriber registered for index `i`.
- `DripListView<T>` — list widget that rebuilds only the tile at the changed index. Structural changes (add/remove) trigger a minimal list-level rebuild.

### Fixed
- `DripNodeProvider.of()` now injects the actual runtime type name `$N` in the missing-provider error message (was `$N` as a literal string due to escaped interpolation).
- `DripNodeProvider.builder` context now correctly resolves its own `InheritedWidget` by wrapping the child in a `Builder`.

### Architecture
- `DripValue<T>` interface introduced in `drip_core` — shared readable/subscribable contract implemented by both `DripState<T>` and `DripComputed<T>`. All Flutter render widgets now accept `DripValue<T>`, allowing computed values to be passed directly without casting.
- `DripListener` / `ListenerSubscriber` moved to `drip_state_base.dart` to be accessible package-wide without importing implementation files.
- `DripNode` is pure Dart — fully unit-testable without a Flutter widget tree.

### Testing (drip_flutter)
- `drip_node_test.dart` — 20+ tests covering `DripNode` lifecycle, `register`/`resolve`, effects, and disposal.
- `drip_node_provider_test.dart` — 8 tests covering mount/unmount, lifecycle forwarding, `Provider.of`, `context.node`, error messages, and nested providers.
- `drip_route_node_test.dart` — route lifecycle integration tests.
- `drip_list_test.dart` — 10 tests covering `add`, `removeAt`, `[]=`, `insert`, `replaceAll`, `update`, `dispose`.
- `drip_list_view_test.dart` — 8 tests including a 10,000-item single-tile-rebuild benchmark.

---

## 0.2.0-alpha (2026-05-13)

**First release of `drip_flutter` — the Flutter direct render binding layer.**

### Added
- `DripBinding<T>` — live `RenderObject` subscriber. Applies state changes directly to render properties, bypassing the widget/element rebuild cycle.
- `DripText` — zero-rebuild text widget. Binds `DripValue<String>` to `RenderParagraph.text` via `markNeedsLayout()`.
- `DripOpacity` — zero-rebuild opacity widget. Binds `DripValue<double>` (clamped `[0.0, 1.0]`) via `markNeedsPaint()`.
- `DripColor` — zero-rebuild background color binding via `markNeedsPaint()`.
- `DripTransform` — zero-rebuild `Matrix4` transform binding via `markNeedsPaint()`.
- `DripImage` — `ImageProvider` binding with async image resolution.
- `DripCustomBinding<T>` — abstract base class for custom `RenderObject` bindings.
- `DripFrame<T>` / `DripFrameBuilder<T>` — controlled rebuild boundary for deliberate structural updates.

### Performance
- Verified: 1,000 simultaneous `DripState` writes → **0 widget `build()` calls**.
- Demo app `demo_grid`: 1,000-cell live grid at 60 fps, zero rebuilds.

### Architecture
- Invariant 2 enforced: zero `setState()` calls in binding code path.
- Invariant 7 enforced: all bindings deregistered in `didUnmountRenderObject`.
