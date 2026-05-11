# drip_core

**Direct Render Isolated Propagation** — sub-widget reactive state for Flutter.

> "State that drips to the metal."

This package is the pure Dart reactive engine. Zero Flutter dependency — usable in Dart CLI and server applications.

## Status

`v0.0.1` — Name placeholder. Active development in progress.

`v0.1.0-alpha` (reactive engine) coming soon.

## Packages

| Package | pub.dev | Purpose |
|---|---|---|
| `drip_core` | [![pub](https://img.shields.io/pub/v/drip_core)](https://pub.dev/packages/drip_core) | Pure Dart reactive engine |
| `drip_core_flutter` | coming soon | Direct RenderObject bindings |
| `drip_core_native` | coming soon | FFI shared memory native bridge |
| `drip_gen` | coming soon | Code generator |
| `drip_test` | coming soon | Test utilities |

## Why DRIP?

Other frameworks flood the widget tree:
```
State change → rebuild widget tree → diff → paint
```

DRIP delivers state directly to RenderObjects:
```
State change → drip to RenderObject → paint
```

Zero widget rebuilds. Zero setState(). Architecture-enforced precision.

## Links

- [GitHub](https://github.com/Sam21-39/drip)
- [Architecture Contract](https://github.com/Sam21-39/drip/blob/main/docs/ARCHITECTURE.md)
