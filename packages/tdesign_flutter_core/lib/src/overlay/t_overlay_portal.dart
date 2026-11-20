import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 't_overlay_layer.dart';

/// Placement preference for anchored popups.
enum TPlacement {
  top,
  topLeft,
  topRight,
  bottom,
  bottomLeft,
  bottomRight,
  left,
  leftTop,
  leftBottom,
  right,
  rightTop,
  rightBottom,
}

/// Options shared by Select / Dropdown / Tooltip / DatePicker popups.
class TOverlayPortalOptions {
  const TOverlayPortalOptions({
    this.preferredPlacement = TPlacement.bottomLeft,
    this.offset = Offset.zero,
    this.viewportPadding = const EdgeInsets.all(8),
    this.dismissOnOutsidePointer = true,
    this.dismissOnEscape = true,
    this.focusTrap = false,
    this.layer = TOverlayLayer.popup,
  });

  final TPlacement preferredPlacement;
  final Offset offset;
  final EdgeInsets viewportPadding;
  final bool dismissOnOutsidePointer;
  final bool dismissOnEscape;
  final bool focusTrap;
  final TOverlayLayer layer;
}

/// Anchored overlay portal (Foundation v0.1).
///
/// Contract:
/// - open/close via controlled [visible] or imperative show/hide
/// - Esc / outside pointer dismiss (configurable)
/// - focus restore to the previously focused node on close
/// - preferred placement with viewport flip + shift
class TOverlayPortal extends StatefulWidget {
  const TOverlayPortal({
    super.key,
    required this.anchor,
    required this.overlayBuilder,
    this.visible,
    this.onVisibleChanged,
    this.options = const TOverlayPortalOptions(),
  });

  final Widget anchor;
  final WidgetBuilder overlayBuilder;
  final bool? visible;
  final ValueChanged<bool>? onVisibleChanged;
  final TOverlayPortalOptions options;

  @override
  State<TOverlayPortal> createState() => _TOverlayPortalState();
}

class _TOverlayPortalState extends State<TOverlayPortal> {
  final _controller = OverlayPortalController();
  final _anchorKey = GlobalKey();
  FocusNode? _previousFocus;
  late bool _visible;

  @override
  void initState() {
    super.initState();
    _visible = widget.visible ?? false;
    if (_visible) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _open());
    }
  }

  @override
  void didUpdateWidget(covariant TOverlayPortal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible == null || widget.visible == _visible) return;
    final shouldOpen = widget.visible!;
    // OverlayPortalController.show/hide must not run during build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (shouldOpen) {
        _open();
      } else {
        _close();
      }
    });
  }

  void _setVisible(bool value) {
    if (_visible == value) return;
    setState(() => _visible = value);
    widget.onVisibleChanged?.call(value);
  }

  void _open() {
    if (_controller.isShowing && _visible) return;
    _previousFocus = FocusManager.instance.primaryFocus;
    if (!_controller.isShowing) {
      _controller.show();
    }
    _setVisible(true);
  }

  void _close() {
    if (_controller.isShowing) {
      _controller.hide();
    }
    _setVisible(false);
    _previousFocus?.requestFocus();
  }

  void toggle() {
    if (_visible) {
      _close();
    } else {
      _open();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        if (widget.options.dismissOnEscape)
          const SingleActivator(LogicalKeyboardKey.escape): _close,
      },
      child: OverlayPortal(
        controller: _controller,
        overlayChildBuilder: (context) {
          return Stack(
            children: [
              if (widget.options.dismissOnOutsidePointer)
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _close,
                    child: const SizedBox.expand(),
                  ),
                ),
              _AnchoredOverlay(
                anchorKey: _anchorKey,
                placement: widget.options.preferredPlacement,
                offset: widget.options.offset,
                viewportPadding: widget.options.viewportPadding,
                child: widget.overlayBuilder(context),
              ),
            ],
          );
        },
        child: KeyedSubtree(
          key: _anchorKey,
          child: widget.anchor,
        ),
      ),
    );
  }
}

class _AnchoredOverlay extends StatelessWidget {
  const _AnchoredOverlay({
    required this.anchorKey,
    required this.placement,
    required this.offset,
    required this.viewportPadding,
    required this.child,
  });

  final GlobalKey anchorKey;
  final TPlacement placement;
  final Offset offset;
  final EdgeInsets viewportPadding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final box = anchorKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) {
      return const SizedBox.shrink();
    }
    final origin = box.localToGlobal(Offset.zero);
    final anchorSize = box.size;
    final media = MediaQuery.sizeOf(context);

    return CustomSingleChildLayout(
      delegate: _AnchorPlacementDelegate(
        anchorOrigin: origin,
        anchorSize: anchorSize,
        preferred: placement,
        offset: offset,
        viewport: media,
        padding: viewportPadding,
      ),
      child: child,
    );
  }
}

class _AnchorPlacementDelegate extends SingleChildLayoutDelegate {
  _AnchorPlacementDelegate({
    required this.anchorOrigin,
    required this.anchorSize,
    required this.preferred,
    required this.offset,
    required this.viewport,
    required this.padding,
  });

  final Offset anchorOrigin;
  final Size anchorSize;
  final TPlacement preferred;
  final Offset offset;
  final Size viewport;
  final EdgeInsets padding;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return constraints.loosen();
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    var placement = preferred;
    var pos = _rawPosition(placement, childSize) + offset;

    // Flip vertically when overflowing.
    if (_overflowsBottom(pos, childSize) && _isBottom(placement)) {
      placement = _flipVertical(placement);
      pos = _rawPosition(placement, childSize) + offset;
    } else if (_overflowsTop(pos) && _isTop(placement)) {
      placement = _flipVertical(placement);
      pos = _rawPosition(placement, childSize) + offset;
    }

    // Flip horizontally when overflowing.
    if (_overflowsRight(pos, childSize) && _isRightish(placement)) {
      placement = _flipHorizontal(placement);
      pos = _rawPosition(placement, childSize) + offset;
    } else if (_overflowsLeft(pos) && _isLeftish(placement)) {
      placement = _flipHorizontal(placement);
      pos = _rawPosition(placement, childSize) + offset;
    }

    // Shift into viewport.
    final minX = padding.left;
    final minY = padding.top;
    final maxX = viewport.width - padding.right - childSize.width;
    final maxY = viewport.height - padding.bottom - childSize.height;
    return Offset(
      pos.dx.clamp(minX, maxX < minX ? minX : maxX),
      pos.dy.clamp(minY, maxY < minY ? minY : maxY),
    );
  }

  Offset _rawPosition(TPlacement placement, Size childSize) {
    switch (placement) {
      case TPlacement.bottom:
        return Offset(
          anchorOrigin.dx + (anchorSize.width - childSize.width) / 2,
          anchorOrigin.dy + anchorSize.height,
        );
      case TPlacement.bottomLeft:
        return Offset(anchorOrigin.dx, anchorOrigin.dy + anchorSize.height);
      case TPlacement.bottomRight:
        return Offset(
          anchorOrigin.dx + anchorSize.width - childSize.width,
          anchorOrigin.dy + anchorSize.height,
        );
      case TPlacement.top:
        return Offset(
          anchorOrigin.dx + (anchorSize.width - childSize.width) / 2,
          anchorOrigin.dy - childSize.height,
        );
      case TPlacement.topLeft:
        return Offset(anchorOrigin.dx, anchorOrigin.dy - childSize.height);
      case TPlacement.topRight:
        return Offset(
          anchorOrigin.dx + anchorSize.width - childSize.width,
          anchorOrigin.dy - childSize.height,
        );
      case TPlacement.left:
      case TPlacement.leftTop:
        return Offset(
          anchorOrigin.dx - childSize.width,
          anchorOrigin.dy,
        );
      case TPlacement.leftBottom:
        return Offset(
          anchorOrigin.dx - childSize.width,
          anchorOrigin.dy + anchorSize.height - childSize.height,
        );
      case TPlacement.right:
      case TPlacement.rightTop:
        return Offset(anchorOrigin.dx + anchorSize.width, anchorOrigin.dy);
      case TPlacement.rightBottom:
        return Offset(
          anchorOrigin.dx + anchorSize.width,
          anchorOrigin.dy + anchorSize.height - childSize.height,
        );
    }
  }

  bool _overflowsBottom(Offset pos, Size child) =>
      pos.dy + child.height > viewport.height - padding.bottom;
  bool _overflowsTop(Offset pos) => pos.dy < padding.top;
  bool _overflowsRight(Offset pos, Size child) =>
      pos.dx + child.width > viewport.width - padding.right;
  bool _overflowsLeft(Offset pos) => pos.dx < padding.left;

  bool _isBottom(TPlacement p) =>
      p == TPlacement.bottom ||
      p == TPlacement.bottomLeft ||
      p == TPlacement.bottomRight;
  bool _isTop(TPlacement p) =>
      p == TPlacement.top ||
      p == TPlacement.topLeft ||
      p == TPlacement.topRight;
  bool _isRightish(TPlacement p) =>
      p == TPlacement.right ||
      p == TPlacement.rightTop ||
      p == TPlacement.rightBottom ||
      p == TPlacement.bottomRight ||
      p == TPlacement.topRight;
  bool _isLeftish(TPlacement p) =>
      p == TPlacement.left ||
      p == TPlacement.leftTop ||
      p == TPlacement.leftBottom ||
      p == TPlacement.bottomLeft ||
      p == TPlacement.topLeft;

  TPlacement _flipVertical(TPlacement p) {
    switch (p) {
      case TPlacement.bottom:
        return TPlacement.top;
      case TPlacement.bottomLeft:
        return TPlacement.topLeft;
      case TPlacement.bottomRight:
        return TPlacement.topRight;
      case TPlacement.top:
        return TPlacement.bottom;
      case TPlacement.topLeft:
        return TPlacement.bottomLeft;
      case TPlacement.topRight:
        return TPlacement.bottomRight;
      default:
        return p;
    }
  }

  TPlacement _flipHorizontal(TPlacement p) {
    switch (p) {
      case TPlacement.left:
        return TPlacement.right;
      case TPlacement.leftTop:
        return TPlacement.rightTop;
      case TPlacement.leftBottom:
        return TPlacement.rightBottom;
      case TPlacement.right:
        return TPlacement.left;
      case TPlacement.rightTop:
        return TPlacement.leftTop;
      case TPlacement.rightBottom:
        return TPlacement.leftBottom;
      case TPlacement.bottomLeft:
        return TPlacement.bottomRight;
      case TPlacement.bottomRight:
        return TPlacement.bottomLeft;
      case TPlacement.topLeft:
        return TPlacement.topRight;
      case TPlacement.topRight:
        return TPlacement.topLeft;
      default:
        return p;
    }
  }

  @override
  bool shouldRelayout(covariant _AnchorPlacementDelegate oldDelegate) {
    return anchorOrigin != oldDelegate.anchorOrigin ||
        anchorSize != oldDelegate.anchorSize ||
        preferred != oldDelegate.preferred ||
        offset != oldDelegate.offset ||
        viewport != oldDelegate.viewport ||
        padding != oldDelegate.padding;
  }
}
