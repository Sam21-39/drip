import 'package:drip_core/drip_core.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../binding/drip_binding.dart';

/// A [RenderProxyBox] that supports direct [DripReadable] binding for opacity.
class DripOpacityRenderBox extends RenderProxyBox {
  double _opacity;
  DripBinding<double>? _binding;
  DripReadable<double>? _source;

  DripOpacityRenderBox({
    required double opacity,
    RenderBox? child,
  })  : _opacity = opacity.clamp(0.0, 1.0),
        super(child);

  double get opacity => _opacity;
  set opacity(double value) {
    final clamped = value.clamp(0.0, 1.0);
    if (_opacity == clamped) return;
    _opacity = clamped;
    markNeedsPaint();
  }

  void bindState(DripReadable<double> source) {
    if (_source != source) {
      _binding?.dispose();
      _binding = null;
      _source = source;
      if (attached) _createBinding();
    } else {
      _binding?.reapply(); // Risk 1: re-assert after parent rebuild.
    }
  }

  void _createBinding() {
    final source = _source;
    if (source == null) return;
    _binding = DripBinding<double>(
      source: source,
      apply: (value) => opacity = value,
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
    _createBinding(); // Risk 4: stable subscription.
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null || _opacity <= 0.0) return;

    if (_opacity >= 1.0) {
      context.paintChild(child!, offset);
      return;
    }

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

  /// Risk 1 fix: re-asserts DRIP value after hot reload.
  @override
  void reassemble() {
    super.reassemble();
    _binding?.reapply();
  }
}

/// A widget that applies opacity from a [DripReadable<double>] with zero rebuilds.
class DripOpacity extends SingleChildRenderObjectWidget {
  final DripReadable<double> opacity;

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
