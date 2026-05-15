import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:drip_core/drip_core.dart';

/// A multi-source reactive builder for two sources.
class DripSelect2<A, B, R> extends StatefulWidget {
  final DripReadable<A> source1;
  final DripReadable<B> source2;
  final R Function(A a, B b) selector;
  final Widget Function(BuildContext context, R value) builder;
  final bool Function(R a, R b)? identity;

  const DripSelect2({
    super.key,
    required this.source1,
    required this.source2,
    required this.selector,
    required this.builder,
    this.identity,
  });

  @override
  State<DripSelect2<A, B, R>> createState() => _DripSelect2State<A, B, R>();
}

class _DripSelect2State<A, B, R> extends State<DripSelect2<A, B, R>> {
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
  void didUpdateWidget(DripSelect2<A, B, R> oldWidget) {
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

/// A multi-source reactive builder for three sources.
class DripSelect3<A, B, C, R> extends StatefulWidget {
  final DripReadable<A> source1;
  final DripReadable<B> source2;
  final DripReadable<C> source3;
  final R Function(A a, B b, C c) selector;
  final Widget Function(BuildContext context, R value) builder;
  final bool Function(R a, R b)? identity;

  const DripSelect3({
    super.key,
    required this.source1,
    required this.source2,
    required this.source3,
    required this.selector,
    required this.builder,
    this.identity,
  });

  @override
  State<DripSelect3<A, B, C, R>> createState() =>
      _DripSelect3State<A, B, C, R>();
}

class _DripSelect3State<A, B, C, R> extends State<DripSelect3<A, B, C, R>> {
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
  void didUpdateWidget(DripSelect3<A, B, C, R> oldWidget) {
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

/// A multi-source reactive builder for four sources.
class DripSelect4<A, B, C, D, R> extends StatefulWidget {
  final DripReadable<A> source1;
  final DripReadable<B> source2;
  final DripReadable<C> source3;
  final DripReadable<D> source4;
  final R Function(A a, B b, C c, D d) selector;
  final Widget Function(BuildContext context, R value) builder;
  final bool Function(R a, R b)? identity;

  const DripSelect4({
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
  State<DripSelect4<A, B, C, D, R>> createState() =>
      _DripSelect4State<A, B, C, D, R>();
}

class _DripSelect4State<A, B, C, D, R>
    extends State<DripSelect4<A, B, C, D, R>> {
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
  void didUpdateWidget(DripSelect4<A, B, C, D, R> oldWidget) {
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
