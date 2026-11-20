import 'package:flutter/widgets.dart';
import 'package:tdesign_flutter_core/tdesign_flutter_core.dart';

import '../form/_popup_shell.dart';
import '../token/t_token_color.dart';

/// Desktop tooltip using OverlayPortal on hover/focus.
class TTooltip extends StatefulWidget {
  const TTooltip({
    super.key,
    required this.child,
    required this.content,
    this.placement = TPlacement.top,
  });

  final Widget child;
  final Widget content;
  final TPlacement placement;

  @override
  State<TTooltip> createState() => _TTooltipState();
}

class _TTooltipState extends State<TTooltip> {
  var _visible = false;

  void _setVisible(bool value) {
    if (_visible == value) return;
    setState(() => _visible = value);
  }

  @override
  Widget build(BuildContext context) {
    return TOverlayPortal(
      visible: _visible,
      onVisibleChanged: _setVisible,
      options: TOverlayPortalOptions(
        preferredPlacement: widget.placement,
        dismissOnOutsidePointer: false,
        dismissOnEscape: true,
        layer: TOverlayLayer.popup,
      ),
      anchor: MouseRegion(
        onEnter: (_) => _setVisible(true),
        onExit: (_) => _setVisible(false),
        child: widget.child,
      ),
      overlayBuilder: (context) {
        final tokens = TDesignTokenScope.of(context);
        return TPopupShell(
          tokens: tokens,
          colorKey: 'grayColor14',
          bordered: false,
          shadowKey: null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: DefaultTextStyle(
              style: TextStyle(
                color: tTokenColorOf(tokens, 'textColorAnti'),
                fontSize: 12,
              ),
              child: widget.content,
            ),
          ),
        );
      },
    );
  }
}
