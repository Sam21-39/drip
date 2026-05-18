# DripCustomBinding Safety

`DripCustomBinding<T>` is an expert-only API for direct render-layer binding.
Incorrect lifecycle handling can leak `RenderObject` references in production.

## Required Contract

1. Always disconnect bindings when a render object is unmounted.
2. Always call your binding teardown (`dispose()` or wrapper `unbindState()`)
   from unmount/dispose lifecycle hooks.
3. Never call `markNeedsPaint`/`markNeedsLayout` after teardown.

## Minimum Pattern

1. Create the binding during render object creation/attach.
2. Keep a stable reference to that binding.
3. Tear it down exactly once during unmount/dispose.

## Why This Exists

Bindings subscribe to `DripState` updates. If a binding remains subscribed after
its render object is gone, the state graph can keep dead render references alive.
This produces leaks that are often silent in release builds.
