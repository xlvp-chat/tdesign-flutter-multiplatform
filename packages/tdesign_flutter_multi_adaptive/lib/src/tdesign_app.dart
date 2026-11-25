import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'adaptive_context.dart';
import 'adaptive_resolver.dart';
import 'tdesign_mode.dart';

/// Host that exposes [AdaptiveScope] to descendants.
///
/// Before any pointer event, [AdaptivePointer.touch] is used and the keyboard
/// is treated as unavailable, so adaptive mode follows width only. A later
/// mouse, trackpad, touch, or stylus event replaces [AdaptiveContext.primaryPointer].
/// The first key event marks the keyboard available. Flutter does not report
/// keyboard removal, so that flag stays true for the rest of the session.
class TDesignApp extends StatefulWidget {
  const TDesignApp({
    super.key,
    required this.child,
    this.mode = TDesignMode.adaptive,
    this.resolver = const AdaptiveResolver(),
    this.density = 'default',
  });

  final Widget child;
  final TDesignMode mode;
  final AdaptiveResolver resolver;
  final String density;

  @override
  State<TDesignApp> createState() => _TDesignAppState();
}

class _TDesignAppState extends State<TDesignApp> {
  var _pointer = AdaptivePointer.touch;
  var _keyboard = false;

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_onKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    super.dispose();
  }

  bool _onKey(KeyEvent event) {
    if (!_keyboard) {
      setState(() => _keyboard = true);
    }
    return false;
  }

  void _onPointer(PointerEvent event) {
    final next = switch (event.kind) {
      PointerDeviceKind.mouse ||
      PointerDeviceKind.trackpad => AdaptivePointer.mouse,
      PointerDeviceKind.stylus ||
      PointerDeviceKind.invertedStylus => AdaptivePointer.stylus,
      PointerDeviceKind.touch => AdaptivePointer.touch,
      PointerDeviceKind.unknown => null,
    };
    if (next == null || next == _pointer) return;
    setState(() => _pointer = next);
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.maybeOf(context);
    final size = media?.size ?? const Size(1024, 768);
    final desktopMin = widget.resolver.desktopMinWidth;
    // Tablet band is 2/3 of desktopMin (600 when desktopMin is 900).
    final tabletMin = desktopMin * 2 / 3;
    final String breakpoint;
    if (size.width >= desktopMin) {
      breakpoint = 'desktop';
    } else if (size.width >= tabletMin) {
      breakpoint = 'tablet';
    } else {
      breakpoint = 'mobile';
    }
    final adaptiveContext = AdaptiveContext(
      windowSize: size,
      breakpoint: breakpoint,
      primaryPointer: _pointer,
      keyboardAvailable: _keyboard,
      density: widget.density,
    );
    final resolved = widget.resolver.resolve(
      mode: widget.mode,
      context: adaptiveContext,
    );
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _onPointer,
      onPointerHover: _onPointer,
      onPointerSignal: _onPointer,
      child: AdaptiveScope(
        mode: resolved,
        contextData: adaptiveContext,
        child: widget.child,
      ),
    );
  }
}

/// Inherited adaptive signals.
class AdaptiveScope extends InheritedWidget {
  const AdaptiveScope({
    super.key,
    required this.mode,
    required this.contextData,
    required super.child,
  });

  final TDesignMode mode;
  final AdaptiveContext contextData;

  static AdaptiveScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AdaptiveScope>();
    assert(scope != null, 'AdaptiveScope not found in context');
    return scope!;
  }

  static AdaptiveScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AdaptiveScope>();
  }

  @override
  bool updateShouldNotify(covariant AdaptiveScope oldWidget) {
    return mode != oldWidget.mode ||
        contextData.windowSize != oldWidget.contextData.windowSize ||
        contextData.primaryPointer != oldWidget.contextData.primaryPointer ||
        contextData.keyboardAvailable !=
            oldWidget.contextData.keyboardAvailable;
  }
}
