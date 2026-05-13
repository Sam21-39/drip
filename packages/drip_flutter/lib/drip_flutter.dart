/// Flutter render layer for the DRIP framework.
///
/// Connects DripState directly to RenderObject properties for high-performance,
/// zero-rebuild UI updates.
library;

// Render binding widgets
export 'src/render/drip_color.dart' show DripColor;
export 'src/render/drip_custom.dart' show DripCustomBinding;
export 'src/render/drip_image.dart' show DripImage;
export 'src/render/drip_opacity.dart' show DripOpacity;
export 'src/render/drip_text.dart' show DripText;
export 'src/render/drip_transform.dart' show DripTransform;

// Structural rebuild tools
export 'src/structural/drip_frame.dart' show DripFrame;
export 'src/structural/drip_frame_builder.dart' show DripFrameBuilder;
