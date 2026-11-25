import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:tdesign_flutter_icons/tdesign_flutter_icons.dart';
import 'package:tdesign_flutter_multi_core/tdesign_flutter_multi_core.dart';

import '../basic/t_icon.dart';
import '../token/t_token_color.dart';

/// Which edge the drawer attaches to.
enum TDrawerPlacement { left, right, top, bottom }

/// Controlled side panel. Esc and the mask call [onVisibleChanged] with false.
class TDrawer extends StatefulWidget {
  const TDrawer({
    super.key,
    required this.visible,
    required this.onVisibleChanged,
    required this.body,
    this.header,
    this.placement = TDrawerPlacement.right,
    this.size = 300,
  });

  final bool visible;
  final ValueChanged<bool> onVisibleChanged;
  final Widget body;
  final Widget? header;
  final TDrawerPlacement placement;
  final double size;

  @override
  State<TDrawer> createState() => _TDrawerState();
}

class _TDrawerState extends State<TDrawer> {
  final _controller = OverlayPortalController();

  @override
  void initState() {
    super.initState();
    if (widget.visible) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
    }
  }

  @override
  void didUpdateWidget(covariant TDrawer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible == oldWidget.visible) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _sync();
    });
  }

  void _sync() {
    if (widget.visible) {
      if (!_controller.isShowing) _controller.show();
    } else if (_controller.isShowing) {
      _controller.hide();
    }
  }

  void _close() => widget.onVisibleChanged(false);

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _controller,
      overlayChildBuilder: _buildOverlay,
      child: const SizedBox.shrink(),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    final tokens = TDesignTokenScope.of(context);
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.escape): _close,
      },
      child: Focus(
        autofocus: true,
        child: Stack(
          children: [
            Positioned.fill(child: _mask(tokens)),
            _panelPosition(_panel(tokens)),
          ],
        ),
      ),
    );
  }

  Widget _mask(TDesignTokenSet tokens) {
    return GestureDetector(
      onTap: _close,
      behavior: HitTestBehavior.opaque,
      child: ColoredBox(color: tTokenColorOf(tokens, 'maskActive')),
    );
  }

  Widget _panel(TDesignTokenSet tokens) {
    return ColoredBox(
      color: tTokenColorOf(tokens, 'bgColorContainer'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
            child: Row(
              children: [
                Expanded(child: widget.header ?? const SizedBox.shrink()),
                GestureDetector(
                  onTap: _close,
                  child: TIcon(
                    TIcons.close,
                    color: tTokenColorOf(tokens, 'textColorSecondary'),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: widget.body,
            ),
          ),
        ],
      ),
    );
  }

  Widget _panelPosition(Widget panel) {
    final size = widget.size;
    switch (widget.placement) {
      case TDrawerPlacement.left:
        return Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          width: size,
          child: panel,
        );
      case TDrawerPlacement.right:
        return Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          width: size,
          child: panel,
        );
      case TDrawerPlacement.top:
        return Positioned(
          left: 0,
          right: 0,
          top: 0,
          height: size,
          child: panel,
        );
      case TDrawerPlacement.bottom:
        return Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: size,
          child: panel,
        );
    }
  }
}
