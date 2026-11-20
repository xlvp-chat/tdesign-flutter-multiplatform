import 'package:flutter/widgets.dart';
import 'package:tdesign_flutter_core/tdesign_flutter_core.dart';

import '../form/_popup_shell.dart';

/// Desktop popover panel anchored to [child].
class TPopover extends StatefulWidget {
  const TPopover({
    super.key,
    required this.child,
    required this.content,
    this.placement = TPlacement.bottomLeft,
  });

  final Widget child;
  final Widget content;
  final TPlacement placement;

  @override
  State<TPopover> createState() => _TPopoverState();
}

class _TPopoverState extends State<TPopover> {
  var _open = false;

  void _setOpen(bool value) => setState(() => _open = value);

  @override
  Widget build(BuildContext context) {
    return TOverlayPortal(
      visible: _open,
      onVisibleChanged: _setOpen,
      options: TOverlayPortalOptions(
        preferredPlacement: widget.placement,
        layer: TOverlayLayer.popup,
      ),
      anchor: TInteractiveRegion(
        onActivate: () => _setOpen(!_open),
        builder: (context, state) => widget.child,
      ),
      overlayBuilder: (context) {
        final tokens = TDesignTokenScope.of(context);
        return TPopupShell(
          tokens: tokens,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: widget.content,
          ),
        );
      },
    );
  }
}
