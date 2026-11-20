/// Shared foundation for TDesign Flutter Mobile and Desktop.
///
/// Holds Token / Theme / Interaction / Overlay / Semantics building blocks.
/// Business components must not live in this package (ADR-001 / ADR-004).
library tdesign_flutter_multi_core;

export 'src/interaction/t_component_state.dart';
export 'src/interaction/t_interactive_region.dart';
export 'src/overlay/t_overlay_layer.dart';
export 'src/overlay/t_overlay_portal.dart';
export 'src/token/t_component_size.dart';
export 'src/token/tdesign_token_scope.dart';
export 'src/token/tdesign_tokens.g.dart';
