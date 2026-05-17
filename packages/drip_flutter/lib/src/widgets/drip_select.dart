import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:drip_core/drip_core.dart';

/// Builds from selected values across multiple reactive sources.
///
/// Use [DripSelect] when a widget depends on a derived slice of two or more
/// [DripReadable] values and should rebuild only when that selected slice
/// changes. The static constructors cover the supported source arities while
/// keeping the public API centered on a single frozen symbol.
///
/// ```dart
/// DripSelect.two<int, int, int>(
///   source1: first,
///   source2: second,
///   selector: (a, b) => a + b,
///   builder: (context, total) => Text('$total'),
/// )
/// ```
abstract final class DripSelect {
  /// Creates a selector widget for two reactive sources.
  static Widget two<A, B, R>({
    Key? key,
    required DripReadable<A> source1,
    required DripReadable<B> source2,
    required R Function(A a, B b) selector,
    required Widget Function(BuildContext context, R value) builder,
    bool Function(R a, R b)? identity,
  }) {
    return _DripSelect2<A, B, R>(
      key: key,
      source1: source1,
      source2: source2,
      selector: selector,
      builder: builder,
      identity: identity,
    );
  }

  /// Creates a selector widget for three reactive sources.
  static Widget three<A, B, C, R>({
    Key? key,
    required DripReadable<A> source1,
    required DripReadable<B> source2,
    required DripReadable<C> source3,
    required R Function(A a, B b, C c) selector,
    required Widget Function(BuildContext context, R value) builder,
    bool Function(R a, R b)? identity,
  }) {
    return _DripSelect3<A, B, C, R>(
      key: key,
      source1: source1,
      source2: source2,
      source3: source3,
      selector: selector,
      builder: builder,
      identity: identity,
    );
  }

  /// Creates a selector widget for four reactive sources.
  static Widget four<A, B, C, D, R>({
    Key? key,
    required DripReadable<A> source1,
    required DripReadable<B> source2,
    required DripReadable<C> source3,
    required DripReadable<D> source4,
    required R Function(A a, B b, C c, D d) selector,
    required Widget Function(BuildContext context, R value) builder,
    bool Function(R a, R b)? identity,
  }) {
    return _DripSelect4<A, B, C, D, R>(
      key: key,
      source1: source1,
      source2: source2,
      source3: source3,
      source4: source4,
      selector: selector,
      builder: builder,
      identity: identity,
    );
  }
}

class _DripSelect2<A, B, R> extends StatefulWidget {
  final DripReadable<A> source1;
  final DripReadable<B> source2;
  final R Function(A a, B b) selector;
  final Widget Function(BuildContext context, R value) builder;
  final bool Function(R a, R b)? identity;

  const _DripSelect2({
    super.key,
    required this.source1,
    required this.source2,
    required this.selector,
    required this.builder,
    this.identity,
  });

  @override
  State<_DripSelect2<A, B, R>> createState() => _DripSelect2State<A, B, R>();
}

class _DripSelect2State<A, B, R> extends State<_DripSelect2<A, B, R>> {
  late R _currentValue;
  bool _isDirty = false;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.selector(widget.source1.value, widget.source2.value);
    widget.source1.addListener(_onChanged);
    widget.source2.addListener(_onChanged);
  }

  void _onChanged() {
    if (!mounted || _isDirty) return;

    _isDirty = true;
    Future.microtask(() {
      if (!mounted) return;
      _isDirty = false;

      final newValue =
          widget.selector(widget.source1.value, widget.source2.value);
      final isEqual = widget.identity?.call(_currentValue, newValue) ??
          (_currentValue == newValue);

      if (!isEqual) {
        setState(() {
          _currentValue = newValue;
        });
      }
    });
  }

  @override
  void didUpdateWidget(_DripSelect2<A, B, R> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.source1 != widget.source1 ||
        oldWidget.source2 != widget.source2) {
      oldWidget.source1.removeListener(_onChanged);
      oldWidget.source2.removeListener(_onChanged);
      _currentValue =
          widget.selector(widget.source1.value, widget.source2.value);
      widget.source1.addListener(_onChanged);
      widget.source2.addListener(_onChanged);
    }
  }

  @override
  void dispose() {
    widget.source1.removeListener(_onChanged);
    widget.source2.removeListener(_onChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _currentValue);
  }
}

class _DripSelect3<A, B, C, R> extends StatefulWidget {
  final DripReadable<A> source1;
  final DripReadable<B> source2;
  final DripReadable<C> source3;
  final R Function(A a, B b, C c) selector;
  final Widget Function(BuildContext context, R value) builder;
  final bool Function(R a, R b)? identity;

  const _DripSelect3({
    super.key,
    required this.source1,
    required this.source2,
    required this.source3,
    required this.selector,
    required this.builder,
    this.identity,
  });

  @override
  State<_DripSelect3<A, B, C, R>> createState() =>
      _DripSelect3State<A, B, C, R>();
}

class _DripSelect3State<A, B, C, R> extends State<_DripSelect3<A, B, C, R>> {
  late R _currentValue;
  bool _isDirty = false;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.selector(
      widget.source1.value,
      widget.source2.value,
      widget.source3.value,
    );
    widget.source1.addListener(_onChanged);
    widget.source2.addListener(_onChanged);
    widget.source3.addListener(_onChanged);
  }

  void _onChanged() {
    if (!mounted || _isDirty) return;

    _isDirty = true;
    Future.microtask(() {
      if (!mounted) return;
      _isDirty = false;

      final newValue = widget.selector(
        widget.source1.value,
        widget.source2.value,
        widget.source3.value,
      );
      final isEqual = widget.identity?.call(_currentValue, newValue) ??
          (_currentValue == newValue);

      if (!isEqual) {
        setState(() {
          _currentValue = newValue;
        });
      }
    });
  }

  @override
  void didUpdateWidget(_DripSelect3<A, B, C, R> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.source1 != widget.source1 ||
        oldWidget.source2 != widget.source2 ||
        oldWidget.source3 != widget.source3) {
      oldWidget.source1.removeListener(_onChanged);
      oldWidget.source2.removeListener(_onChanged);
      oldWidget.source3.removeListener(_onChanged);
      _currentValue = widget.selector(
        widget.source1.value,
        widget.source2.value,
        widget.source3.value,
      );
      widget.source1.addListener(_onChanged);
      widget.source2.addListener(_onChanged);
      widget.source3.addListener(_onChanged);
    }
  }

  @override
  void dispose() {
    widget.source1.removeListener(_onChanged);
    widget.source2.removeListener(_onChanged);
    widget.source3.removeListener(_onChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _currentValue);
  }
}

class _DripSelect4<A, B, C, D, R> extends StatefulWidget {
  final DripReadable<A> source1;
  final DripReadable<B> source2;
  final DripReadable<C> source3;
  final DripReadable<D> source4;
  final R Function(A a, B b, C c, D d) selector;
  final Widget Function(BuildContext context, R value) builder;
  final bool Function(R a, R b)? identity;

  const _DripSelect4({
    super.key,
    required this.source1,
    required this.source2,
    required this.source3,
    required this.source4,
    required this.selector,
    required this.builder,
    this.identity,
  });

  @override
  State<_DripSelect4<A, B, C, D, R>> createState() =>
      _DripSelect4State<A, B, C, D, R>();
}

class _DripSelect4State<A, B, C, D, R>
    extends State<_DripSelect4<A, B, C, D, R>> {
  late R _currentValue;
  bool _isDirty = false;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.selector(
      widget.source1.value,
      widget.source2.value,
      widget.source3.value,
      widget.source4.value,
    );
    widget.source1.addListener(_onChanged);
    widget.source2.addListener(_onChanged);
    widget.source3.addListener(_onChanged);
    widget.source4.addListener(_onChanged);
  }

  void _onChanged() {
    if (!mounted || _isDirty) return;

    _isDirty = true;
    Future.microtask(() {
      if (!mounted) return;
      _isDirty = false;

      final newValue = widget.selector(
        widget.source1.value,
        widget.source2.value,
        widget.source3.value,
        widget.source4.value,
      );
      final isEqual = widget.identity?.call(_currentValue, newValue) ??
          (_currentValue == newValue);

      if (!isEqual) {
        setState(() {
          _currentValue = newValue;
        });
      }
    });
  }

  @override
  void didUpdateWidget(_DripSelect4<A, B, C, D, R> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.source1 != widget.source1 ||
        oldWidget.source2 != widget.source2 ||
        oldWidget.source3 != widget.source3 ||
        oldWidget.source4 != widget.source4) {
      oldWidget.source1.removeListener(_onChanged);
      oldWidget.source2.removeListener(_onChanged);
      oldWidget.source3.removeListener(_onChanged);
      oldWidget.source4.removeListener(_onChanged);
      _currentValue = widget.selector(
        widget.source1.value,
        widget.source2.value,
        widget.source3.value,
        widget.source4.value,
      );
      widget.source1.addListener(_onChanged);
      widget.source2.addListener(_onChanged);
      widget.source3.addListener(_onChanged);
      widget.source4.addListener(_onChanged);
    }
  }

  @override
  void dispose() {
    widget.source1.removeListener(_onChanged);
    widget.source2.removeListener(_onChanged);
    widget.source3.removeListener(_onChanged);
    widget.source4.removeListener(_onChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _currentValue);
  }
}
