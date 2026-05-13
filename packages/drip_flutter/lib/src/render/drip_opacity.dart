import 'package:drip_core/drip_core.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../binding/drip_binding.dart';

/// A [RenderProxyBox] that supports direct [DripState] binding for opacity.
///
/// **Design Decision:** Subclassing [RenderProxyBox] instead of [RenderOpacity]
/// to maintain a clean, binding-focused implementation without being coupled
/// to internal caching logic of the framework's default opacity renderer.
class DripOpacityRenderBox extends RenderProxyBox {
  double _opacity;
  DripBinding<double>? _binding;

  /// Creates a [DripOpacityRenderBox].
  DripOpacityRenderBox({
    required double opacity,
    RenderBox? child,
  })  : _opacity = opacity.clamp(0.0, 1.0),
        super(child);

  /// The current opacity value, clamped to [0.0, 1.0].
  double get opacity => _opacity;
  set opacity(double value) {
    final clamped = value.clamp(0.0, 1.0);
    if (_opacity == clamped) return;
    _opacity = clamped;
    markNeedsPaint();
  }

  /// Binds a [DripState] to this render object.
  void bindState(DripState<double> state) {
    _binding?.dispose();
    _binding = DripBinding<double>(
      state: state,
      apply: (value) => opacity = value,
      markNeeds: () {
        // Rationale: Opacity is a paint-only property and does not affect layout.
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
    if (child == null || _opacity <= 0.0) return;

    if (_opacity >= 1.0) {
      context.paintChild(child!, offset);
      return;
    }

    // Apply opacity using the PaintingContext.
    context.pushOpacity(
      offset,
      (_opacity * 255).round(),
      (context, offset) => context.paintChild(child!, offset),
    );
  }

  @override
  void dispose() {
    unbindState();
    super.dispose();
  }
}

/// A widget that applies opacity from a [DripState<double>] with zero rebuilds.
class DripOpacity extends SingleChildRenderObjectWidget {
  /// The reactive state source for the opacity value.
  final DripState<double> opacity;

  /// Creates a [DripOpacity] widget.
  const DripOpacity({
    required this.opacity,
    super.child,
    super.key,
  });

  @override
  DripOpacityRenderBox createRenderObject(BuildContext context) {
    final renderObject = DripOpacityRenderBox(opacity: opacity.value);
    renderObject.bindState(opacity);
    return renderObject;
  }

  @override
  void updateRenderObject(
      BuildContext context, DripOpacityRenderBox renderObject) {
    renderObject.bindState(opacity);
  }

  @override
  void didUnmountRenderObject(DripOpacityRenderBox renderObject) {
    renderObject.unbindState();
  }
}
