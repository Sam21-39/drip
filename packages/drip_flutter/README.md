# drip_flutter

[![pub package](https://img.shields.io/pub/v/drip_flutter.svg)](https://pub.dev/packages/drip_flutter)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Flutter render layer for the DRIP framework.

Provides direct `RenderObject` bindings that update the UI with **zero widget rebuilds**, a scoped business-logic architecture via **`DripNode`**, and a high-performance reactive list via **`DripList`**.

> ⚠️ **Early Alpha**: APIs are stable within the alpha series but subject to change before v1.0.0.

---

## Features

- **Zero Rebuilds** — State changes call `markNeedsPaint()` / `markNeedsLayout()` directly on `RenderObject`s, bypassing the Widget → Element → RenderObject traversal entirely.
- **Reactive Builder Widgets** — Scoped, optimized builders (`DripBuilder`, `DripSelect`, `DripAsyncBuilder`) for complex UI updates when rebuilding widgets is necessary.
- **`DripReadable<T>` binding** — All render widgets accept both `DripState<T>` and `DripComputed<T>` via the shared `DripReadable<T>` interface.
- **`DripLifecycle` & `DripNode`** — Explicit, context-free management of business logic modules. No `InheritedWidget` magic.
- **`DripSemantics`** — Full accessibility support with zero-rebuild reactivity.

---

## Render Widgets

| Widget | Bound Property | RenderObject call |
|---|---|---|
| `DripText` | `DripValue<String>` | `markNeedsLayout()` |
| `DripOpacity` | `DripValue<double>` | `markNeedsPaint()` |
| `DripColor` | `DripValue<Color>` | `markNeedsPaint()` |
| `DripTransform` | `DripValue<Matrix4>` | `markNeedsPaint()` |
| `DripImage` | `DripValue<ImageProvider>` | async image resolution |
| `DripCustomBinding<T>` | any | developer-defined |

## Builder Widgets

When you need to rebuild a subtree conditionally or construct new widgets, use DRIP's reactive builders:

| Widget | Purpose |
|---|---|
| `DripBuilder<T>` | Rebuilds its subtree whenever the bound `DripReadable<T>` changes. |
| `DripSelect` | Combines multiple sources via an internal `DripComputed` and rebuilds only when the evaluated combination changes. |
| `DripAsyncBuilder<T>`| Handles exhaustive sealed-class state rendering for `DripAsync<T>` (`loading`, `data`, `error`), automatically passing `previousData` to handlers. |

---

## Usage

### 1. Zero-rebuild UI

```dart
import 'package:drip_flutter/drip_flutter.dart';

final label = dripState('Hello');
final opacity = DripComputed(() => label.value.isEmpty ? 0.0 : 1.0);

// In build() — no setState ever:
Column(children: [
  DripText(label, style: TextStyle(fontSize: 24)),
  DripOpacity(opacity: opacity, child: Text('visible!')),
])

// Anywhere in business logic:
label.write('World'); // → 0 widget builds
```

### 2. Business logic with `DripNode`

```dart
class CounterNode extends DripNode {
  late final DripState<int> count;
  late final DripComputed<String> displayText;
  late final DripComputed<double> opacity;

  @override
  void onInit() {
    count = state(0);
    displayText = computed(() => count.value.toString());
    opacity = computed(() => count.value == 0 ? 0.4 : 1.0);
  }

  void increment() => count.write(count.value + 1);
  void decrement() => count.write(count.value - 1);
}
```

Provide and consume (Context-Free):

```dart
// Explicit dependency injection via constructor
DripLifecycle<CounterNode>(
  create: () => CounterNode(),
  child: DripBuilder<CounterNode>(
    builder: (context, node) => Column(children: [
      DripText(node.displayText),
      DripOpacity(opacity: node.opacity, child: ElevatedButton(
        onPressed: node.increment,
        child: Icon(Icons.add),
      )),
    ]),
  ),
)
```

### 3. Accessibility with `DripSemantics`

```dart
DripSemantics<int>(
  value: node.count,
  label: (value) => "Current count is $value",
  child: DripText(node.displayText),
)
```


### 4. Reactive Lists

For lists, use standard `ListView.builder` combined with `DripBuilder` for item-level granularity, or use the legacy `DripList` (deprecated) for O(1) tile updates.


---

## Architecture Invariants

1. **Zero `setState()`**: No `setState()` calls exist in the binding code path. `DripFrame` is the sole intentional exception, explicitly documented.
2. **Binding Lifecycle**: All bindings are synchronously deregistered in `didUnmountRenderObject` — zero subscriber leaks.
3. **Context Correctness**: `DripNodeProvider` wraps the builder child in a `Builder`, ensuring `context.node<N>()` resolves from a context below the `InheritedWidget`.

---

## Benchmarking

Run the `demo_grid` app in profile mode to observe the zero-rebuild guarantee:

```bash
cd apps/demo_grid
flutter run --profile
```

Open **Flutter DevTools → Performance → Track Widget Builds**: 1,000 `DripText` cells update every 16 ms — widget build count stays at **0**.

---

## Installation

```yaml
dependencies:
  drip_flutter: ^0.5.1-alpha
```

Requires Flutter `>=3.27.0`.

---

*Part of the [DRIP Framework](https://github.com/Sam21-39/drip).*
