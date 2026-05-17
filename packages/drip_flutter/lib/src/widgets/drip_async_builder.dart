import 'package:flutter/widgets.dart';
import 'package:drip_core/drip_core.dart';

/// An async state widget that renders subtrees based on the current [DripAsyncValue].
///
/// Exhaustively switches over [DripAsyncLoading], [DripAsyncData], and [DripAsyncError].
/// All three callbacks are required to ensure robust error handling.
class DripAsyncBuilder<T> extends StatefulWidget {
  final DripAsync<T> source;
  final Widget Function(BuildContext context, T? previousData) loading;
  final Widget Function(BuildContext context, T value) data;
  final Widget Function(BuildContext context, Object error,
      StackTrace stackTrace, T? previousData) error;

  const DripAsyncBuilder({
    super.key,
    required this.source,
    required this.loading,
    required this.data,
    required this.error,
  });

  @override
  State<DripAsyncBuilder<T>> createState() => _DripAsyncBuilderState<T>();
}

class _DripAsyncBuilderState<T> extends State<DripAsyncBuilder<T>> {
  late DripAsyncValue<T> _currentAsyncValue;

  @override
  void initState() {
    super.initState();
    _currentAsyncValue = widget.source.value;
    widget.source.addListener(_onChanged);
  }

  void _onChanged() {
    if (!mounted) return;
    setState(() {
      _currentAsyncValue = widget.source.value;
    });
  }

  @override
  void didUpdateWidget(DripAsyncBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.source != widget.source) {
      oldWidget.source.removeListener(_onChanged);
      _currentAsyncValue = widget.source.value;
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
    final value = _currentAsyncValue;
    return switch (value) {
      DripAsyncLoading<T>() => widget.loading(context, value.previousData),
      DripAsyncData<T>() => widget.data(context, value.value),
      DripAsyncError<T>() => widget.error(
          context, value.error, value.stackTrace, value.previousData),
    };
  }
}
