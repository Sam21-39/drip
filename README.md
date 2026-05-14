# DRIP — Direct Render Isolated Propagation

> "State that drips to the metal."

[![CI](https://github.com/Sam21-39/drip/actions/workflows/ci.yml/badge.svg)](https://github.com/Sam21-39/drip/actions/workflows/ci.yml)
[![drip_core](https://img.shields.io/pub/v/drip_core?label=drip_core)](https://pub.dev/packages/drip_core)
[![drip_flutter](https://img.shields.io/pub/v/drip_flutter?label=drip_flutter)](https://pub.dev/packages/drip_flutter)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Sub-widget reactive state for Flutter. State changes propagate directly to `RenderObject` property setters — zero widget rebuilds, zero `setState()`.

---

## Packages

| Package | Version | Description |
|---|---|---|
| [`drip_core`](packages/drip_core) | `0.1.1-alpha` | Pure Dart reactive engine — `DripState`, `DripComputed`, `DripEffect`, `DripScope` |
| [`drip_flutter`](packages/drip_flutter) | `0.3.0-alpha` | Flutter render layer — `DripText`, `DripOpacity`, `DripNode`, `DripList` |
| `drip_core_native` | planned | FFI shared memory native bridge |
| `drip_gen` | planned | Code generator + CLI |

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

// In your widget tree:
DripNodeProvider<CounterNode>(
  create: () => CounterNode(),
  builder: (context, node) => DripText(node.displayText),
)
```

---

## Development Status

| Version | Status | Description |
|---|---|---|
| `v0.1.1-alpha` | ✅ Released | Reactive engine — `DripState`, `DripComputed`, `DripEffect`, `DripScope` |
| `v0.2.0-alpha` | ✅ Released | Flutter render layer — `DripText`, `DripOpacity`, `DripColor`, `DripTransform`, `DripImage` |
| `v0.3.0-alpha` | ✅ Released | Node architecture — `DripNode`, `DripNodeProvider`, `DripRouteNode`, `DripList`, `DripListView` |
| `v0.4.0-alpha` | 🔜 Next | Native bridge — FFI shared memory (Android + iOS) |
| `v0.5.0-beta` | Planned | Code generation + CLI |
| `v0.6.0-beta` | Planned | Router integration + DevTools |
| `v1.0.0` | Planned | Stable |

---

## Setup (contributors)

**Prerequisites:** [FVM](https://fvm.app/) + [Melos](https://melos.invertase.dev/)

```bash
# Install FVM if not already installed
dart pub global activate fvm

# Use the pinned Flutter version for this repo
fvm install  # reads from .fvmrc → 3.27.0

# Activate Melos via the FVM-pinned Dart
fvm dart pub global activate melos

# Link all local packages
fvm dart pub global run melos bootstrap
```

### Common commands

```bash
# Run all tests
fvm dart pub global run melos test

# Static analysis (zero-tolerance)
fvm dart pub global run melos analyze

# Format
fvm dart pub global run melos format

# Publish dry-run
fvm dart pub global run melos publish:dry
```

Or use the short aliases if `melos` is on your PATH:

```bash
melos bootstrap && melos run analyze && melos run test
```

---

## License

[MIT](LICENSE) © 2026 DRIP Contributors
