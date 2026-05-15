import 'package:drip_core/drip_core.dart';
import '../binding/drip_binding.dart';

/// An abstract base class for developers building their own [RenderObject] bindings.
///
/// Encapsulates the pattern established by [DripText], [DripOpacity], etc.,
/// allowing developers to create custom high-performance bindings without
/// re-implementing the core lifecycle logic.
abstract class DripCustomBinding<T> {
  /// The reactive source.
  final DripReadable<T> source;
  DripBinding<T>? _binding;

  /// Creates a [DripCustomBinding] for the given [source].
  DripCustomBinding(this.source);

  /// Implement this to apply the new state value to the [RenderObject] property.
  void applyValue(T value);

  /// Returns the [RenderObject] method to call to trigger the pipeline.
  ///
  /// Typically returns either `markNeedsPaint` or `markNeedsLayout`.
  void Function() get markNeedsMethod;

  /// Initializes the binding. Should be called from `createRenderObject` or
  /// a similar initialization hook.
  void initBinding() {
    _binding?.dispose();
    _binding = DripBinding<T>(
      source: source,
      apply: applyValue,
      markNeeds: markNeedsMethod,
    );
  }

  /// Disposes the binding and deregisters from the state.
  ///
  /// Should be called from `dispose()` or `didUnmountRenderObject`.
  void dispose() {
    _binding?.dispose();
    _binding = null;
  }

  /// Whether the binding is currently active.
  bool get isActive => _binding != null && !_binding!.isDisposed;
}
