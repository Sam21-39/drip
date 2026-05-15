# drip_core

[![pub package](https://img.shields.io/pub/v/drip_core.svg)](https://pub.dev/packages/drip_core)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**Direct Render Isolated Propagation** — A high-performance, pure Dart reactive engine.

DRIP Core is the zero-dependency state engine powering the DRIP framework. It provides atomic reactive primitives with **synchronous-only tracking** and **microtask-based coalescing**, giving the Flutter render layer the granularity needed to bypass the widget tree entirely.

> ⚠️ **Early Alpha**: APIs are stable within the alpha series but subject to change before v1.0.0.

---

## ⚡ Performance

- **High Throughput**: Capable of `>10,000,000` writes/sec on modern hardware.
- **O(1) Dependency Registration**: Tracking cost is constant per read.
- **O(n) Propagation**: Invalidation cost is proportional only to direct subscribers.
- **Zero Zones**: No `dart:async` Zone overhead for tracking.
- **Smart Batching**: Multiple synchronous writes coalesce into exactly one propagation pass.

---

## 🛠 Core Primitives

| Class | Role |
|---|---|
| `DripState<T>` | The source of truth. Holds a typed value and a version clock. |
| `DripComputed<T>` | Lazily evaluated, cached derivation. Recomputes only when dependencies change. |
| `DripAsync<T>` | Reactive async state container. Manages transitions between loading, data, and error states with concurrent call cancellation. |
| `DripAsyncValue<T>` | Sealed class (`DripLoading`, `DripData`, `DripError`) providing exhaustive state mapping and `previousData` preservation. |
| `DripEffect` | Automatic side-effect. Runs once on creation, re-runs on dependency change. |
| `DripScope` | Resource owner. Disposes registered nodes in LIFO order. |
| `DripReadable<T>` | Shared read/subscribe interface implemented by `DripState`, `DripComputed`, and `DripAsync`. |

---

## 📖 Usage

### Basic reactive state

```dart
import 'package:drip_core/drip_core.dart';

final count = dripState(0);

DripEffect(() {
  print('Count: ${count.value}');
});

// Multiple synchronous writes → one propagation pass
count.write(1);
count.write(2);
count.write(3);

// Output (after microtask flush):
// Count: 0  ← initial run
// Count: 3  ← single batched notification
```

### Derived state

```dart
final a = dripState(10);
final b = dripState(20);
final sum = DripComputed(() => a.value + b.value);

print(sum.value); // 30
a.write(15);
print(sum.value); // 35  — recomputed lazily on read
```

### Resource management

```dart
final scope = DripScope(debugName: 'UserModule');

final name = scope.state('Alice');
scope.effect(() => print('Hello, ${name.value}'));

scope.dispose(); // disposes name and the effect in LIFO order
```

### Accepting multiple sources via `DripReadable`

```dart
void display(DripReadable<String> source) {
  print(source.value);
}

final raw = dripState('hello');
final upper = DripComputed(() => raw.value.toUpperCase());
final asyncStr = DripAsync<String>()..setData('async data');

display(raw);      // ✅
display(upper);    // ✅
// Note: asyncStr.value is a DripAsyncValue<String>, so you'd normally map it first
```

---

## 🏗 Key Architectural Invariants

1. **Synchronous-Only Tracking**: Dependencies are only tracked during synchronous execution. Async gaps (after `await`) never register spurious dependencies.
2. **Deterministic Propagation**: Notification order follows the reactive graph.
3. **One Pass Per Frame**: Updates are batched into microtasks — complex graphs trigger exactly one propagation pass per sync block.
4. **LIFO Disposal**: Scopes dispose resources in reverse creation order, ensuring safe cleanup of dependent nodes.

---

## 📦 Installation

```yaml
dependencies:
  drip_core: ^0.2.0-alpha
```

---

## 📄 License

MIT — see [LICENSE](../../LICENSE).
