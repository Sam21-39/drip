# DRIP — Direct Render Isolated Propagation

> "State that drips to the metal."

[![CI](https://github.com/Sam21-39/drip/actions/workflows/ci.yml/badge.svg)](https://github.com/Sam21-39/drip/actions/workflows/ci.yml)
[![drip_core](https://img.shields.io/pub/v/drip_core?label=drip_core)](https://pub.dev/packages/drip_core)
[![drip_flutter](https://img.shields.io/pub/v/drip_flutter?label=drip_flutter)](https://pub.dev/packages/drip_flutter)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Sub-widget reactive state for Flutter. State changes propagate directly to `RenderObject` property setters — zero widget rebuilds, zero `setState()`.

---

## Packages

| Package | Version | Status | Description |
|---|---|---|---|
| [`drip_core`](packages/drip_core) | `1.0.0` | [![drip_core](https://img.shields.io/pub/v/drip_core?label=pub.dev)](https://pub.dev/packages/drip_core) | Pure Dart reactive engine — `DripState`, `DripComputed`, `DripEffect`, `DripScope`, `DripTrace` |
| [`drip_flutter`](packages/drip_flutter) | `0.7.0-alpha` | [![drip_flutter](https://img.shields.io/pub/v/drip_flutter?label=pub.dev)](https://pub.dev/packages/drip_flutter) | Flutter render layer — `DripText`, `DripOpacity`, `DripLifecycle`, `DripSemantics`, `DripItems`, `DripItemBuilder` |
| `drip_gen` | planned | Planned | Code generator + CLI |
| `drip_native` | planned | Planned | FFI shared memory native bridge |

## Architecture

```
State.write() → DripBatch (microtask) → DripBinding → RenderObject.markNeedsPaint() → paint
                                            ↑
                                  zero Widget.build() calls
```

No widget tree traversal. No diffing. No `setState()`.

See [ARCHITECTURE.md](docs/ARCHITECTURE.md) for the 7 invariants that govern every line of code.

---

## Quick Start

### 1. Reactive primitives (`drip_core`)

```dart
import 'package:drip_core/drip_core.dart';

final count = dripState(0);
final doubled = DripComputed(() => count.value * 2);

DripEffect(() => print('count: ${count.value}, doubled: ${doubled.value}'));

count.write(5);
// → prints: "count: 5, doubled: 10"
```

### 2. Zero-rebuild UI (`drip_flutter`)

```dart
import 'package:drip_flutter/drip_flutter.dart';

final label = dripState('Hello');

// In build() — no setState ever needed:
DripText(label, style: TextStyle(fontSize: 24))

// Anywhere else:
label.write('World'); // Updates RenderParagraph directly. 0 widget builds.
```

### 3. Business logic modules (`DripNode`)

```dart
class CounterNode extends DripNode {
  late final DripState<int> count;
  late final DripComputed<String> displayText;

  @override
  void onInit() {
    count = state(0);
    displayText = computed(() => count.value.toString());
  }
}

// In your widget tree (Context-Free Injection):
DripLifecycle<CounterNode>(
  create: () => CounterNode(),
  builder: (node) => DripText(node.displayText),
)
```

### 4. Diagnostic Tooling (`DripTrace`)

```dart
// Enable synchronous stack trace capturing for state mutations
DripTrace.enabled = true;

final count = dripState(0, debugName: 'counter');
// If an effect fails, the stack trace will chain back to the exact write call.
```


---

## Migration

Upgrading from an older version of DRIP? Please read [MIGRATION.md](MIGRATION.md) for step-by-step instructions on replacing deprecated provider, route-node, and list APIs with `DripLifecycle`, `DripItems`, and `DripItemBuilder`.

---

## Development Status

| Version | Status | Description |
|---|---|---|
| `v0.1.1-alpha` | ✅ Released | Reactive engine — `DripState`, `DripComputed`, `DripEffect`, `DripScope` |
| `v0.2.0-alpha` | ✅ Released | Flutter render layer — `DripText`, `DripOpacity`, `DripColor`, `DripTransform`, `DripImage` |
| `v0.3.0-alpha` | ✅ Released | Node architecture — `DripNode`, `DripNodeProvider`, `DripRouteNode`, `DripList`, `DripListView` |
| `v0.4.0-alpha` | ✅ Released | Async layer — `DripAsync`, `DripAsyncValue`, `DripAsyncBuilder`, `DripSelect`, `DripAsyncNode` |
| `v0.5.1-alpha` | ✅ Released | Phase 5: Stability — Diagnostic tracing, Semantics bridge, Lifecycle widgets, Context-free enforcement |
| `drip_core 1.0.0` | ✅ Ready | Stable core API, coverage gate, benchmark regression checks |
| `drip_flutter 0.6.0-alpha` | ✅ Ready | Deprecated provider, route-node, and list APIs removed |
| `drip_flutter 0.7.0-alpha` | ✅ Ready | Flutter API freeze for the pre-1.0 line |
| `drip_flutter 1.0.0` | Planned | DevTools extension, migration guides, stress testing |

---

## Setup (contributors)

**Prerequisites:** [Melos](https://melos.invertase.dev/)

```bash
# Install Melos
dart pub global activate melos

# Link all local packages
dart pub global run melos bootstrap
```

### Common commands

```bash
# Run all tests
dart pub global run melos test

# Static analysis (zero-tolerance)
dart pub global run melos analyze

# Format
dart pub global run melos format

# Publish dry-run
dart pub global run melos publish:dry
```

Or use the short aliases if `melos` is on your PATH:

```bash
melos bootstrap && melos run analyze && melos run test
```

---

## License

[MIT](LICENSE) © 2026 DRIP Contributors
