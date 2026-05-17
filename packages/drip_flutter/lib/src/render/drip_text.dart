import 'package:drip_core/drip_core.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../binding/drip_binding.dart';

/// A [RenderParagraph] that supports direct [DripReadable] binding.
///
/// The [DripBinding] is created in [attach] and destroyed in [dispose],
/// not in [bindState], so that the subscription survives parent rebuilds
/// without being torn down and re-created (Risk 4 fix).
class DripRenderParagraph extends RenderParagraph {
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

  // The source and style are stored so that attach() can (re)create the binding
  // when the RenderObject is mounted, and reapply() can be called from the
  // widget's updateRenderObject.
  DripReadable<String>? _source;
  TextStyle _style = const TextStyle();

  /// Called from [DripText.createRenderObject] and [DripText.updateRenderObject].
  /// Stores the source and style for use in [attach].
  ///
  /// If the source reference itself has changed (e.g., the widget was given a
  /// new state object), dispose the old binding and create a fresh one.
  void bindState(DripReadable<String> source, TextStyle style) {
    _style = style;

    if (_source != source) {
      // Source changed — tear down old binding and re-attach to new source.
      _binding?.dispose();
      _binding = null;
      _source = source;

      if (attached) {
        _createBinding();
      }
    } else {
      // Same source — only re-assert the current value (Risk 4: no subscription churn).
      _binding?.reapply();
    }
  }

  void _createBinding() {
    final source = _source;
    if (source == null) return;

    _binding = DripBinding<String>(
      source: source,
      apply: (value) {
        text = TextSpan(text: value, style: _style);
      },
      markNeeds: () {
        if (attached) markNeedsLayout();
      },
    );
  }

  /// Removes the active subscription but **preserves `_source`** so that
  /// `attach()` can re-create the binding if Flutter remounts this
  /// [RenderObject] in the same slot (Risk 4 / CI-1.2 fix).
  ///
  /// Call from `didUnmountRenderObject` — not from a full disposal path.
  void detachBinding() {
    _binding?.dispose();
    _binding = null;
    // _source is intentionally kept: attach() needs it to re-subscribe on remount.
  }

  /// Full teardown: disposes the binding **and** forgets the source.
  ///
  /// Use only when the source is being replaced (`bindState` with a new source)
  /// or when the [RenderObject] itself is being permanently destroyed (`dispose`).
  void unbindState() {
    _binding?.dispose();
    _binding = null;
    _source = null;
  }

  // ── RenderObject lifecycle ────────────────────────────────────────────────

  /// Risk 4 fix: binding is created here (on mount), not in bindState.
  /// Risk 1 fix: re-asserts DRIP value immediately on mount, before first paint,
  /// overwriting whatever Flutter wrote from the widget tree.
  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _createBinding();
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    if (debugNeedsLayout) return false;
    return super.hitTestChildren(result, position: position);
  }

  @override
  void dispose() {
    unbindState(); // full teardown — source no longer needed.
    super.dispose();
  }

  /// Risk 1 fix: re-asserts DRIP value after a hot reload (reassemble cycle).
  @override
  void reassemble() {
    super.reassemble();
    _binding?.reapply();
  }
}

/// A widget that renders text from a [DripReadable<String>] with zero rebuilds.
class DripText extends LeafRenderObjectWidget {
  final DripReadable<String> state;
  final TextStyle? style;
  final TextAlign textAlign;
  final TextDirection? textDirection;
  final bool softWrap;
  final TextOverflow overflow;
  final int? maxLines;
  final TextScaler? textScaler;

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
    final DefaultTextStyle defaultTextStyle = DefaultTextStyle.of(context);
    TextStyle? effectiveTextStyle = style;
    if (style == null || style!.inherit) {
      effectiveTextStyle = defaultTextStyle.style.merge(style);
    }

    final renderObject = DripRenderParagraph(
      TextSpan(text: state.value, style: effectiveTextStyle),
      textAlign: textAlign,
      textDirection: textDirection ?? Directionality.of(context),
      softWrap: softWrap,
      overflow: overflow,
      textScaler: textScaler ?? MediaQuery.textScalerOf(context),
      maxLines: maxLines,
    );

    // Store source/style so attach() can create the binding.
    renderObject.bindState(state, effectiveTextStyle ?? const TextStyle());

    return renderObject;
  }

  @override
  void updateRenderObject(
    BuildContext context,
    DripRenderParagraph renderObject,
  ) {
    final DefaultTextStyle defaultTextStyle = DefaultTextStyle.of(context);
    TextStyle? effectiveTextStyle = style;
    if (style == null || style!.inherit) {
      effectiveTextStyle = defaultTextStyle.style.merge(style);
    }

    renderObject
      ..textAlign = textAlign
      ..textDirection = textDirection ?? Directionality.of(context)
      ..softWrap = softWrap
      ..overflow = overflow
      ..textScaler = textScaler ?? MediaQuery.textScalerOf(context)
      ..maxLines = maxLines;

    // Risk 1 fix: re-assert DRIP value after Flutter has synced widget properties.
    // Risk 4 fix: bindState calls reapply() if source unchanged — no subscription churn.
    renderObject.bindState(state, effectiveTextStyle ?? const TextStyle());
  }

  @override
  void didUnmountRenderObject(DripRenderParagraph renderObject) {
    // Invariant 7: subscription removed when RenderObject unmounts.
    // Use detachBinding(), NOT unbindState(), so that _source is preserved.
    // Flutter may reuse the same RenderObject instance on remount (same slot,
    // same type), in which case attach() fires again and needs _source to
    // re-create the subscription (CI-1.2 fix).
    renderObject.detachBinding();
  }
}
