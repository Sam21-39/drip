# drip_core

[![pub package](https://img.shields.io/pub/v/drip_core.svg)](https://pub.dev/packages/drip_core)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Direct Render Isolated Propagation — a pure Dart reactive engine that serves as the foundation for the DRIP framework.

> ⚠️ **Early Alpha**: This package is in early development. APIs are subject to change until v1.0.0.

## What is drip_core?

DRIP solves the problem of granular reactivity in Flutter. While traditional state management often relies on `setState()` or complex `ChangeNotifier` trees that trigger broad widget rebuilds, DRIP provides a way to propagate state changes directly to the render layer, bypassing the widget tree entirely for most updates.

This package, `drip_core`, is the pure Dart engine behind that vision. It provides the atomic primitives for state tracking, dependency management, and batched updates without any dependency on the Flutter SDK. This makes it suitable for CLI tools, server-side Dart, and as a robust foundation for the upcoming `drip_flutter` render bindings.

## Quick Start

### Basic Counter
```dart
import 'package:drip_core/drip_core.dart';

void main() async {
  final count = dripState(0);
  
  // Create an effect that runs whenever count changes
  DripEffect(() => print('Count: ${count.value}'));
  
  count.write(1);
  count.write(2);
  
  // Wait for the microtask flush
  await Future.microtask(() {}); // Prints: Count: 2
}
```

### Computed Values
```dart
final count = dripState(5);
final doubled = DripComputed(() => count.value * 2);

print(doubled.value); // 10
count.write(10);
print(doubled.value); // 20 (lazily computed)
```

### Scoped Lifetimes
```dart
final scope = DripScope(debugName: 'feature-scope');
final state = scope.state(0);

scope.effect(() {
  print('Value: ${state.value}');
});

// Clean up everything in the scope
scope.dispose();
```

## Core Concepts

| Concept | Class | Description |
|---|---|---|
| **State** | `DripState<T>` | Atomic reactive value with version clock. |
| **Computed** | `DripComputed<T>` | Lazy, cached derived value with auto-tracking. |
| **Effect** | `DripEffect` | Side-effect that re-runs on dependency change. |
| **Scope** | `DripScope` | Lifetime owner with LIFO disposal. |
| **Batch** | `DripBatch` | Microtask-based update coalescing. |

## Why not Zone-based tracking?

Most reactive frameworks in Dart use `Zone`s to track asynchronous dependencies. While convenient, this often leads to "leakage" where state reads after an `await` point accidentally register as dependencies, causing memory leaks or redundant computations.

DRIP uses a stack-based `TrackingContext`. Because dependency tracking is strictly synchronous, any code after an `await` gap naturally stops tracking. This makes your reactive graph predictable, easier to debug, and significantly more performant.

## Roadmap

See [ROADMAP_OVERVIEW.md](../../docs/ROADMAP_OVERVIEW.md) for the full project plan.

## License

MIT
