import 'dart:io';

/// Checks product pubspec dependency keys from Spec 099.
///
/// Run from the repository root:
/// `dart tools/check_product_deps.dart`
void main() {
  final failures = <String>[];
  _check(
    failures,
    path: 'tdesign-component/example/pubspec.yaml',
    required: const {'tdesign_flutter'},
    forbidden: const {
      'tdesign_flutter_multi_core',
      'tdesign_flutter_multi_desktop',
      'tdesign_flutter_multi_adaptive',
    },
  );
  _check(
    failures,
    path: 'examples/desktop_gallery/pubspec.yaml',
    required: const {
      'tdesign_flutter_multi_core',
      'tdesign_flutter_multi_desktop',
    },
    forbidden: const {
      'tdesign_flutter',
      'tdesign_flutter_multi_adaptive',
    },
  );
  _check(
    failures,
    path: 'packages/tdesign_flutter_multi_adaptive/pubspec.yaml',
    required: const {'flutter'},
    forbidden: const {
      'tdesign_flutter',
      'tdesign_flutter_multi_core',
      'tdesign_flutter_multi_desktop',
    },
  );
  if (failures.isNotEmpty) {
    stderr.writeln(failures.join('\n'));
    exitCode = 1;
    return;
  }
  stdout.writeln('product dependency keys ok');
}

void _check(
  List<String> failures, {
  required String path,
  required Set<String> required,
  required Set<String> forbidden,
}) {
  final file = File(path);
  if (!file.existsSync()) {
    failures.add('$path: missing');
    return;
  }
  final names = _dependencyNames(file.readAsStringSync(), path, failures);
  for (final name in required) {
    if (!names.contains(name)) {
      failures.add('$path: missing dependency $name');
    }
  }
  for (final name in forbidden) {
    if (names.contains(name)) {
      failures.add('$path: forbidden dependency $name');
    }
  }
}

/// Package names directly under the root `dependencies:` map.
Set<String> _dependencyNames(
  String source,
  String path,
  List<String> failures,
) {
  final lines = source.split('\n');
  var inDependencies = false;
  final names = <String>{};
  for (final raw in lines) {
    if (raw.trimLeft().startsWith('#')) continue;
    final topLevel = RegExp(r'^[A-Za-z0-9_-]+:').hasMatch(raw);
    if (topLevel) {
      inDependencies = raw.startsWith('dependencies:');
      continue;
    }
    if (!inDependencies) continue;
    if (raw.startsWith('  ') && !raw.startsWith('    ')) {
      final match = RegExp(r'^  ([A-Za-z0-9_]+):').firstMatch(raw);
      if (match != null) names.add(match.group(1)!);
    }
  }
  if (!source.contains('\ndependencies:') &&
      !source.startsWith('dependencies:')) {
    failures.add('$path: no dependencies key');
  }
  return names;
}
