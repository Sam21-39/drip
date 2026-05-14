## 0.3.0-alpha

### Added

**Node System**
- `DripNode` — abstract feature module with owned `DripScope`. Extend to create
  a named, scoped business logic unit. All state, computed values, and effects
  are automatically disposed when the node is disposed.
- `DripNode.register<T>` / `DripNode.resolve<T>` — scoped dependency injection.
  Singleton by default; no global service locators.
- `DripNode` lifecycle: `onInit`, `onDispose`, `onBackground`, `onForeground`
- `DripNodeProvider<N>` — `StatefulWidget` + `InheritedWidget` that creates a node
  on mount and disposes it on unmount. Handles app lifecycle events automatically.
- `DripRouteNode` — `DripNode` subclass with route-lifecycle hooks: `onRouteEnter`,
  `onRouteLeave`. Integrates with Flutter's `RouteObserver`.
- `BuildContext.node<N>()` extension — ergonomic node lookup

**List System**
- `DripList<T>` — reactive list with item-level subscriber granularity. Updating
  index `i` notifies only the subscriber for index `i`, not the entire list.
- `DripListView<T>` — list widget that rebuilds only the tile at the changed index.
  Structural changes (add/remove) trigger a minimal list-level rebuild.

### Architecture
- `DripNode` is pure Dart — unit-testable without a Flutter widget tree
- No global registries: node resolution via `InheritedWidget` tree lookup only
- `DripList` item-level granularity proven: 10,000-item list, 1 item change = 1 tile rebuild

## 0.2.0-alpha (2026-05-13)

**First release of `drip_flutter` — the Flutter direct render binding layer.**

### Added
- `DripBinding<T>` — live RenderObject subscriber: applies state changes directly to render properties, bypassing the widget/element rebuild cycle.
- `DripText` — zero-rebuild text widget binding `DripState<String>` to `RenderParagraph.text` via `markNeedsLayout()`.
- `DripOpacity` — zero-rebuild opacity widget binding `DripState<double>` to opacity via `markNeedsPaint()`; clamps to `[0.0, 1.0]`.
- `DripColor` — zero-rebuild background color widget binding `DripState<Color>` via `markNeedsPaint()`.
- `DripTransform` — zero-rebuild matrix transform widget binding `DripState<Matrix4>` via `markNeedsPaint()`.
- `DripImage` — ImageProvider binding with async image resolution.
- `DripCustomBinding<T>` — abstract base class for custom RenderObject bindings.
- `DripFrame<T>` — structural state boundary (controlled rebuild trigger).
- `DripFrameBuilder<T>` — StatefulWidget that rebuilds when `DripFrame` updates.

### Performance
- Verified: 1000 simultaneous `DripState` writes → 0 widget `build()` calls.
- Demo app `demo_grid`: 1000-cell live grid, zero rebuilds at 60fps.

### Architecture
- Invariant 2 enforced: zero `setState()` calls in binding code path.
- Invariant 7 enforced: all bindings deregistered in `didUnmountRenderObject`.
- `DripFrame` is the only intentional `setState()` path, documented explicitly.
