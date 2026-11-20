import 'dart:convert';
import 'dart:io';

import 'package:token_codegen/theme_declarations.dart';

/// Writes `common/web-theme.lock.json` from a tdesign-vue-next checkout.
///
/// ```bash
/// dart run bin/lock_common.dart --root C:\path\to\tdesign-vue-next
/// ```
void main(List<String> args) {
  final rootFlag = args.indexOf('--root');
  if (rootFlag < 0 || rootFlag + 1 >= args.length) {
    stderr.writeln('Usage: dart run bin/lock_common.dart --root <tdesign-vue-next>');
    exitCode = 64;
    return;
  }
  final root = Directory(args[rootFlag + 1]);
  final theme = Directory(
    '${root.path}/packages/common/style/web/theme',
  );
  final light = File('${theme.path}/_light.less');
  final dark = File('${theme.path}/_dark.less');
  final radius = File('${theme.path}/_radius.less');
  if (!light.existsSync() || !dark.existsSync() || !radius.existsSync()) {
    stderr.writeln('Theme files not found under ${theme.path}');
    exitCode = 1;
    return;
  }

  final revision = Process.runSync('git', [
    '-C',
    root.path,
    'rev-parse',
    'HEAD',
  ]);
  if (revision.exitCode != 0) {
    stderr.writeln(revision.stderr);
    exitCode = revision.exitCode;
    return;
  }

  final radiusValue = ThemeDeclarations.parse(radius.readAsStringSync())
      .values['--td-radius-default'];
  if (radiusValue == null) {
    stderr.writeln('Missing --td-radius-default');
    exitCode = 1;
    return;
  }

  final lock = <String, Object>{
    'revision': (revision.stdout as String).trim(),
    'source': 'tdesign-vue-next/packages/common/style/web/theme',
    'radiusDefault': radiusValue,
    'light': ThemeDeclarations.parse(light.readAsStringSync()).values,
    'dark': ThemeDeclarations.parse(dark.readAsStringSync()).values,
  };
  final out = File('common/web-theme.lock.json');
  out.parent.createSync(recursive: true);
  out.writeAsStringSync('${const JsonEncoder.withIndent('  ').convert(lock)}\n');
  stdout.writeln('Wrote ${out.path} at ${lock['revision']}');
}
