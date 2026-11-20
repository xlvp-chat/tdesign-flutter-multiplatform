import 'adaptive_context.dart';
import 'tdesign_mode.dart';

/// Resolves presentation mode from [TDesignMode] + [AdaptiveContext].
///
/// OS alone must not decide the morph (ADR-005).
class AdaptiveResolver {
  const AdaptiveResolver({
    this.desktopMinWidth = 900,
    this.forceDesktopWhenKeyboardAndMouse = true,
  });

  final double desktopMinWidth;
  final bool forceDesktopWhenKeyboardAndMouse;

  TDesignMode resolve({
    required TDesignMode mode,
    required AdaptiveContext context,
  }) {
    switch (mode) {
      case TDesignMode.mobile:
        return TDesignMode.mobile;
      case TDesignMode.desktop:
        return TDesignMode.desktop;
      case TDesignMode.adaptive:
        if (forceDesktopWhenKeyboardAndMouse &&
            context.keyboardAvailable &&
            context.primaryPointer == AdaptivePointer.mouse &&
            context.windowSize.width >= desktopMinWidth * 0.75) {
          return TDesignMode.desktop;
        }
        if (context.windowSize.width >= desktopMinWidth) {
          return TDesignMode.desktop;
        }
        return TDesignMode.mobile;
    }
  }
}
