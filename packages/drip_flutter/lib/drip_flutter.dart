/// Flutter render layer for the DRIP framework.
///
/// Connects DripState directly to RenderObject properties for high-performance,
/// zero-rebuild UI updates.
library;

export 'src/render/drip_color.dart' show DripColor;
export 'src/render/drip_custom.dart' show DripCustomBinding;
export 'src/render/drip_image.dart' show DripImage;
export 'src/render/drip_opacity.dart' show DripOpacity;
export 'src/render/drip_text.dart' show DripText;
export 'src/render/drip_transform.dart' show DripTransform;

// Structural rebuild tools
export 'src/structural/drip_frame.dart' show DripFrame;
export 'src/structural/drip_frame_builder.dart' show DripFrameBuilder;

// Node system
export 'src/node/drip_node.dart';
export 'src/node/drip_async_node.dart';
export 'src/widgets/drip_lifecycle.dart';
export 'src/widgets/drip_scope_widget.dart';

export 'src/widgets/drip_item_builder.dart';

// Reactive builder widgets (Phase 4)
export 'src/widgets/drip_builder.dart';
export 'src/widgets/drip_select.dart';
export 'src/widgets/drip_async_builder.dart';
export 'src/widgets/drip_semantics.dart';
