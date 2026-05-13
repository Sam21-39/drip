import 'package:drip_core/drip_core.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../binding/drip_binding.dart';

/// A [RenderProxyBox] that supports direct [DripState] binding for background color.
class DripColorRenderBox extends RenderProxyBox {
  Color _color;
  DripBinding<Color>? _binding;

  /// Creates a [DripColorRenderBox].
  DripColorRenderBox({
    required Color color,
    RenderBox? child,
  })  : _color = color,
        super(child);

  /// The current background color.
  Color get color => _color;
  set color(Color value) {
    if (_color == value) return;
    _color = value;
    markNeedsPaint();
  }

  /// Binds a [DripState] to this render object.
  void bindState(DripState<Color> state) {
    _binding?.dispose();
    _binding = DripBinding<Color>(
      state: state,
      apply: (value) => color = value,
      markNeeds: () {
        // Rationale: Color changes are paint-only.
        if (attached) {
          markNeedsPaint();
        }
      },
    );
  }

  /// Disposes the current binding and stops updates.
  void unbindState() {
    _binding?.dispose();
    _binding = null;
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
}

/// A widget that applies a background color from a [DripState<Color>] with zero rebuilds.
class DripColor extends SingleChildRenderObjectWidget {
  /// The reactive state source for the background color.
  final DripState<Color> color;

  /// Creates a [DripColor] widget.
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
    renderObject.bindState(color);
  }

  @override
  void didUnmountRenderObject(DripColorRenderBox renderObject) {
    renderObject.unbindState();
  }
}
