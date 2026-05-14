# Changelog

All notable changes to the Benchmark project will be documented in this file.

## [1.0.0] - 2026-05-14

### Added
- **Cube Grid Workload**: Implemented a 10x20 reactive grid stressing the framework with 200 updates per frame.
- **High-Fidelity Profiling**: Added real-time tracking of Frame Builds vs. Widget Builds.
- **Efficiency Scoring**: Mathematical efficiency metric based on expected vs. actual rebuilds.
- **30s Race Mode**: Standardized 30-second benchmark execution with auto-stop and countdown.
- **Session History**: Persistent history log for the current app session with ranking medals (🥇, 🥈, 🥉).
- **Dark Luxury Theme**: Premium UI with uniform cyan accent colors and high-performance sparkline visualization.
- **State Management Support**: Implementations for DRIP, GetX, Riverpod, BLoC, Provider, and setState.

### Changed
- Refactored `RebuildTracker` to separate frame-level engine events from widget-level logic.
- Optimized `FrameUpdater` to use `scheduleFrameCallback` for zero-jitter workload generation.
