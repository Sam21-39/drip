import 'package:flutter/widgets.dart';
import 'package:drip_core/drip_core.dart';

/// A multi-source reactive builder.
///
/// Combines multiple reactive sources using a computed function and only rebuilds
/// when the combined result changes (based on the provided [equality] or default equality).
class DripSelect<T> extends StatefulWidget {
  final T Function() select;
  final Widget Function(BuildContext context, T value) builder;
  final Equality<T>? equality;

  const DripSelect({
    super.key,
    required this.select,
    required this.builder,
    this.equality,
  });

  @override
  State<DripSelect<T>> createState() => _DripSelectState<T>();
}

class _DripSelectState<T> extends State<DripSelect<T>> implements DripListener {
  late DripComputed<T> _computed;
  late T _currentValue;

  @override
  void initState() {
    super.initState();
    _computed = DripComputed<T>(widget.select);
    _currentValue = _computed.value;
    _computed.subscribe(this);
  }

  @override
  void onStateChanged() {
    if (!mounted) return;

    // Evaluate the computed value lazily.
    final newValue = _computed.value;

    // Check equality to prevent spurious rebuilds.
    final eq = widget.equality ?? defaultEquality<T>();
    if (!eq.equals(_currentValue, newValue)) {
      setState(() {
        _currentValue = newValue;
      });
    }
  }

  @override
  void didUpdateWidget(DripSelect<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.select != widget.select ||
        oldWidget.equality != widget.equality) {
      _computed.unsubscribe(this);
      _computed.dispose();

      _computed = DripComputed<T>(widget.select);
      _currentValue = _computed.value;
      _computed.subscribe(this);
    }
  }

  @override
  void dispose() {
    _computed.unsubscribe(this);
    _computed.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _currentValue);
  }
}
