# drip_core

[![pub package](https://img.shields.io/pub/v/drip_core.svg)](https://pub.dev/packages/drip_core)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**Direct Render Isolated Propagation** — A high-performance, pure Dart reactive engine designed to scale.

DRIP is the core state management engine that powers the DRIP framework. It provides atomic reactive primitives with **synchronous-only tracking** and **microtask-based coalescing**, enabling granular updates that can bypass the widget tree.

> ⚠️ **Early Alpha**: This package is in active development. APIs are subject to change until v1.0.0.

---

## ⚡ Performance
- **High Throughput**: Capable of `>10,000,000` writes/sec on modern hardware.
- **Efficient Invalidation**: Dependency tracking is `O(1)` per read; invalidation is `O(subscribers)`.
- **Zero Zones**: No `dart:async` Zone overhead for tracking.
- **Smart Batching**: Multiple synchronous writes result in exactly one propagation pass.

## 🛠 Core Primitives

| Primitive | Class | Purpose |
|---|---|---|
| **State** | `DripState<T>` | The source of truth. Holds a value and a version clock. |
| **Computed** | `DripComputed<T>` | Lazily evaluated, cached derivation. Only recomputes if sources change. |
| **Effect** | `DripEffect` | Automatic side-effect. Runs once and then re-runs on dependency changes. |
| **Scope** | `DripScope` | Resource owner. Disposes all registered states, computeds, and effects in LIFO order. |

---

## 📖 Usage

### Basic Counter
```dart
import 'package:drip_core/drip_core.dart';

void main() async {
  final count = dripState(0);
  
  // Effect runs immediately, then again whenever 'count' changes.
  DripEffect(() {
    print('Count changed: ${count.value}');
  });
  
  // Multiple writes are batched in the same microtask.
  count.write(1);
  count.write(2);
  count.write(3);
  
  // prints: "Count changed: 0" (initial)
  // prints: "Count changed: 3" (after microtask flush)
}
```

### Derived State (Computed)
Computeds are lazy and cached. They only execute their function if a dependency has changed since the last read.
```dart
final a = dripState(10);
final b = dripState(20);

final sum = DripComputed(() => a.value + b.value);

print(sum.value); // 30
a.write(15);
print(sum.value); // 35
```

### Resource Management (Scope)
Use `DripScope` to manage the lifetime of your reactive nodes.
```dart
final scope = DripScope(debugName: 'UserModule');

final name = scope.state('Alice');
scope.effect(() => print('Hello, ${name.value}'));

// Disposes all nodes created within this scope.
scope.dispose();
```

---

## 🏗 Key Architectural Invariants

1. **Synchronous-Only Tracking**: Dependencies are only tracked during the synchronous execution of a node. Asynchronous gaps (after an `await`) naturally stop tracking, preventing memory leaks and spurious dependencies common in Zone-based frameworks.
2. **Deterministic Propagation**: Update propagation follows a deterministic order based on the reactive graph.
3. **One Pass Per Frame**: Updates are batched into microtasks, ensuring that even complex graphs only trigger one propagation pass per synchronous execution block.
4. **LIFO Disposal**: Scopes dispose of their resources in the reverse order they were created, ensuring safe cleanup of dependent resources.

## 📦 Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  drip_core: ^0.1.0-alpha
```

---

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.
