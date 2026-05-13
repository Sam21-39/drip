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
