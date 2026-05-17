# DRIP Migration Guide (0.5.x -> 0.6.0)

This guide documents the deprecation of legacy reactive abstractions in DRIP `0.5.1-alpha` and details the migration path to their modern, high-performance replacements.

All deprecated symbols will be permanently removed in the upcoming **`0.6.0-alpha`** release.

---

## 1. Node Management: `DripNodeProvider` -> `DripLifecycle`

### Why the Change?
`DripNodeProvider` relied on Flutter's `InheritedWidget` system to propagate node instances implicitly down the widget tree, forcing widgets to dynamically resolve dependencies via `BuildContext` lookups (e.g. `context.node<MyNode>()`). This approach:
- Couples business logic modules directly to Flutter's element tree hierarchy.
- Can fail at runtime if a widget attempts lookup above the provider.
- Introduces unnecessary widget rebuild layers and context nesting.

`DripLifecycle` provides a type-safe, context-free management pattern. The node is explicitly instantiated and passed directly as a callback argument, allowing descendant widgets to receive dependencies explicitly (via constructors) or bind selectively.

### Migration Path

#### Legacy Pattern (`DripNodeProvider`)
```dart
// Legacy: Implicit BuildContext lookups
class LegacyScreen extends StatelessWidget {
  const LegacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DripNodeProvider<CounterNode>(
      create: () => CounterNode(),
      builder: (context) {
        // Must resolve dynamically via context lookup
        final node = context.node<CounterNode>();
        return DripBuilder<int>(
          source: node.counter,
          builder: (context, val) => Text('$val'),
        );
      },
    );
  }
}
```

#### Modern Pattern (`DripLifecycle`)
```dart
// Modern: Explicit compile-time type-safe references
class ModernScreen extends StatelessWidget {
  const ModernScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DripLifecycle<CounterNode>(
      create: () => CounterNode(),
      builder: (node) {
        // Node instance is passed explicitly. Completely context-free!
        return DripBuilder<int>(
          source: node.counter,
          builder: (context, val) => Text('$val'),
        );
      },
    );
  }
}
```

---

## 2. Scoped Lifecycles: `DripRouteNode` -> `DripLifecycle` + Route Observer

### Why the Change?
`DripRouteNode` was a specialized subclass of `DripNode` that attempted to hook directly into Flutter's routing system to trigger custom entry and exit events (`onRouteEnter`, `onRouteLeave`). This coupled the core reactive node directly to the Flutter navigation stack.

The modern way is to combine `DripLifecycle` with regular Flutter route observers, or listen to route transitions in the presentation layer and invoke node actions explicitly, keeping business logic pure and fully unit-testable outside of Flutter.

### Migration Path
Instantiate a pure `DripNode` using `DripLifecycle` and trigger lifecycle actions explicitly in response to navigation events, or subclass `WidgetsBindingObserver`/`RouteObserver` at the widget level.

---

## 3. Collections: `DripList` & `DripListView` -> `DripItems` & `DripItemBuilder`

### Why the Change?
`DripList` and `DripListView` provided reactive list capabilities, but did not cleanly isolate index-granular value writes from list-level structural mutations.

`DripItems<T>` and `DripItemBuilder` completely separate these concerns:
- **`DripItems<T>`**: Represents a multi-tier list of `DripState<T>` elements. Mutating an element at an index (e.g. `items[index] = newValue`) triggers propagation *only* to the subscriber of that index, completely bypassing list-level listeners. Structural mutations (e.g. `add`, `removeAt`) schedule a full list-level update.
- **`DripItemBuilder`**: A high-performance builder that binds to a specific index. In `renderMode: true` (for string items), it bypasses widget rebuilds entirely, binding updates directly to the underlying `RenderParagraph` via `DripText` for maximum performance.

### Migration Guide

#### Legacy Pattern (`DripList` & `DripListView`)
```dart
// Legacy: List-state and list-view
final legacyList = DripList<String>(['A', 'B', 'C']);

DripListView<String>(
  list: legacyList,
  itemBuilder: (context, index, value) {
    return ListTile(title: Text(value));
  },
);
```

#### Modern Pattern (`DripItems` & `DripItemBuilder`)
```dart
// Modern: DripItems collection state and DripItemBuilder list item builder
final items = DripItems<String>(['A', 'B', 'C']);

ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return DripItemBuilder<String>(
      items: items,
      index: index,
      builder: (context, itemState) {
        return DripBuilder<String>(
          source: itemState,
          builder: (context, value) => ListTile(title: Text(value)),
        );
      },
    );
  },
);
```

For ultra-high performance where the list items are purely text strings, use `renderMode: true` to bypass widget builds completely:
```dart
DripItemBuilder<String>(
  items: items,
  index: index,
  renderMode: true, // Rebuild-free text rendering directly on the render paragraph!
)
```
