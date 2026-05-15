import 'package:drip_core/drip_core.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../binding/drip_binding.dart';

/// A [RenderTransform] that supports direct [DripReadable] binding for matrix transformations.
class DripTransformRenderBox extends RenderTransform {
  DripBinding<Matrix4>? _binding;
  Matrix4 _transform;

  /// Creates a [DripTransformRenderBox].
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

  /// Binds a [DripReadable] to this render object.
  void bindState(DripReadable<Matrix4> state) {
    _binding?.dispose();
    _binding = DripBinding<Matrix4>(
      source: state,
      apply: (value) => transform = value,
      markNeeds: () {
        // Rationale: Transforms are typically paint-only. Hit-testing is
        // updated during the paint pass in Flutter.
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
  void dispose() {
    unbindState();
    super.dispose();
  }
}

/// A widget that applies a matrix transform from a [DripReadable<Matrix4>] with zero rebuilds.
class DripTransform extends SingleChildRenderObjectWidget {
  /// The reactive state source for the transformation matrix.
  final DripReadable<Matrix4> transform;

  /// The origin of the transform.
  final Offset? origin;

  /// The alignment of the transform.
  final AlignmentGeometry? alignment;

  /// Whether to apply the transform to hit tests.
  final bool transformHitTests;

  /// The filter quality to use when transforming.
  final FilterQuality? filterQuality;

  /// Creates a [DripTransform] widget.
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

    renderObject.bindState(transform);
  }

  @override
  void didUnmountRenderObject(DripTransformRenderBox renderObject) {
    renderObject.unbindState();
  }
}
