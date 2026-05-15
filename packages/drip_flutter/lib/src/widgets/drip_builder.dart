import 'package:flutter/widgets.dart';
import 'package:drip_core/drip_core.dart';

/// A general-purpose reactive builder widget that subscribes to a [DripReadable].
///
/// Use this when you need to conditionally build different widgets based on
/// a reactive value. Unlike [DripFrameBuilder], which expects imperative
/// updates, this builder automatically tracks and rebuilds when the bound
/// [source] changes.
class DripBuilder<T> extends StatefulWidget {
  /// The reactive source to watch.
  final DripReadable<T> source;

  /// The builder function called whenever the source changes.
  final Widget Function(BuildContext context, T value) builder;

  /// Optional equality function to skip rebuilds when the value is unchanged.
  /// Defaults to `==` if not provided.
  final bool Function(T a, T b)? identity;

  const DripBuilder({
    super.key,
    required this.source,
    required this.builder,
    this.identity,
  });

  @override
  State<DripBuilder<T>> createState() => _DripBuilderState<T>();
}

class _DripBuilderState<T> extends State<DripBuilder<T>> {
  late T _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.source.value;
    widget.source.addListener(_onChanged);
  }

  void _onChanged() {
    if (!mounted) return;

    final newValue = widget.source.value;
    final isEqual = widget.identity?.call(_currentValue, newValue) ??
        (_currentValue == newValue);

    if (isEqual) return;

    // DRIP EXCEPTION: setState() is permitted here.
    // DripBuilder exists to confine structural rebuilds
    // to the smallest possible subtree. This is intentional.
    setState(() {
      _currentValue = newValue;
    });
  }

  @override
  void didUpdateWidget(DripBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.source != widget.source) {
      oldWidget.source.removeListener(_onChanged);
      _currentValue = widget.source.value;
      widget.source.addListener(_onChanged);
    }
  }

  @override
  void dispose() {
    widget.source.removeListener(_onChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _currentValue);
  }
}
