/// Adaptive host signals for TDesign Flutter.
///
/// [TDesignApp] resolves `mobile` or `desktop` from window size and input
/// capability (ADR-005) and exposes the result through [AdaptiveScope].
/// Version 0.1.0 does not swap Mobile and Desktop widgets.
library tdesign_flutter_multi_adaptive;

export 'src/adaptive_context.dart';
export 'src/adaptive_resolver.dart';
export 'src/tdesign_app.dart';
export 'src/tdesign_mode.dart';
