import 'package:flutter/widgets.dart';
import 'drip_list.dart';

/// A list widget that rebuilds only the specific item tile that changed.
///
/// Unlike `ListView.builder` driven by a traditional state object (which rebuilds
/// the entire visible list on any change), `DripListView` leverages [DripList]'s
/// item-level subscriber granularity.
/// Structural changes (add/remove) trigger a minimal list-level rebuild to
/// add or remove tiles. Content changes (list[i] = value) trigger a rebuild
/// ONLY for the `_DripListTile` at index `i`.
class DripListView<T> extends StatefulWidget {
  final DripList<T> list;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget Function(BuildContext context)? emptyBuilder;
  final Axis scrollDirection;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;

  const DripListView({
    super.key,
    required this.list,
    required this.itemBuilder,
    this.emptyBuilder,
    this.scrollDirection = Axis.vertical,
    this.shrinkWrap = false,
    this.physics,
    this.padding,
  });

  @override
  State<DripListView<T>> createState() => _DripListViewState<T>();
}

class _DripListViewState<T> extends State<DripListView<T>> {
  late int _length;

  @override
  void initState() {
    super.initState();
    _length = widget.list.length;
    widget.list.addStructuralListener(_onStructuralChange);
  }

  @override
  void didUpdateWidget(DripListView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.list != widget.list) {
      oldWidget.list.removeStructuralListener(_onStructuralChange);
      _length = widget.list.length;
      widget.list.addStructuralListener(_onStructuralChange);
    }
  }

  @override
  void dispose() {
    widget.list.removeStructuralListener(_onStructuralChange);
    super.dispose();
  }

  void _onStructuralChange() {
    if (!mounted) return;
    setState(() {
      _length = widget.list.length;
    });
  }

  Widget _buildItem(BuildContext context, int index) {
    return _DripListTile<T>(
      list: widget.list,
      index: index,
      itemBuilder: widget.itemBuilder,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_length == 0 && widget.emptyBuilder != null) {
      return widget.emptyBuilder!(context);
    }

    return ListView.builder(
      scrollDirection: widget.scrollDirection,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics,
      padding: widget.padding,
      itemCount: _length,
      itemBuilder: _buildItem,
    );
  }
}

/// A private tile widget that subscribes exclusively to its specific index in the list.
class _DripListTile<T> extends StatefulWidget {
  final DripList<T> list;
  final int index;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;

  const _DripListTile({
    super.key,
    required this.list,
    required this.index,
    required this.itemBuilder,
  });

  @override
  State<_DripListTile<T>> createState() => _DripListTileState<T>();
}

class _DripListTileState<T> extends State<_DripListTile<T>> {
  @override
  void initState() {
    super.initState();
    widget.list.addIndexListener(widget.index, _onItemChanged);
  }

  @override
  void didUpdateWidget(_DripListTile<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.list != widget.list || oldWidget.index != widget.index) {
      oldWidget.list.removeIndexListener(oldWidget.index, _onItemChanged);
      widget.list.addIndexListener(widget.index, _onItemChanged);
    }
  }

  @override
  void dispose() {
    widget.list.removeIndexListener(widget.index, _onItemChanged);
    // Invariant 7 analogue: listener removed BEFORE super.dispose()
    super.dispose();
  }

  void _onItemChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return widget.itemBuilder(
      context,
      widget.list[widget.index],
      widget.index,
    );
  }
}
