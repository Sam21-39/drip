import 'package:flutter/widgets.dart';
import 'package:drip_core/drip_core.dart';

/// A general-purpose reactive builder widget that subscribes to a [DripReadable].
///
/// Use this when you need to conditionally build different widgets based on
/// a reactive value. Unlike [DripFrameBuilder], which expects imperative
/// updates, this builder automatically tracks and rebuilds when the bound
/// [value] changes.
class DripBuilder<T> extends StatefulWidget {
  final DripReadable<T> value;
  final Widget Function(BuildContext context, T value) builder;

  const DripBuilder({
    super.key,
    required this.value,
    required this.builder,
  });

  @override
  State<DripBuilder<T>> createState() => _DripBuilderState<T>();
}

class _DripBuilderState<T> extends State<DripBuilder<T>> implements DripListener {
  late T _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value.value;
    widget.value.subscribe(this);
  }

  @override
  void onStateChanged() {
    if (!mounted) return;
    setState(() {
      _currentValue = widget.value.value;
    });
  }

  @override
  void didUpdateWidget(DripBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      oldWidget.value.unsubscribe(this);
      _currentValue = widget.value.value;
      widget.value.subscribe(this);
    }
  }

  @override
  void dispose() {
    widget.value.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _currentValue);
  }
}
