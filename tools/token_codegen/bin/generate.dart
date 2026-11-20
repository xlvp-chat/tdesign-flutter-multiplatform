import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:token_codegen/dart_emitter.dart';
import 'package:token_codegen/desktop_token_css.dart';

/// Phase 0 Token PoC entry.
///
/// Usage:
///   dart run bin/generate.dart --demo
///   dart run bin/generate.dart --light <light.css> --dark <dark.css> --out <file.dart>
Future<void> main(List<String> args) async {
  if (args.contains('--demo') || args.isEmpty) {
    await _writeDemo();
    return;
  }

  String? lightPath;
  String? darkPath;
  String? outPath;
  for (var i = 0; i < args.length; i++) {
    switch (args[i]) {
      case '--light':
        lightPath = args[++i];
      case '--dark':
        darkPath = args[++i];
      case '--out':
        outPath = args[++i];
      default:
        stderr.writeln('Unknown arg: ${args[i]}');
        exitCode = 64;
        return;
    }
  }

  if (lightPath == null || darkPath == null || outPath == null) {
    stderr.writeln(
      'Required: --light <css> --dark <css> --out <dart>  (or --demo)',
    );
    exitCode = 64;
    return;
  }

  final lightCss = await File(lightPath).readAsString();
  final darkCss = await File(darkPath).readAsString();
  final dart = emitTDesignTokensDart(
    tokensFromCss(lightCss: lightCss, darkCss: darkCss),
  );
  final out = File(outPath);
  await out.parent.create(recursive: true);
  await out.writeAsString(dart);
  stdout.writeln('Wrote ${out.path}');
}

Future<void> _writeDemo() async {
  final dart = emitTDesignTokensDart(
    tokensFromCss(
      lightCss: desktopLightTokenCss,
      darkCss: desktopDarkTokenCss,
    ),
  );

  // Prefer package-relative path when run from tools/token_codegen.
  final candidates = <String>[
    p.join(
      Directory.current.path,
      '..',
      '..',
      'packages',
      'tdesign_flutter_multi_core',
      'lib',
      'src',
      'token',
      'tdesign_tokens.g.dart',
    ),
    p.join(
      Directory.current.path,
      'packages',
      'tdesign_flutter_multi_core',
      'lib',
      'src',
      'token',
      'tdesign_tokens.g.dart',
    ),
  ];

  final out = File(p.normalize(candidates.first));
  await out.parent.create(recursive: true);
  await out.writeAsString(dart);
  stdout.writeln('Demo tokens written to ${out.path}');
}
