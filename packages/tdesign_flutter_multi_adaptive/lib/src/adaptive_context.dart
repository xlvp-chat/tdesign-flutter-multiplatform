import 'package:flutter/widgets.dart';

/// Runtime signals used to choose Mobile vs Desktop component morphs.
///
/// OS alone must not be the primary branch (ADR-005).
@immutable
class AdaptiveContext {
  const AdaptiveContext({
    required this.windowSize,
    required this.breakpoint,
    required this.primaryPointer,
    required this.keyboardAvailable,
    required this.density,
  });

  final Size windowSize;
  final String breakpoint;
  final AdaptivePointer primaryPointer;
  final bool keyboardAvailable;
  final String density;
}

enum AdaptivePointer {
  touch,
  mouse,
  stylus,
}
