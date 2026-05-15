import 'package:drip_core/drip_core.dart';
import 'package:flutter/widgets.dart';

import '../binding/drip_binding.dart';

/// A [RenderBox] that supports direct [DripReadable] binding for [ImageProvider].
class DripImageRenderBox extends RenderBox {
  ImageProvider _imageProvider;
  double? _width;
  double? _height;
  BoxFit _fit;
  Alignment _alignment;

  ImageStream? _imageStream;
  ImageInfo? _imageInfo;
  ImageStreamListener? _imageStreamListener;
  DripBinding<ImageProvider>? _binding;

  /// Creates a [DripImageRenderBox].
  DripImageRenderBox({
    required ImageProvider image,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    Alignment alignment = Alignment.center,
  })  : _imageProvider = image,
        _width = width,
        _height = height,
        _fit = fit,
        _alignment = alignment;

  // Setters for layout-affecting properties
  set width(double? value) {
    if (_width == value) return;
    _width = value;
    markNeedsLayout();
  }

  set height(double? value) {
    if (_height == value) return;
    _height = value;
    markNeedsLayout();
  }

  set fit(BoxFit value) {
    if (_fit == value) return;
    _fit = value;
    markNeedsPaint();
  }

  set alignment(Alignment value) {
    if (_alignment == value) return;
    _alignment = value;
    markNeedsPaint();
  }

  void _handleImageFrame(ImageInfo info, bool synchronousCall) {
    if (_imageInfo == info) return;
    _imageInfo = info;
    markNeedsPaint();
  }

  void _resolveImage() {
    final ImageStream? oldStream = _imageStream;
    _imageStream = _imageProvider.resolve(ImageConfiguration.empty);

    if (_imageStream?.key != oldStream?.key) {
      _imageStreamListener ??= ImageStreamListener(_handleImageFrame);
      oldStream?.removeListener(_imageStreamListener!);
      _imageStream?.addListener(_imageStreamListener!);
    }
  }

  /// Binds a [DripReadable] to this render object.
  void bindState(DripReadable<ImageProvider> state) {
    _binding?.dispose();
    _binding = DripBinding<ImageProvider>(
      source: state,
      apply: (value) {
        _imageProvider = value;
        _resolveImage();
      },
      markNeeds: () {
        // markNeedsPaint is handled by the ImageStreamListener.
      },
    );
  }

  /// Disposes the current binding and stops updates.
  void unbindState() {
    _binding?.dispose();
    _binding = null;
    if (_imageStreamListener != null) {
      _imageStream?.removeListener(_imageStreamListener!);
    }
    _imageStream = null;
    _imageInfo = null;
  }

  @override
  void performLayout() {
    size = constraints.constrain(Size(
      _width ?? constraints.maxWidth,
      _height ?? constraints.maxHeight,
    ));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_imageInfo == null) return;

    paintImage(
      canvas: context.canvas,
      rect: offset & size,
      image: _imageInfo!.image,
      fit: _fit,
      alignment: _alignment,
    );
  }

  @override
  void dispose() {
    unbindState();
    super.dispose();
  }
}

/// A widget that renders an image from a [DripReadable<ImageProvider>] with zero rebuilds.
class DripImage extends LeafRenderObjectWidget {
  /// The reactive state source for the image provider.
  final DripReadable<ImageProvider> state;

  /// The width of the image.
  final double? width;

  /// The height of the image.
  final double? height;

  /// How the image should be inscribed into the box.
  final BoxFit fit;

  /// How the image should be aligned within the box.
  final Alignment alignment;

  /// Creates a [DripImage] widget.
  const DripImage(
    this.state, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
  });

  @override
  DripImageRenderBox createRenderObject(BuildContext context) {
    final renderObject = DripImageRenderBox(
      image: state.value,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
    );
    renderObject.bindState(state);
    return renderObject;
  }

  @override
  void updateRenderObject(
      BuildContext context, DripImageRenderBox renderObject) {
    renderObject
      ..width = width
      ..height = height
      ..fit = fit
      ..alignment = alignment;

    renderObject.bindState(state);
  }

  @override
  void didUnmountRenderObject(DripImageRenderBox renderObject) {
    renderObject.unbindState();
  }
}
