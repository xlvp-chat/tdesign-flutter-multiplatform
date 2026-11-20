import 'package:flutter/widgets.dart';

import 't_component_state.dart';

/// Unified hover / focus / press / keyboard activation surface for Desktop.
///
/// Phase 0 PoC: FocusableActionDetector + MouseRegion + state resolver.
/// Components must reuse this instead of reinventing pointer/focus wiring.
class TInteractiveRegion extends StatefulWidget {
  const TInteractiveRegion({
    super.key,
    required this.builder,
    this.onActivate,
    this.enabled = true,
    this.focusNode,
    this.cursor,
  });

  final Widget Function(BuildContext context, TComponentState state) builder;
  final VoidCallback? onActivate;
  final bool enabled;
  final FocusNode? focusNode;
  final MouseCursor? cursor;

  @override
  State<TInteractiveRegion> createState() => _TInteractiveRegionState();
}

class _TInteractiveRegionState extends State<TInteractiveRegion> {
  var _hovered = false;
  var _focused = false;
  var _pressed = false;

  TComponentState get _state {
    if (!widget.enabled) return TComponentState.disabled;
    if (_pressed) return TComponentState.pressed;
    if (_focused) return TComponentState.focused;
    if (_hovered) return TComponentState.hovered;
    return TComponentState.normal;
  }

  void _activate() {
    if (!widget.enabled) return;
    widget.onActivate?.call();
  }

  @override
  Widget build(BuildContext context) {
    final cursor = widget.cursor ??
        (widget.enabled ? SystemMouseCursors.click : SystemMouseCursors.basic);

    return FocusableActionDetector(
      enabled: widget.enabled,
      focusNode: widget.focusNode,
      mouseCursor: cursor,
      onShowHoverHighlight: (hovered) => setState(() => _hovered = hovered),
      onShowFocusHighlight: (focused) => setState(() => _focused = focused),
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            _activate();
            return null;
          },
        ),
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: widget.enabled
            ? (_) => setState(() => _pressed = true)
            : null,
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: widget.enabled
            ? (_) {
                setState(() => _pressed = false);
                _activate();
              }
            : null,
        child: widget.builder(context, _state),
      ),
    );
  }
}
