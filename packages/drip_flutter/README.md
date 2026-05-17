# drip_flutter

[![pub package](https://img.shields.io/pub/v/drip_flutter.svg)](https://pub.dev/packages/drip_flutter)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Flutter render layer for the DRIP framework.

Provides direct `RenderObject` bindings that update the UI with **zero widget rebuilds**, optional scoped business-logic helpers via **`DripNode`**, and high-performance granular reactive lists via **`DripItems`** and **`DripItemBuilder`**.

> **API frozen for alpha**: `0.7.0-alpha` is the frozen pre-1.0 Flutter surface. Removals now require a documented deprecation cycle.

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
| `DripText` | `DripReadable<String>` | `markNeedsLayout()` |
| `DripOpacity` | `DripReadable<double>` | `markNeedsPaint()` |
| `DripColor` | `DripReadable<Color>` | `markNeedsPaint()` |
| `DripTransform` | `DripReadable<Matrix4>` | `markNeedsPaint()` |
| `DripImage` | `DripReadable<ImageProvider>` | async image resolution |
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
  builder: (node) => Column(children: [
      DripText(node.displayText),
      DripOpacity(opacity: node.opacity, child: ElevatedButton(
        onPressed: node.increment,
        child: Icon(Icons.add),
      )),
    ]),
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

For highly-granular reactive collections, use `DripItems<T>` in combination with `DripItemBuilder<T>`. This ensures that individual element updates do not trigger a full list rebuild, keeping element-level updates isolated and performant:

```dart
final items = DripItems<String>(['item A', 'item B']);

// In build():
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return DripItemBuilder<String>(
      items: items,
      index: index,
      builder: (context, value) => ListTile(title: Text(value)),
    );
  },
);

// Writing to an element updates ONLY that specific index tile — zero list-level rebuilds:
items[0].write('Updated Item A');
```


---

## Architecture Invariants

1. **Zero `setState()`**: No `setState()` calls exist in the binding code path. `DripFrame` is the sole intentional exception, explicitly documented.
2. **Binding Lifecycle**: All bindings are synchronously deregistered in `didUnmountRenderObject` — zero subscriber leaks.
3. **Context-Free Lifecycle**: `DripLifecycle` creates nodes in `initState`, passes them explicitly through its builder, and disposes them in `dispose`.

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
  drip_flutter: ^0.7.0-alpha
```

Requires Flutter `>=3.10.0` and `drip_core ^1.0.0`.

---

*Part of the [DRIP Framework](https://github.com/Sam21-39/drip).*
