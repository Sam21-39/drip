import 'package:drip_core/drip_core.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../binding/drip_binding.dart';

/// A [RenderProxyBox] that supports direct [DripReadable] binding for background color.
class DripColorRenderBox extends RenderProxyBox {
  Color _color;
  DripBinding<Color>? _binding;
  DripReadable<Color>? _source;

  DripColorRenderBox({
    required Color color,
    RenderBox? child,
  })  : _color = color,
        super(child);

  Color get color => _color;
  set color(Color value) {
    if (_color == value) return;
    _color = value;
    markNeedsPaint();
  }

  /// Stores the source and (re)creates the binding if source changed.
  /// On unchanged source, calls [reapply] only — no subscription churn (Risk 4).
  void bindState(DripReadable<Color> source) {
    if (_source != source) {
      _binding?.dispose();
      _binding = null;
      _source = source;
      if (attached) _createBinding();
    } else {
      // Risk 1: re-assert DRIP value after a parent rebuild.
      _binding?.reapply();
    }
  }

  void _createBinding() {
    final source = _source;
    if (source == null) return;
    _binding = DripBinding<Color>(
      source: source,
      apply: (value) => color = value,
      markNeeds: () {
        if (attached) markNeedsPaint();
      },
    );
  }

  void unbindState() {
    _binding?.dispose();
    _binding = null;
    _source = null;
  }

  // ── RenderObject lifecycle ────────────────────────────────────────────────

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _createBinding(); // Risk 4: binding created on mount, not on every rebuild.
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_color.a > 0.0) {
      context.canvas.drawRect(
        offset & size,
        Paint()..color = _color,
      );
    }
    if (child != null) {
      context.paintChild(child!, offset);
    }
  }

  @override
  void dispose() {
    unbindState();
    super.dispose();
  }

  /// Risk 1 fix: re-asserts DRIP value after hot reload.
  @override
  void reassemble() {
    super.reassemble();
    _binding?.reapply();
  }
}

/// A widget that applies a background color from a [DripReadable<Color>] with zero rebuilds.
class DripColor extends SingleChildRenderObjectWidget {
  final DripReadable<Color> color;

  const DripColor({
    required this.color,
    super.child,
    super.key,
  });

  @override
  DripColorRenderBox createRenderObject(BuildContext context) {
    final renderObject = DripColorRenderBox(color: color.value);
    renderObject.bindState(color);
    return renderObject;
  }

  @override
  void updateRenderObject(
      BuildContext context, DripColorRenderBox renderObject) {
    // Risk 1 + Risk 4: bindState re-asserts value without subscription churn.
    renderObject.bindState(color);
  }

  @override
  void didUnmountRenderObject(DripColorRenderBox renderObject) {
    renderObject.unbindState();
  }
}
