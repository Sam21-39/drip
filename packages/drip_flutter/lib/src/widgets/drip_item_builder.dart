import 'package:flutter/widgets.dart';
import 'package:drip_core/drip_core.dart';
import '../render/drip_text.dart';

/// A reactive widget that binds to a specific element index of a [DripItems] collection.
///
/// Under standard mode, it registers a listener on the element at the given [index],
/// rebuilding its subtree ONLY when that specific element changes.
///
/// Under [renderMode] (for [String] types), it completely bypasses Flutter's `build()`
/// cycles, returning a direct [DripText] render widget. This achieves true zero-rebuild
/// performance for lists/grids.
class DripItemBuilder<T> extends StatefulWidget {
  /// The collection of items.
  final DripItems<T> items;

  /// The index of the item this builder is responsible for.
  final int index;

  /// The builder function called to construct the subtree.
  final Widget Function(BuildContext context, T value) builder;

  /// Whether to use high-performance zero-rebuild direct render bindings.
  /// Only supported when T is [String].
  final bool renderMode;

  const DripItemBuilder({
    super.key,
    required this.items,
    required this.index,
    required this.builder,
    this.renderMode = false,
  });

  @override
  State<DripItemBuilder<T>> createState() => _DripItemBuilderState<T>();
}

class _DripItemBuilderState<T> extends State<DripItemBuilder<T>> {
  late DripState<T> _itemState;

  @override
  void initState() {
    super.initState();
    _itemState = widget.items[widget.index];
    if (!widget.renderMode) {
      _itemState.addListener(_onItemChanged);
    }
  }

  @override
  void didUpdateWidget(DripItemBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items ||
        oldWidget.index != widget.index ||
        oldWidget.renderMode != widget.renderMode) {
      if (!oldWidget.renderMode) {
        _itemState.removeListener(_onItemChanged);
      }
      _itemState = widget.items[widget.index];
      if (!widget.renderMode) {
        _itemState.addListener(_onItemChanged);
      }
    }
  }

  @override
  void dispose() {
    if (!widget.renderMode) {
      _itemState.removeListener(_onItemChanged);
    }
    // Invariant 7: listener removed BEFORE super.dispose()
    super.dispose();
  }

  void _onItemChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (widget.renderMode && _itemState is DripReadable<String>) {
      return DripText(_itemState as DripReadable<String>);
    }
    return widget.builder(context, _itemState.value);
  }
}
