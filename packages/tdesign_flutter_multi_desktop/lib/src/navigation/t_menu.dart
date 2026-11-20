import 'package:flutter/widgets.dart';
import 'package:tdesign_flutter_multi_core/tdesign_flutter_multi_core.dart';

import '../token/t_token_color.dart';

/// Component-local menu surface. This does not switch the app theme.
enum TMenuTheme {
  /// Light container from the current [TDesignTokenScope] (`bgColorContainer`).
  ///
  /// With no scope that is [TDesignTokens.light]. Labels use `textColorPrimary`.
  light,

  /// Dark surface from [TDesignTokens.dark], provided to this menu's subtree.
  ///
  /// Background is dark `bgColorContainer` (`#242424`). Idle labels use dark
  /// `textColorAnti`. This does not switch the surrounding scope.
  dark,
}

/// Root layout of [TMenu].
enum TMenuAxis {
  /// Nested items stay in the list and indent to the right. Default.
  vertical,

  /// Top bar. Nested items open in an overlay instead of indenting.
  horizontal,
}

class TMenuItem {
  const TMenuItem({
    required this.value,
    required this.label,
    this.icon,
    this.children = const [],
  });

  final String value;
  final Widget label;

  /// Optional leading icon. Nothing is reserved when this is null.
  final Widget? icon;
  final List<TMenuItem> children;
}

/// Desktop side/top menu with optional nested groups.
///
/// [theme] defaults to [TMenuTheme.light]. [axis] defaults to
/// [TMenuAxis.vertical]. [width] and [collapsed] apply to the vertical axis;
/// a horizontal menu sizes to its items.
class TMenu extends StatelessWidget {
  const TMenu({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    this.theme = TMenuTheme.light,
    this.axis = TMenuAxis.vertical,
    this.collapsed = false,
    this.width = 200,
  });

  final List<TMenuItem> items;
  final String? value;
  final ValueChanged<String> onChanged;
  final TMenuTheme theme;
  final TMenuAxis axis;
  final bool collapsed;
  final double width;

  @override
  Widget build(BuildContext context) {
    final tokens = theme == TMenuTheme.dark
        ? TDesignTokens.dark
        : TDesignTokenScope.of(context);
    final palette = _MenuPalette.of(tokens, theme);
    final decoration = _surfaceDecoration(palette, axis);
    final Widget surface;
    if (axis == TMenuAxis.horizontal) {
      surface = DecoratedBox(
        decoration: decoration,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final item in items)
              _horizontalNode(
                item: item,
                palette: palette,
                selectedValue: value,
                onChanged: onChanged,
              ),
          ],
        ),
      );
    } else {
      surface = SizedBox(
        width: collapsed ? 64 : width,
        child: DecoratedBox(
          decoration: decoration,
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              for (final item in items)
                ..._verticalItems(
                  item: item,
                  depth: 0,
                  palette: palette,
                  value: value,
                  onChanged: onChanged,
                ),
            ],
          ),
        ),
      );
    }
    return TDesignTokenScope(tokens: tokens, child: surface);
  }
}

BoxDecoration _surfaceDecoration(_MenuPalette palette, TMenuAxis axis) {
  final side = BorderSide(color: palette.border);
  return BoxDecoration(
    color: palette.background,
    border: axis == TMenuAxis.horizontal
        ? Border(bottom: side)
        : Border(right: side),
  );
}

Widget _horizontalNode({
  required TMenuItem item,
  required _MenuPalette palette,
  required String? selectedValue,
  required ValueChanged<String> onChanged,
}) {
  if (item.children.isEmpty) {
    return _MenuEntry(
      item: item,
      palette: palette,
      depth: 0,
      selected: item.value == selectedValue,
      onActivate: () => onChanged(item.value),
    );
  }
  return _MenuSubmenu(
    item: item,
    palette: palette,
    selectedValue: selectedValue,
    placement: TPlacement.bottomLeft,
    onChanged: onChanged,
  );
}

List<Widget> _verticalItems({
  required TMenuItem item,
  required int depth,
  required _MenuPalette palette,
  required String? value,
  required ValueChanged<String> onChanged,
}) {
  return <Widget>[
    _MenuEntry(
      item: item,
      palette: palette,
      depth: depth,
      selected: item.value == value,
      expandLabel: true,
      onActivate: item.children.isEmpty ? () => onChanged(item.value) : null,
    ),
    for (final child in item.children)
      ..._verticalItems(
        item: child,
        depth: depth + 1,
        palette: palette,
        value: value,
        onChanged: onChanged,
      ),
  ];
}

class _MenuSubmenu extends StatefulWidget {
  const _MenuSubmenu({
    required this.item,
    required this.palette,
    required this.selectedValue,
    required this.placement,
    required this.onChanged,
  });

  final TMenuItem item;
  final _MenuPalette palette;
  final String? selectedValue;
  final TPlacement placement;
  final ValueChanged<String> onChanged;

  @override
  State<_MenuSubmenu> createState() => _MenuSubmenuState();
}

class _MenuSubmenuState extends State<_MenuSubmenu> {
  var _open = false;

  void _setOpen(bool value) {
    if (_open == value) return;
    setState(() => _open = value);
  }

  @override
  Widget build(BuildContext context) {
    return TOverlayPortal(
      visible: _open,
      onVisibleChanged: _setOpen,
      options: TOverlayPortalOptions(
        preferredPlacement: widget.placement,
        viewportPadding: EdgeInsets.zero,
        layer: TOverlayLayer.dropdown,
      ),
      anchor: _MenuEntry(
        item: widget.item,
        palette: widget.palette,
        depth: 0,
        selected: widget.item.value == widget.selectedValue,
        onActivate: () => _setOpen(!_open),
      ),
      overlayBuilder: (context) {
        return _MenuPopup(
          palette: widget.palette,
          children: [
            for (final child in widget.item.children)
              if (child.children.isEmpty)
                _MenuEntry(
                  item: child,
                  palette: widget.palette,
                  depth: 0,
                  selected: child.value == widget.selectedValue,
                  onActivate: () {
                    widget.onChanged(child.value);
                    _setOpen(false);
                  },
                )
              else
                _MenuSubmenu(
                  item: child,
                  palette: widget.palette,
                  selectedValue: widget.selectedValue,
                  placement: TPlacement.rightTop,
                  onChanged: (value) {
                    widget.onChanged(value);
                    _setOpen(false);
                  },
                ),
          ],
        );
      },
    );
  }
}

class _MenuPopup extends StatelessWidget {
  const _MenuPopup({required this.palette, required this.children});

  final _MenuPalette palette;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.background,
        border: Border.all(color: palette.border),
        borderRadius: BorderRadius.circular(palette.radius),
        boxShadow: palette.shadow,
      ),
      child: IntrinsicWidth(
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 160),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ),
    );
  }
}

class _MenuEntry extends StatelessWidget {
  const _MenuEntry({
    required this.item,
    required this.palette,
    required this.depth,
    required this.selected,
    required this.onActivate,
    this.expandLabel = false,
  });

  final TMenuItem item;
  final _MenuPalette palette;
  final int depth;
  final bool selected;
  final VoidCallback? onActivate;

  /// Vertical rows are width-bounded. Long labels ellipsize instead of
  /// overflowing the menu. Horizontal items and popups stay shrink-wrapped.
  final bool expandLabel;

  @override
  Widget build(BuildContext context) {
    return TInteractiveRegion(
      onActivate: onActivate,
      builder: (context, state) {
        final hovered = state == TComponentState.hovered;
        final color = selected ? palette.brand : palette.text;
        return ColoredBox(
          color: selected
              ? palette.selectedBackground
              : hovered
              ? palette.hoverBackground
              : const Color(0x00000000),
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.0 + depth * 12, 10, 16, 10),
            child: Row(
              mainAxisSize: expandLabel ? MainAxisSize.max : MainAxisSize.min,
              children: [
                if (item.icon != null) ...[
                  IconTheme(
                    data: IconThemeData(color: color, size: 16),
                    child: item.icon!,
                  ),
                  const SizedBox(width: 8),
                ],
                _menuLabel(
                  item: item,
                  color: color,
                  selected: selected,
                  expandLabel: expandLabel,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Widget _menuLabel({
  required TMenuItem item,
  required Color color,
  required bool selected,
  required bool expandLabel,
}) {
  final label = DefaultTextStyle(
    style: TextStyle(
      color: color,
      fontSize: 14,
      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
    ),
    maxLines: expandLabel ? 1 : null,
    overflow: expandLabel ? TextOverflow.ellipsis : TextOverflow.clip,
    softWrap: !expandLabel,
    child: item.label,
  );
  if (!expandLabel) return label;
  return Expanded(child: label);
}

class _MenuPalette {
  const _MenuPalette({
    required this.background,
    required this.text,
    required this.brand,
    required this.selectedBackground,
    required this.hoverBackground,
    required this.border,
    required this.shadow,
    required this.radius,
  });

  factory _MenuPalette.of(TDesignTokenSet tokens, TMenuTheme theme) {
    final dark = theme == TMenuTheme.dark;
    return _MenuPalette(
      background: tTokenColorOf(tokens, 'bgColorContainer'),
      text: tTokenColorOf(tokens, dark ? 'textColorAnti' : 'textColorPrimary'),
      brand: tTokenColorOf(tokens, 'brandColor7'),
      selectedBackground: tTokenColorOf(
        tokens,
        dark ? 'grayColor11' : 'brandColorLight',
      ),
      hoverBackground: tTokenColorOf(tokens, 'bgColorContainerHover'),
      border: tTokenColorOf(tokens, 'borderLevel1Color'),
      shadow: tTokenShadows(tokens, 'shadow1'),
      radius: tTokenRadius(tokens),
    );
  }

  final Color background;
  final Color text;
  final Color brand;
  final Color selectedBackground;
  final Color hoverBackground;
  final Color border;
  final List<BoxShadow> shadow;
  final double radius;
}
