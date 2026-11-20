import 'package:css2token/css2token.dart';

/// Light/dark token pair for Dart emission.
class FlutterThemeTokensPair {
  const FlutterThemeTokensPair({required this.light, required this.dark});

  final FlutterThemeTokens light;
  final FlutterThemeTokens dark;
}

/// Builds a pair from CSS strings via css2token.
FlutterThemeTokensPair tokensFromCss({
  required String lightCss,
  required String darkCss,
}) {
  final theme = cssToFlutterTokens(lightCss: lightCss, darkCss: darkCss);
  final json = theme.toJson();
  return FlutterThemeTokensPair(
    light: _finishTokens(_tokensFromJson(json['light']! as Map), lightCss),
    dark: _finishTokens(_tokensFromJson(json['dark']! as Map), darkCss),
  );
}

FlutterThemeTokens _finishTokens(FlutterThemeTokens tokens, String css) {
  return _recordContainerHover(_materializeAliasColors(tokens), css);
}

/// Writes `bgColorContainerHover` when the CSS declares the tdesign-common
/// variable. A direct color refs itself. A `var(--td-…-color-N)` refs that
/// palette leaf. Declaring the gray ramp is not required, and this does not
/// add `grayColor13`.
FlutterThemeTokens _recordContainerHover(
    FlutterThemeTokens tokens, String css) {
  final variables = parseCssVariables(css);
  if (!variables.containsKey(_containerHoverCss)) return tokens;
  final resolved = _resolveCssColor(variables, _containerHoverCss);
  if (resolved == null) return tokens;
  final colors = Map<String, Object>.from(tokens.color);
  final refs = Map<String, Object>.from(tokens.ref);
  colors[_containerHoverToken] = resolved;
  refs[_containerHoverToken] =
      _paletteLeaf(variables, _containerHoverCss) ?? _containerHoverToken;
  return FlutterThemeTokens(
    ref: refs,
    color: colors,
    font: tokens.font,
    fontMetric: tokens.fontMetric,
    radius: tokens.radius,
    shadow: tokens.shadow,
    insetShadow: tokens.insetShadow,
    margin: tokens.margin,
    fontFamily: tokens.fontFamily,
    size: tokens.size,
  );
}

String? _resolveCssColor(
  Map<String, String> variables,
  String name, [
  Set<String>? seen,
]) {
  final visiting = {...?seen};
  if (!visiting.add(name)) return null;
  final raw = variables[name];
  if (raw == null) return null;
  final reference = RegExp(r'^var\(\s*(--td-[\w-]+)').firstMatch(raw);
  if (reference != null) {
    return _resolveCssColor(variables, reference.group(1)!, visiting);
  }
  return normalizeCssColor(raw);
}

String? _paletteLeaf(
  Map<String, String> variables,
  String name, [
  Set<String>? seen,
]) {
  final visiting = {...?seen};
  if (!visiting.add(name)) return null;
  final self = _cssPaletteName(name);
  if (self != null) return self;
  final raw = variables[name];
  if (raw == null) return null;
  final reference = RegExp(r'^var\(\s*(--td-[\w-]+)').firstMatch(raw);
  if (reference == null) return null;
  return _paletteLeaf(variables, reference.group(1)!, visiting);
}

String? _cssPaletteName(String name) {
  final palette = RegExp(
    r'^--td-(primary|brand|warning|error|success|gray)-color-(\d+)$',
  ).firstMatch(name);
  if (palette != null) return '${palette[1]}Color${palette[2]}';
  final font = RegExp(r'^--td-font-(white|gray)-(\d+)$').firstMatch(name);
  if (font == null) return null;
  return 'font${font[1] == 'white' ? 'White' : 'Gray'}${font[2]}';
}

/// css2token does not map `--td-bg-color-container-hover`.
const _containerHoverCss = '--td-bg-color-container-hover';

/// Dart name recorded for [_containerHoverCss].
const _containerHoverToken = 'bgColorContainerHover';

/// Copies resolved semantic aliases into [FlutterThemeTokens.color].
///
/// css2token keeps palette steps in `color` and names such as `errorColorLight`
/// in `ref`. Desktop components read `TDesignTokens.*.colors`, so each alias
/// whose leaf is already a color is repeated there under the css2token name.
/// Unmapped functional `*ColorHover` names are not invented here.
/// `_recordContainerHover` records the container hover variable separately.
FlutterThemeTokens _materializeAliasColors(FlutterThemeTokens tokens) {
  final colors = Map<String, Object>.from(tokens.color);
  for (final entry in tokens.ref.entries) {
    if (colors.containsKey(entry.key)) continue;
    final leaf = entry.value;
    if (leaf is! String) continue;
    final resolved = colors[leaf];
    if (resolved is String) colors[entry.key] = resolved;
  }
  return FlutterThemeTokens(
    ref: tokens.ref,
    color: colors,
    font: tokens.font,
    fontMetric: tokens.fontMetric,
    radius: tokens.radius,
    shadow: tokens.shadow,
    insetShadow: tokens.insetShadow,
    margin: tokens.margin,
    fontFamily: tokens.fontFamily,
    size: tokens.size,
  );
}

/// Emits a generated Dart library; preserves semantic key names.
String emitTDesignTokensDart(FlutterThemeTokensPair theme) {
  final buffer = StringBuffer()
    ..writeln('// GENERATED CODE - DO NOT EDIT BY HAND')
    ..writeln('// Source: tools/token_codegen + css2token')
    ..writeln('// ignore_for_file: public_member_api_docs')
    ..writeln()
    ..writeln('/// Semantic design tokens generated for Desktop/Mobile Core.')
    ..writeln('class TDesignTokens {')
    ..writeln('  const TDesignTokens._();')
    ..writeln()
    ..writeln('  static const light = TDesignTokenSet(')
    ..writeln(_emitMapArg('colors', theme.light.color, indent: 4))
    ..writeln(_emitMapArg('refs', theme.light.ref, indent: 4))
    ..writeln(_emitRadiusArg(theme.light.radius, indent: 4))
    ..writeln(_emitShadowArg(theme.light.shadow, indent: 4))
    ..writeln('  );')
    ..writeln()
    ..writeln('  static const dark = TDesignTokenSet(')
    ..writeln(_emitMapArg('colors', theme.dark.color, indent: 4))
    ..writeln(_emitMapArg('refs', theme.dark.ref, indent: 4))
    ..writeln(_emitRadiusArg(theme.dark.radius, indent: 4))
    ..writeln(_emitShadowArg(theme.dark.shadow, indent: 4))
    ..writeln('  );')
    ..writeln('}')
    ..writeln()
    ..writeln('class TDesignTokenSet {')
    ..writeln('  const TDesignTokenSet({')
    ..writeln('    required this.colors,')
    ..writeln('    required this.refs,')
    ..writeln('    required this.radii,')
    ..writeln('    this.shadows = const {},')
    ..writeln('  });')
    ..writeln()
    ..writeln('  final Map<String, String> colors;')
    ..writeln('  final Map<String, String> refs;')
    ..writeln('  final Map<String, double> radii;')
    ..writeln('  final Map<String, List<TDesignShadowLayer>> shadows;')
    ..writeln('}')
    ..writeln()
    ..writeln('class TDesignShadowLayer {')
    ..writeln('  const TDesignShadowLayer({')
    ..writeln('    required this.color,')
    ..writeln('    required this.blurRadius,')
    ..writeln('    required this.spreadRadius,')
    ..writeln('    required this.dx,')
    ..writeln('    required this.dy,')
    ..writeln('  });')
    ..writeln()
    ..writeln('  final String color;')
    ..writeln('  final double blurRadius;')
    ..writeln('  final double spreadRadius;')
    ..writeln('  final double dx;')
    ..writeln('  final double dy;')
    ..writeln('}')
    ..writeln();

  return buffer.toString();
}

FlutterThemeTokens _tokensFromJson(Map raw) {
  Map<String, Object> asMap(Object? value) =>
      Map<String, Object>.from((value as Map?) ?? const {});

  return FlutterThemeTokens(
    ref: asMap(raw['ref']),
    color: asMap(raw['color']),
    font: asMap(raw['font']),
    fontMetric: asMap(raw['fontMetric']),
    radius: asMap(raw['radius']),
    shadow: asMap(raw['shadow']),
    insetShadow: asMap(raw['insetShadow']),
    margin: asMap(raw['margin']),
    fontFamily: asMap(raw['fontFamily']),
    size: asMap(raw['size']),
  );
}

String _emitMapArg(
  String name,
  Map<String, Object> map, {
  required int indent,
}) {
  final pad = ' ' * indent;
  if (map.isEmpty) {
    return '$pad$name: <String, String>{},';
  }
  final entries = map.entries.map((e) {
    final escaped = e.value.toString().replaceAll("'", r"\'");
    return "$pad  '${e.key}': '$escaped',";
  });
  return '$pad$name: <String, String>{\n${entries.join('\n')}\n$pad},';
}

String _emitShadowArg(Map<String, Object> map, {required int indent}) {
  final pad = ' ' * indent;
  if (map.isEmpty) {
    return '${pad}shadows: <String, List<TDesignShadowLayer>>{},';
  }
  final entries = map.entries.map((entry) {
    final layers = entry.value;
    if (layers is! List) {
      throw StateError('Shadow ${entry.key} is not a layer list');
    }
    final body = layers.map((layer) {
      final item = Map<String, Object>.from(layer as Map);
      final offset = Map<String, Object>.from(item['offset']! as Map);
      return '''
$pad    TDesignShadowLayer(
$pad      color: '${item['color']}',
$pad      blurRadius: ${_number(item['blurRadius'])},
$pad      spreadRadius: ${_number(item['spreadRadius'])},
$pad      dx: ${_number(offset['x'])},
$pad      dy: ${_number(offset['y'])},
$pad    ),''';
    }).join('\n');
    return "$pad  '${entry.key}': <TDesignShadowLayer>[\n$body\n$pad  ],";
  });
  return '${pad}shadows: <String, List<TDesignShadowLayer>>{\n${entries.join('\n')}\n$pad},';
}

String _number(Object? value) {
  final number =
      value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
  return number.toString();
}

String _emitRadiusArg(Map<String, Object> map, {required int indent}) {
  final pad = ' ' * indent;
  if (map.isEmpty) {
    return '${pad}radii: <String, double>{},';
  }
  final entries = map.entries.map((e) {
    return "$pad  '${e.key}': ${_number(e.value)},";
  });
  return '${pad}radii: <String, double>{\n${entries.join('\n')}\n$pad},';
}
