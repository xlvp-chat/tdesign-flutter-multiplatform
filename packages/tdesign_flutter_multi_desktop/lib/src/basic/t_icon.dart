import 'package:flutter/widgets.dart';
import 'package:tdesign_flutter_icons/tdesign_flutter_icons.dart';
import 'package:tdesign_flutter_multi_core/tdesign_flutter_multi_core.dart';

import '../token/t_token_color.dart';

/// Desktop affordance icon sizes (logical px). Aligns with Vue Next defaults.
abstract final class TIconSizes {
  /// Default standalone / FakeArrow-class affordance.
  static const double medium = 16;

  /// Input suffix / clear cluster.
  static const double input = 14;

  /// Dense marks (checkbox glyph, tag close, tree caret when compact).
  static const double small = 12;

  /// Upload image add glyph.
  static const double uploadAdd = 32;
}

/// Passes resolved icon appearance to nested [TIcon]s.
///
/// Desktop-only: does **not** read Mobile Material [Theme] / `TTheme`.
class TIconStyleScope extends InheritedWidget {
  const TIconStyleScope({
    super.key,
    this.color,
    this.size,
    required super.child,
  });

  /// Inherited icon color for nested [TIcon]s.
  final Color? color;

  /// Inherited icon size for nested [TIcon]s.
  final double? size;

  static TIconStyleScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<TIconStyleScope>();

  @override
  bool updateShouldNotify(TIconStyleScope oldWidget) =>
      color != oldWidget.color || size != oldWidget.size;
}

/// Desktop icon primitive over [TIcons].
///
/// Size resolution: explicit → [TIconStyleScope] → ambient [IconTheme] →
/// [TIconSizes.medium]. Color: explicit → scope → [IconTheme] →
/// Token `textColorPrimary`.
class TIcon extends StatelessWidget {
  const TIcon(
    this.icon, {
    super.key,
    this.size,
    this.color,
    this.semanticLabel,
  });

  /// Looks up [name] in [TIcons.allIconsMap].
  factory TIcon.fromName(
    String name, {
    Key? key,
    double? size,
    Color? color,
    String? semanticLabel,
  }) {
    final iconData = TIcons.allIconsMap[name];
    if (iconData == null) {
      throw ArgumentError('Unknown icon name: $name');
    }
    return TIcon(
      iconData,
      key: key,
      size: size,
      color: color,
      semanticLabel: semanticLabel,
    );
  }

  /// Glyph from [TIcons].
  final IconData icon;

  /// Explicit size; falls back to scope / [IconTheme] / [TIconSizes.medium].
  final double? size;

  /// Explicit color; falls back to scope / [IconTheme] / token primary text.
  final Color? color;

  /// Accessibility label for the icon.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final scope = TIconStyleScope.maybeOf(context);
    final theme = IconTheme.of(context);
    final tokens = TDesignTokenScope.of(context);
    final effectiveSize =
        size ?? scope?.size ?? theme.size ?? TIconSizes.medium;
    final effectiveColor =
        color ??
        scope?.color ??
        theme.color ??
        tTokenColorOf(tokens, 'textColorPrimary');

    return Icon(
      icon,
      size: effectiveSize,
      color: effectiveColor,
      semanticLabel: semanticLabel,
      applyTextScaling: false,
    );
  }
}
