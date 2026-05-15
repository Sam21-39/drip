# Flutter High-Stress Benchmark

A production-grade performance laboratory for comparing Flutter state management solutions under extreme rendering pressure.

## 🎯 Objective
This benchmark measures the efficiency of different state management frameworks by simulating a high-frequency workload: a **10x20 grid (200 cubes)** updating every single frame (vsync) for 30 seconds.

## 🚀 How to Run
To get accurate performance metrics, you **must** run the app in release mode on a physical device.

```bash
flutter run --release
```

## 📊 Key Metrics
- **Widget Builds**: Every call to a widget's `build()` method.
- **Frame Builds**: Actual vsync-locked frame boundaries where the engine renders.
- **Efficiency**: Calculated as `(Expected Builds / Actual Builds) * 100`. 
  - *Expected*: 201 builds per frame (1 boundary + 200 items).
  - High efficiency (>95%) indicates the framework is correctly scoping rebuilds.
- **Latency**: Build and Raster thread durations in milliseconds.

## 🛠️ Solutions Compared
1. **DRIP**: Our high-performance reactive framework.
2. **GetX**: Reactive list updates.
3. **Riverpod**: StateProvider with manual consumption.
4. **BLoC**: Event-driven state updates.
5. **Provider**: ChangeNotifier with Consumer.
6. **setState**: Standard Flutter subtree rebuild.

## 🏆 Scoring
Results are recorded in the **Session History** at the bottom of the screen. Winning entries (Top 3) are awarded 🥇, 🥈, and 🥉 medals based on their Efficiency score.
