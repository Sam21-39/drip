# demo_grid

A Flutter demo app proving DRIP's zero-rebuild rendering.

## What it shows

A 40×25 grid of **1,000 cells**. Every cell is a `DripText` widget bound to an
independent `DripState<String>`. A periodic `Timer` fires every 16 ms and writes
a new value to all 1,000 states. `DripBatch` coalesces all 1,000 writes into a
single microtask flush, and each `DripText` updates its `RenderParagraph` directly
via `markNeedsLayout()`.

**Flutter DevTools Timeline shows zero widget build events during the update cycle.**

## How to verify the benchmark

### 1. Run in profile mode

```bash
flutter run --profile
```

### 2. Open DevTools

In the terminal, press `d` to open DevTools (or navigate to the printed URL).

### 3. Performance tab

Go to **Performance** → enable **"Track Widget Builds"** → record a few seconds.

### 4. Observe

The frame timeline shows `RenderObject.markNeedsLayout()` calls for each cell
but **zero widget build events** for the 1,000 `DripText` cells.

The frame counter widget in the top-right corner increments every frame via a
`Ticker` + `ValueListenableBuilder` — this is intentional: it proves that normal
Flutter StatefulWidget rebuilds coexist peacefully with DRIP zero-rebuild updates.

## Architecture

```
Timer (16ms)
  └─ writes to 1000 DripState<String>
       └─ DripBatch (microtask coalesce)
            └─ DripBinding.onStateChanged()
                 ├─ apply: RenderParagraph.text = new TextSpan(...)
                 └─ markNeeds: RenderObject.markNeedsLayout()
                      └─ Flutter engine: layout + paint pass
                           └─ Screen update (zero build() calls)
```

## Expected DevTools output (profile mode)

```
Widget rebuilds during 1000-cell update cycle:    0
RenderObject.markNeedsLayout() calls:             ~1000
Estimated frame time:                             <2ms
```

> "No floods. No leaks. Just precision drops."
>
> drip_flutter v0.2.0-alpha: 1000 live cells. 0 widget rebuilds.
> DripState → DripBinding → markNeedsLayout(). That's it.
