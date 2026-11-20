import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('gallery sources match the locked Vue Next example pages', () {
    final lock =
        jsonDecode(File('visual/vue_reference.lock.json').readAsStringSync())
            as Map<String, Object?>;
    final revision = lock['revision'] as String;
    expect(revision, hasLength(40));
    expect(
      lock['sourceRoot'],
      'tdesign-vue-next/packages/components',
    );

    final pages = (lock['pages']! as Map).cast<String, Object?>();
    final sources = <String>{};
    final sourcePattern = RegExp(r"source:\s*'([^']+)'");
    for (final entity in Directory('lib/gallery/pages').listSync()) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      for (final match in sourcePattern.allMatches(entity.readAsStringSync())) {
        sources.add(match.group(1)!);
      }
    }

    expect(sources, pages.keys.toSet());
    for (final entry in pages.entries) {
      final files = (entry.value! as List).cast<String>();
      expect(files, isNotEmpty, reason: entry.key);
      for (final name in files) {
        expect(name, endsWith('.vue'), reason: entry.key);
      }
    }
  });
}
