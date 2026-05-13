# drip_flutter

Flutter render layer for the DRIP framework.

Provides direct `RenderObject` bindings that update the UI with **zero widget rebuilds**, bypassing the standard Flutter `build()` cycle for state-driven property updates.

## Features

- **Direct Binding**: Connect `DripState<T>` directly to `RenderObject` properties.
- **Zero Rebuilds**: High-performance UI updates that skip the Widget → Element → RenderObject traversal.
- **Precision Rendering**: Optimized for high-frequency updates (e.g., animations, grids, live data).

## Usage

```dart
final label = dripState('Hello');

// In build():
DripText(label, style: TextStyle(fontSize: 24));

// Elsewhere:
label.write('World'); // Updates RenderParagraph directly, NO build() calls.
```

## Architecture Invariants

`drip_flutter` adheres to the following core invariants:

1. **Invariant 2: Zero `setState()`**: No `setState()` calls are used in the binding path.
2. **Invariant 7: Binding Lifecycle**: All bindings are synchronously deregistered when the widget is unmounted.

## Benchmarking

To verify the zero-rebuild guarantee, run the `apps/demo_grid` application:

1.  Run the app in profile mode: `flutter run --profile`
2.  Open **Flutter DevTools** → **Performance** tab.
3.  Enable **"Track widget builds"**.
4.  Observe: The 1000 `DripText` cells update every 16ms, but the "Widget build events" count remains static.

---

*Part of the DRIP Framework.*
