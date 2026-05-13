import 'package:drip_core/drip_core.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../binding/drip_binding.dart';

/// A [RenderParagraph] that supports direct [DripState] binding.
class DripRenderParagraph extends RenderParagraph {
  /// Creates a [DripRenderParagraph].
  DripRenderParagraph(
    super.text, {
    super.textAlign,
    required super.textDirection,
    super.softWrap,
    super.overflow,
    super.textScaler,
    super.maxLines,
    super.locale,
    super.strutStyle,
    super.textWidthBasis,
    super.textHeightBehavior,
  });

  DripBinding<String>? _binding;

  /// Binds a [DripState] to this render object.
  ///
  /// Disposes any existing binding before creating a new one.
  void bindState(DripState<String> state, TextStyle style) {
    _binding?.dispose();
    _binding = DripBinding<String>(
      state: state,
      apply: (value) {
        // Construct a new TextSpan and assign it to the text property.
        // RenderParagraph.text setter internally handles Painter updates.
        text = TextSpan(text: value, style: style);
      },
      markNeeds: () {
        // Rationale: Text content changes affect geometry (size/wrapping),
        // so markNeedsLayout() is required.
        if (attached) {
          markNeedsLayout();
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

/// A widget that renders text from a [DripState<String>] with zero rebuilds.
///
/// When the [state] changes, [DripText] updates the underlying [RenderParagraph]
/// directly, bypassing the widget build cycle.
class DripText extends LeafRenderObjectWidget {
  /// The reactive state source for the text content.
  final DripState<String> state;

  /// The style to use for the text.
  final TextStyle? style;

  /// How the text should be aligned horizontally.
  final TextAlign textAlign;

  /// The directionality of the text.
  final TextDirection? textDirection;

  /// Whether the text should break at soft line breaks.
  final bool softWrap;

  /// How visual overflow should be handled.
  final TextOverflow overflow;

  /// An optional maximum number of lines for the text to span.
  final int? maxLines;

  /// The scaling strategy to use for text.
  final TextScaler? textScaler;

  /// Creates a [DripText] widget.
  const DripText(
    this.state, {
    super.key,
    this.style,
    this.textAlign = TextAlign.start,
    this.textDirection,
    this.softWrap = true,
    this.overflow = TextOverflow.clip,
    this.maxLines,
    this.textScaler,
  });

  @override
  DripRenderParagraph createRenderObject(BuildContext context) {
    final renderObject = DripRenderParagraph(
      TextSpan(text: state.value, style: style),
      textAlign: textAlign,
      textDirection: textDirection ?? Directionality.of(context),
      softWrap: softWrap,
      overflow: overflow,
      textScaler: textScaler ?? MediaQuery.textScalerOf(context),
      maxLines: maxLines,
    );

    // Initial binding
    renderObject.bindState(state, style ?? const TextStyle());

    return renderObject;
  }

  @override
  void updateRenderObject(
    BuildContext context,
    DripRenderParagraph renderObject,
  ) {
    renderObject
      ..textAlign = textAlign
      ..textDirection = textDirection ?? Directionality.of(context)
      ..softWrap = softWrap
      ..overflow = overflow
      ..textScaler = textScaler ?? MediaQuery.textScalerOf(context)
      ..maxLines = maxLines;

    // Always rebind to handle potential style or state reference changes.
    // bindState disposes the old binding first.
    renderObject.bindState(state, style ?? const TextStyle());
  }

  @override
  void didUnmountRenderObject(DripRenderParagraph renderObject) {
    // Invariant 7: Ensure binding is destroyed when render object is unmounted.
    renderObject.unbindState();
  }
}
