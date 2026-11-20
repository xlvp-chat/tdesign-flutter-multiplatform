/// Parses and resolves `--td-*` custom properties from theme CSS or Less.
class ThemeDeclarations {
  const ThemeDeclarations(this.values);

  /// Normalized declaration values, without `var()` resolution.
  final Map<String, String> values;

  static final _decl = RegExp(r'(--td-[a-z0-9-]+)\s*:\s*([^;]+);');
  static final _varRef = RegExp(r'^var\((--td-[a-z0-9-]+)\)$');

  static ThemeDeclarations parse(String source) {
    final values = <String, String>{};
    for (final match in _decl.allMatches(source)) {
      values[match.group(1)!] = normalizeDeclaration(match.group(2)!);
    }
    return ThemeDeclarations(values);
  }

  /// Resolves a single `var(--td-*)` chain. Literals are returned normalized.
  String resolve(String name) {
    final seen = <String>{};
    String walk(String key) {
      if (!seen.add(key)) {
        throw StateError('Cycle in token $key');
      }
      final raw = values[key];
      if (raw == null) {
        throw StateError('Missing token $key');
      }
      final ref = _varRef.firstMatch(raw);
      if (ref == null) return raw;
      return walk(ref.group(1)!);
    }

    return walk(name);
  }
}

/// Lowercases, strips a trailing Less comment, and expands `#rgb` to `#rrggbb`.
String normalizeDeclaration(String raw) {
  var value = raw.trim();
  final comment = value.indexOf('//');
  if (comment >= 0) value = value.substring(0, comment).trim();
  value = value.toLowerCase().replaceAll(RegExp(r'\s+'), '');
  return value.replaceAllMapped(RegExp(r'#([0-9a-f]{3})$'), (match) {
    final hex = match.group(1)!;
    return '#${hex[0]}${hex[0]}${hex[1]}${hex[1]}${hex[2]}${hex[2]}';
  });
}
