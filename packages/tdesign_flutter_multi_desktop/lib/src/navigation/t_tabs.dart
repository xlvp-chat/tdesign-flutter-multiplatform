import 'package:flutter/widgets.dart';
import 'package:tdesign_flutter_multi_core/tdesign_flutter_multi_core.dart';

import '../token/t_token_color.dart';

/// Where the tab list sits. The indicator follows the selected item.
///
/// [top] and [bottom] use a horizontal bar. [left] and [right] use a
/// vertical bar, on the edge that faces the tab content.
enum TTabPlacement { top, bottom, left, right }

/// Tab list size. Vue Next has no small tabs, so this is not [TComponentSize].
enum TTabsSize { medium, large }

/// Visual theme. Matches Vue Next `theme`: `normal` | `card`.
enum TTabsTheme {
  /// Line tabs with a track and selected indicator. Default.
  normal,

  /// Bordered cards. No track or indicator bar.
  card,
}

class TTabItem {
  const TTabItem({required this.value, required this.label});
  final String value;
  final Widget label;
}

/// Compact desktop tabs with keyboard activation via InteractiveRegion.
///
/// [placement] defaults to [TTabPlacement.top]. [size] defaults to
/// [TTabsSize.medium] (48px tall; [TTabsSize.large] is 64px). [theme]
/// defaults to [TTabsTheme.normal].
class TTabs extends StatelessWidget {
  const TTabs({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    this.placement = TTabPlacement.top,
    this.size = TTabsSize.medium,
    this.theme = TTabsTheme.normal,
  });

  final List<TTabItem> items;
  final String value;
  final ValueChanged<String> onChanged;
  final TTabPlacement placement;
  final TTabsSize size;
  final TTabsTheme theme;

  double get _itemHeight => size == TTabsSize.large ? 64 : 48;

  double get _horizontalPadding => size == TTabsSize.large ? 24 : 16;

  double get _fontSize => size == TTabsSize.large ? 16 : 14;

  @override
  Widget build(BuildContext context) {
    final colors = _TabColors.of(TDesignTokenScope.of(context));
    final tabs = <Widget>[
      for (final item in items)
        _TabButton(
          label: item.label,
          selected: item.value == value,
          height: _itemHeight,
          horizontalPadding: _horizontalPadding,
          fontSize: _fontSize,
          colors: colors,
          placement: placement,
          theme: theme,
          onActivate: () => onChanged(item.value),
        ),
    ];

    final bar = switch (placement) {
      TTabPlacement.top || TTabPlacement.bottom => Row(
        mainAxisSize: MainAxisSize.min,
        children: tabs,
      ),
      TTabPlacement.left || TTabPlacement.right => IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: tabs,
        ),
      ),
    };

    if (theme == TTabsTheme.card) return bar;

    return DecoratedBox(
      decoration: BoxDecoration(border: _trackBorder(placement, colors.track)),
      child: bar,
    );
  }
}

const _indicatorThickness = 3.0;

Border _trackBorder(TTabPlacement placement, Color track) {
  final side = BorderSide(color: track);
  return switch (placement) {
    TTabPlacement.top => Border(bottom: side),
    TTabPlacement.bottom => Border(top: side),
    TTabPlacement.left => Border(right: side),
    TTabPlacement.right => Border(left: side),
  };
}

class _TabColors {
  const _TabColors({
    required this.brand,
    required this.text,
    required this.track,
    required this.cardIdle,
    required this.cardSelected,
  });

  factory _TabColors.of(TDesignTokenSet tokens) {
    return _TabColors(
      brand: tTokenColorOf(tokens, 'brandColor7'),
      text: tTokenColorOf(tokens, 'textColorPrimary'),
      track: tTokenColorOf(tokens, 'borderLevel1Color'),
      cardIdle: tTokenColorOf(tokens, 'bgColorContainerHover'),
      cardSelected: tTokenColorOf(tokens, 'bgColorContainer'),
    );
  }

  final Color brand;
  final Color text;
  final Color track;
  final Color cardIdle;
  final Color cardSelected;
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.selected,
    required this.height,
    required this.horizontalPadding,
    required this.fontSize,
    required this.colors,
    required this.placement,
    required this.theme,
    required this.onActivate,
  });

  final Widget label;
  final bool selected;
  final double height;
  final double horizontalPadding;
  final double fontSize;
  final _TabColors colors;
  final TTabPlacement placement;
  final TTabsTheme theme;
  final VoidCallback onActivate;

  @override
  Widget build(BuildContext context) {
    return TInteractiveRegion(
      onActivate: onActivate,
      builder: (context, _) {
        final content = Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: DefaultTextStyle(
            style: TextStyle(
              color: selected ? colors.brand : colors.text,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              fontSize: fontSize,
            ),
            child: label,
          ),
        );

        if (theme == TTabsTheme.card) {
          return DecoratedBox(
            decoration: BoxDecoration(
              color: selected ? colors.cardSelected : colors.cardIdle,
              border: Border.all(color: colors.track),
            ),
            child: SizedBox(
              height: height,
              child: Align(alignment: Alignment.center, child: content),
            ),
          );
        }

        return SizedBox(
          height: height,
          child: Stack(
            fit: StackFit.loose,
            alignment: Alignment.centerLeft,
            children: [content, if (selected) _indicator()],
          ),
        );
      },
    );
  }

  Widget _indicator() {
    final bar = ColoredBox(color: colors.brand);
    return switch (placement) {
      TTabPlacement.top => Positioned(
        left: 0,
        right: 0,
        bottom: 0,
        height: _indicatorThickness,
        child: bar,
      ),
      TTabPlacement.bottom => Positioned(
        left: 0,
        right: 0,
        top: 0,
        height: _indicatorThickness,
        child: bar,
      ),
      TTabPlacement.left => Positioned(
        top: 0,
        bottom: 0,
        right: 0,
        width: _indicatorThickness,
        child: bar,
      ),
      TTabPlacement.right => Positioned(
        top: 0,
        bottom: 0,
        left: 0,
        width: _indicatorThickness,
        child: bar,
      ),
    };
  }
}
