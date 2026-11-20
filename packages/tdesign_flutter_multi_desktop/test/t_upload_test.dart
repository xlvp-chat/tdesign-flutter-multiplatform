import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tdesign_flutter_multi_desktop/tdesign_flutter_multi_desktop.dart';

void main() {
  testWidgets('pick appends files and auto request updates status', (
    tester,
  ) async {
    var files = <TUploadFile>[];
    await tester.pumpWidget(
      _host(
        StatefulBuilder(
          builder: (context, setState) {
            return TUpload(
              files: files,
              pickFiles: () async => const [
                TUploadFile(name: 'a.txt'),
              ],
              request: (file) async =>
                  file.copyWith(status: TUploadFileStatus.success),
              onChanged: (value) => setState(() => files = value),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('选择文件'));
    await tester.pump();
    await tester.pump();

    expect(files, hasLength(1));
    expect(files.single.name, 'a.txt');
    expect(files.single.status, TUploadFileStatus.success);
    expect(find.text('a.txt'), findsOneWidget);
    expect(find.text('上传成功'), findsOneWidget);
  });

  testWidgets('remove drops a file from the list', (tester) async {
    var files = const [
      TUploadFile(name: 'a.txt', status: TUploadFileStatus.success),
    ];
    await tester.pumpWidget(
      _host(
        StatefulBuilder(
          builder: (context, setState) {
            return TUpload(
              files: files,
              pickFiles: () async => const [],
              onChanged: (value) => setState(() => files = value),
            );
          },
        ),
      ),
    );

    await tester.tap(find.byIcon(TIcons.close));
    await tester.pump();
    expect(files, isEmpty);
  });

  testWidgets('single mode replaces the previous file', (tester) async {
    var files = const [
      TUploadFile(name: 'old.txt', status: TUploadFileStatus.success),
    ];
    await tester.pumpWidget(
      _host(
        StatefulBuilder(
          builder: (context, setState) {
            return TUpload(
              files: files,
              autoUpload: false,
              pickFiles: () async => const [
                TUploadFile(name: 'new.txt'),
              ],
              onChanged: (value) => setState(() => files = value),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('选择文件'));
    await tester.pump();
    expect(files.map((file) => file.name), ['new.txt']);
  });

  testWidgets('image theme shows a tile and an add control', (tester) async {
    await tester.pumpWidget(
      _host(
        TUpload(
          theme: TUploadTheme.image,
          files: const [TUploadFile(name: 'photo.png')],
          pickFiles: () async => const [],
          onChanged: (_) {},
        ),
      ),
    );
    expect(find.text('photo.png'), findsOneWidget);
    expect(find.byKey(const ValueKey('TUpload.add')), findsOneWidget);
    expect(find.byIcon(TIcons.add), findsOneWidget);
    // Image theme uses the add tile as trigger — no text button.
    expect(find.text('选择文件'), findsNothing);
  });

  testWidgets('file-flow shows the file size', (tester) async {
    await tester.pumpWidget(
      _host(
        TUpload(
          theme: TUploadTheme.fileFlow,
          files: const [TUploadFile(name: 'a.txt', size: 2048)],
          pickFiles: () async => const [],
          onChanged: (_) {},
        ),
      ),
    );
    expect(find.text('2.0 KB'), findsOneWidget);
  });
}

Widget _host(Widget child) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: Center(child: child),
  );
}
