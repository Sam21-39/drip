# DRIP Demo Grid

A high-performance benchmark app for the DRIP framework.

## The Experiment

This app renders a 40×25 grid (1000 cells). Every cell's content is updated independently every 16ms (60 updates per second).

Standard Flutter approaches (like `setState` at the root) would trigger 60 full-widget-tree rebuilds per second, significantly impacting performance and battery life.

**The DRIP Approach:**
1. Each cell is a `DripText` widget.
2. `DripText` binds directly to a `DripState<String>`.
3. When the state changes, `DripText` calls `markNeedsLayout()` on its `RenderParagraph` directly.
4. **Result:** 1000 cells update 60 times a second with **zero widget rebuilds**.

## How to Verify

1. Run the app in **Profile Mode**:
   ```bash
   flutter run --profile
   ```
2. Open **Flutter DevTools** -> **Performance** tab.
3. Enable **Track widget builds**.
4. Observe the "App Rebuilds" counter in the AppBar. It should stay at **1**.
5. Observe the DevTools timeline: you will see Frame events, but zero Widget Build events during the periodic updates.

---

*Precision drops. No floods.*
