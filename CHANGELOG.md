## 0.3.0-alpha (2026-05-15)

### Added — Node System (`drip_flutter`)
- `DripNode`, `DripNodeProvider`, `DripRouteNode`, `DripList`, `DripListView`

### Changed
- All render widgets (`DripText`, `DripOpacity`, `DripColor`, `DripTransform`, `DripImage`) now accept `DripValue<T>` instead of `DripState<T>` — `DripComputed<T>` values can be passed directly without casting.
- `DripNodeProvider` builder context now correctly resolves its own `InheritedWidget`.

### Fixed
- `DripNodeProvider.of()` error message now contains the actual runtime type name.

---

## 0.1.1-alpha (2026-05-14)

### Added (`drip_core`)
- `DripValue<T>` — shared readable/subscribable interface for `DripState` and `DripComputed`.
- `DripListener` / `ListenerSubscriber` — public subscription API for cross-package use.

---

## 0.2.0-alpha (2026-05-13)

- `drip_flutter` initial release: `DripBinding`, `DripText`, `DripOpacity`, `DripColor`, `DripTransform`, `DripImage`, `DripFrame`, `DripFrameBuilder`.

---

## 0.1.0-alpha (2026-05-13)

- `drip_core` initial release: `DripState`, `DripComputed`, `DripEffect`, `DripScope`, `DripBatch`.
