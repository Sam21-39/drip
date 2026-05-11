# DRIP — Direct Render Isolated Propagation

> "State that drips to the metal."

Sub-widget reactive state for Flutter. State changes propagate directly to `RenderObject` property setters — zero widget rebuilds, zero `setState()`.

## Packages

| Package | Version | Description |
|---|---|---|
| [`drip_core`](packages/drip_core) | [![pub](https://img.shields.io/pub/v/drip_core)](https://pub.dev/packages/drip_core) | Pure Dart reactive engine |
| `drip_core_flutter` | coming soon | Direct RenderObject bindings |
| `drip_core_native` | coming soon | FFI shared memory native bridge |
| `drip_gen` | coming soon | Code generator |
| `drip_test` | coming soon | Test utilities |

## Architecture

```
State change → DripBinding → RenderObject.markNeedsPaint() → paint
```

No widget tree traversal. No diffing. No `setState()`.

See [ARCHITECTURE.md](docs/ARCHITECTURE.md) for the invariants that govern every line of code in this repo.

## Development Status

- [x] v0.0.1 — Name placeholder published
- [ ] v0.1.0-alpha — Reactive engine (DripState, DripComputed, DripEffect, DripScope, DripBatch)
- [ ] v0.2.0-alpha — Direct render bindings (DripText, DripOpacity, DripColor, DripTransform)
- [ ] v0.3.0-alpha — DripNode, DripList, scoped DI
- [ ] v0.4.0-alpha — Native bridge (Android)
- [ ] v0.4.1-alpha — Native bridge (iOS)
- [ ] v0.5.0-beta — Full codegen + CLI
- [ ] v0.6.0-beta — Router + DevTools
- [ ] v1.0.0 — Stable

## Setup (contributors)

```bash
fvm dart pub global activate melos
fvm dart pub global run melos bootstrap
fvm dart pub global run melos test
```
