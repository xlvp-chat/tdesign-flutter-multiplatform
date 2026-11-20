import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:token_codegen/desktop_token_css.dart';
import 'package:token_codegen/theme_declarations.dart';

/// Phase 0 values that intentionally differ from the locked tdesign-common
/// revision. Every other `--td-*` declaration in the desktop CSS must resolve
/// to the same color as that revision.
const _pocOverrides = <String, Map<String, String>>{
  'light': {'--td-text-color-primary': '#000000'},
  'dark': {
    '--td-brand-color-7': '#4582e6',
    '--td-text-color-primary': '#ffffff',
  },
};

void main() {
  final lock = jsonDecode(
    File('common/web-theme.lock.json').readAsStringSync(),
  ) as Map<String, Object?>;
  final revision = lock['revision'] as String;
  final light = ThemeDeclarations(
    Map<String, String>.from(lock['light']! as Map),
  );
  final dark = ThemeDeclarations(
    Map<String, String>.from(lock['dark']! as Map),
  );

  test('desktop token CSS matches locked common $revision', () {
    expect(lock['source'], 'tdesign-vue-next/packages/common/style/web/theme');
    expect(revision, hasLength(40));
    _expectMode(
      desktop: ThemeDeclarations.parse(desktopLightTokenCss),
      common: light,
      overrides: _pocOverrides['light']!,
      radius: lock['radiusDefault'] as String,
    );
    _expectMode(
      desktop: ThemeDeclarations.parse(desktopDarkTokenCss),
      common: dark,
      overrides: _pocOverrides['dark']!,
      radius: lock['radiusDefault'] as String,
    );
  });
}

void _expectMode({
  required ThemeDeclarations desktop,
  required ThemeDeclarations common,
  required Map<String, String> overrides,
  required String radius,
}) {
  expect(desktop.resolve('--td-radius-default'), radius);
  for (final entry in overrides.entries) {
    expect(desktop.resolve(entry.key), entry.value, reason: entry.key);
    expect(
      common.resolve(entry.key),
      isNot(entry.value),
      reason: '${entry.key} is no longer a PoC override',
    );
  }
  for (final name in desktop.values.keys) {
    if (name == '--td-radius-default' || overrides.containsKey(name)) {
      continue;
    }
    expect(desktop.resolve(name), common.resolve(name), reason: name);
  }
}
