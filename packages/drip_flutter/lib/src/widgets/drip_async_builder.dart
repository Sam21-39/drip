import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart' show CircularProgressIndicator;
import 'package:drip_core/drip_core.dart';

/// An async state widget that renders subtrees based on the current [DripAsyncValue].
///
/// Exhaustively switches over [DripLoading], [DripData], and [DripError].
class DripAsyncBuilder<T> extends StatefulWidget {
  final DripAsync<T> state;
  final Widget Function(BuildContext context, T? previousData)? loading;
  final Widget Function(BuildContext context, T value) data;
  final Widget Function(BuildContext context, Object error,
      StackTrace stackTrace, T? previousData)? error;

  const DripAsyncBuilder({
    super.key,
    required this.state,
    this.loading,
    required this.data,
    this.error,
  });

  @override
  State<DripAsyncBuilder<T>> createState() => _DripAsyncBuilderState<T>();
}

class _DripAsyncBuilderState<T> extends State<DripAsyncBuilder<T>>
    implements DripListener {
  late DripAsyncValue<T> _currentAsyncValue;

  @override
  void initState() {
    super.initState();
    _currentAsyncValue = widget.state.value;
    widget.state.subscribe(this);
  }

  @override
  void onStateChanged() {
    if (!mounted) return;
    setState(() {
      _currentAsyncValue = widget.state.value;
    });
  }

  @override
  void didUpdateWidget(DripAsyncBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      oldWidget.state.unsubscribe(this);
      _currentAsyncValue = widget.state.value;
      widget.state.subscribe(this);
    }
  }

  @override
  void dispose() {
    widget.state.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final value = _currentAsyncValue;
    return switch (value) {
      DripLoading<T>() => _buildLoading(context, value.previousData),
      DripData<T>() => widget.data(context, value.value),
      DripError<T>() =>
        _buildError(context, value.error, value.stackTrace, value.previousData),
    };
  }

  Widget _buildLoading(BuildContext context, T? previousData) {
    if (widget.loading != null) {
      return widget.loading!(context, previousData);
    }
    assert(() {
      debugPrint(
          'DripAsyncBuilder: Warning: No loading callback provided. Using default CircularProgressIndicator.');
      return true;
    }());
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildError(BuildContext context, Object error, StackTrace stackTrace,
      T? previousData) {
    if (widget.error != null) {
      return widget.error!(context, error, stackTrace, previousData);
    }
    assert(() {
      debugPrint(
          'DripAsyncBuilder: Warning: No error callback provided. Using default Text.');
      debugPrint('Error: $error\n$stackTrace');
      return true;
    }());
    return Center(child: Text(error.toString()));
  }
}
