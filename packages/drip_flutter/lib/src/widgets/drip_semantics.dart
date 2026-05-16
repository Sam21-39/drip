import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:drip_core/drip_core.dart';

/// A wrapper widget that explicitly synchronises a [DripReadable] to the Flutter
/// semantics tree for accessibility (e.g., VoiceOver, TalkBack).
///
/// Unlike zero-rebuild render widgets (`DripText`, `DripOpacity`), which bypass
/// widget reconciliation, `DripSemantics` uses `setState` to rebuild a
/// [Semantics] widget when the value changes. This ensures screen readers
/// always read the correct, updated value.
///
/// To prevent screen reader buffer overruns on high-frequency state updates,
/// this widget enforces a minimum debounce interval between semantics updates
/// (default 200ms, floor 16ms).
class DripSemantics<T> extends StatefulWidget {
  /// The reactive value to sync with the semantics tree.
  final DripReadable<T> value;

  /// A function that returns the semantics label for the current value.
  final String Function(T value) label;

  /// The child widget.
  final Widget child;

  /// The minimum interval between semantics updates.
  /// Defaults to 200ms. Has a hard floor of 16ms.
  final Duration updateInterval;

  DripSemantics({
    super.key,
    required this.value,
    required this.label,
    required this.child,
    Duration updateInterval = const Duration(milliseconds: 200),
  }) : updateInterval = updateInterval.inMilliseconds < 16
            ? const Duration(milliseconds: 16)
            : updateInterval;

  @override
  State<DripSemantics<T>> createState() => _DripSemanticsState<T>();
}

class _DripSemanticsState<T> extends State<DripSemantics<T>> {
  late String _currentLabel;
  Timer? _debounceTimer;
  bool _isStale = false;

  @override
  void initState() {
    super.initState();
    _currentLabel = widget.label(widget.value.value);
    widget.value.addListener(_markStale);
  }

  @override
  void didUpdateWidget(DripSemantics<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      oldWidget.value.removeListener(_markStale);
      _currentLabel = widget.label(widget.value.value);
      widget.value.addListener(_markStale);
    }
  }

  @override
  void dispose() {
    widget.value.removeListener(_markStale);
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _markStale() {
    if (_isStale || !mounted) return;
    _isStale = true;

    // If there is an active timer, we wait for it.
    // If not, we start one.
    if (_debounceTimer == null || !_debounceTimer!.isActive) {
      _debounceTimer = Timer(widget.updateInterval, _updateSemantics);
    }
  }

  void _updateSemantics() {
    if (!mounted) return;
    _isStale = false;

    final newValue = widget.value.value;
    final newLabel = widget.label(newValue);
    if (newLabel != _currentLabel) {
      setState(() {
        _currentLabel = newLabel;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: _currentLabel,
      child: widget.child,
    );
  }
}
