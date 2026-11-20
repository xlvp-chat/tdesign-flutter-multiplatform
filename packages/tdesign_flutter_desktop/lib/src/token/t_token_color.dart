import 'package:flutter/widgets.dart';
import 'package:tdesign_flutter_core/tdesign_flutter_core.dart';

/// Reads a color from [TDesignTokenScope], with an optional hex [fallback].
Color tTokenColor(BuildContext context, String key, {String? fallback}) {
  return tTokenColorOf(TDesignTokenScope.of(context), key, fallback: fallback);
}

/// Reads a color from an already-resolved [TDesignTokenSet].
Color tTokenColorOf(TDesignTokenSet tokens, String key, {String? fallback}) {
  final hex = tokens.colors[key] ?? fallback;
  if (hex == null || hex.isEmpty) {
    throw StateError('Missing TDesign color token $key');
  }
  return parseTokenColor(hex);
}

/// Outer shadow layers for [key], usually `shadow1` or `shadow2`.
List<BoxShadow> tTokenShadows(TDesignTokenSet tokens, String key) {
  final layers = tokens.shadows[key];
  if (layers == null) {
    throw StateError('Missing TDesign shadow token $key');
  }
  return [
    for (final layer in layers)
      BoxShadow(
        color: parseTokenColor(layer.color),
        blurRadius: layer.blurRadius,
        spreadRadius: layer.spreadRadius,
        offset: Offset(layer.dx, layer.dy),
      ),
  ];
}

/// Corner radius from [tokens.radii], defaulting to [fallback] (usually 3).
double tTokenRadius(
  TDesignTokenSet tokens, {
  String key = 'radiusDefault',
  double fallback = 3,
}) {
  return tokens.radii[key] ?? fallback;
}

/// Parses `#RRGGBB` or `#AARRGGBB` from token codegen.
Color parseTokenColor(String hex) {
  var value = hex.replaceFirst('#', '');
  if (value.length == 6) value = 'FF$value';
  return Color(int.parse(value, radix: 16));
}
