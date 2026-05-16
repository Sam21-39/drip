import 'package:drip_core/drip_core.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../binding/drip_binding.dart';

/// A [RenderTransform] that supports direct [DripReadable] binding for matrix transformations.
class DripTransformRenderBox extends RenderTransform {
  DripBinding<Matrix4>? _binding;
  Matrix4 _transform;
  DripReadable<Matrix4>? _source;

  DripTransformRenderBox({
    required Matrix4 initialTransform,
    super.origin,
    super.alignment,
    super.textDirection,
    super.transformHitTests,
    super.filterQuality,
    super.child,
  })  : _transform = initialTransform,
        super(transform: initialTransform);

  Matrix4 get transform => _transform;

  @override
  set transform(Matrix4 value) {
    _transform = value;
    super.transform = value;
    markNeedsPaint();
  }

  void bindState(DripReadable<Matrix4> source) {
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
    _binding = DripBinding<Matrix4>(
      source: source,
      apply: (value) => transform = value,
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

/// A widget that applies a matrix transform from a [DripReadable<Matrix4>] with zero rebuilds.
class DripTransform extends SingleChildRenderObjectWidget {
  final DripReadable<Matrix4> transform;
  final Offset? origin;
  final AlignmentGeometry? alignment;
  final bool transformHitTests;
  final FilterQuality? filterQuality;

  const DripTransform({
    required this.transform,
    super.child,
    super.key,
    this.origin,
    this.alignment,
    this.transformHitTests = true,
    this.filterQuality,
  });

  @override
  DripTransformRenderBox createRenderObject(BuildContext context) {
    final renderObject = DripTransformRenderBox(
      initialTransform: transform.value,
      origin: origin,
      alignment: alignment,
      textDirection: Directionality.maybeOf(context),
      transformHitTests: transformHitTests,
      filterQuality: filterQuality,
    );
    renderObject.bindState(transform);
    return renderObject;
  }

  @override
  void updateRenderObject(
    BuildContext context,
    DripTransformRenderBox renderObject,
  ) {
    renderObject
      ..origin = origin
      ..alignment = alignment
      ..textDirection = Directionality.maybeOf(context)
      ..transformHitTests = transformHitTests
      ..filterQuality = filterQuality;

    // Risk 1 + Risk 4: re-assert without subscription churn.
    renderObject.bindState(transform);
  }

  @override
  void didUnmountRenderObject(DripTransformRenderBox renderObject) {
    renderObject.unbindState();
  }
}
