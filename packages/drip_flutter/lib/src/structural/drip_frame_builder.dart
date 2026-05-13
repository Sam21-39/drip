import 'package:flutter/widgets.dart';
import 'drip_frame.dart';

/// A [StatefulWidget] that rebuilds when a [DripFrame] updates.
///
/// This is the controlled "escape hatch" for structural changes that genuinely
/// require a widget rebuild. Its use must be deliberate.
class DripFrameBuilder<T> extends StatefulWidget {
  /// The frame to watch.
  final DripFrame<T> frame;

  /// The builder function to call when the frame updates.
  final Widget Function(BuildContext context, T value) builder;

  /// Creates a [DripFrameBuilder].
  const DripFrameBuilder({
    required this.frame,
    required this.builder,
    super.key,
  });

  @override
  State<DripFrameBuilder<T>> createState() => _DripFrameBuilderState<T>();
}

class _DripFrameBuilderState<T> extends State<DripFrameBuilder<T>> {
  late T _value;

  @override
  void initState() {
    super.initState();
    _value = widget.frame.value;
    widget.frame.addListener(_onFrameChange);
  }

  void _onFrameChange(T newValue) {
    // Invariant 2 Check: This is the ONLY place in drip_flutter where
    // setState() is called, specifically for structural rebuilds.
    if (!mounted) return;
    setState(() {
      _value = newValue;
    });
  }

  @override
  void didUpdateWidget(DripFrameBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.frame != widget.frame) {
      oldWidget.frame.removeListener(_onFrameChange);
      _value = widget.frame.value;
      widget.frame.addListener(_onFrameChange);
    }
  }

  @override
  void dispose() {
    widget.frame.removeListener(_onFrameChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _value);
  }
}
