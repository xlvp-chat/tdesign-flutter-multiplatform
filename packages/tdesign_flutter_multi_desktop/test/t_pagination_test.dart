import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tdesign_flutter_multi_desktop/tdesign_flutter_multi_desktop.dart';

Widget _host(Widget child) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: Overlay(
      key: UniqueKey(),
      initialEntries: [
        OverlayEntry(
          builder: (context) =>
              Align(alignment: Alignment.topLeft, child: child),
        ),
      ],
    ),
  );
}

Future<void> _pump(
  WidgetTester tester, {
  required int total,
  required int pageSize,
  int current = 1,
  bool showJumper = false,
  List<int>? pageSizeOptions,
  List<int>? pages,
  List<int>? sizes,
}) async {
  var page = current;
  await tester.pumpWidget(
    _host(
      StatefulBuilder(
        builder: (context, setState) {
          return TPagination(
            total: total,
            pageSize: pageSize,
            current: page,
            onChanged: (next) {
              pages?.add(next);
              setState(() => page = next);
            },
            showJumper: showJumper,
            pageSizeOptions: pageSizeOptions,
            onPageSizeChanged: (next) {
              sizes?.add(next);
            },
          );
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Finder _navFinder(String label) {
  if (label == '上一页' || label == '下一页') {
    return find.ancestor(
      of: find.bySemanticsLabel(label),
      matching: find.byType(TButton),
    );
  }
  return find.widgetWithText(TButton, label);
}

TButton _button(WidgetTester tester, String label) {
  return tester.widget<TButton>(_navFinder(label));
}

void main() {
  testWidgets('shows every page number when there are at most 7 pages', (
    tester,
  ) async {
    final pages = <int>[];
    await _pump(tester, total: 30, pageSize: 10, pages: pages);

    for (final label in ['1', '2', '3']) {
      expect(find.widgetWithText(TButton, label), findsOneWidget);
    }
    expect(find.text('4'), findsNothing);
    expect(find.text('…'), findsNothing);
    expect(_button(tester, '上一页').onPressed, isNull);
    expect(_button(tester, '1').theme, TButtonTheme.primary);
    expect(_button(tester, '2').theme, TButtonTheme.defaultTheme);
    expect(_button(tester, '2').variant, TButtonVariant.outline);

    await tester.tap(find.widgetWithText(TButton, '3'));
    await tester.pumpAndSettle();
    expect(pages, [3]);
    expect(_button(tester, '下一页').onPressed, isNull);
    expect(_button(tester, '3').theme, TButtonTheme.primary);

    await tester.tap(_navFinder('上一页'));
    await tester.pumpAndSettle();
    expect(pages, [3, 2]);
  });

  testWidgets('uses one ellipsis for each skipped range when many pages', (
    tester,
  ) async {
    final pages = <int>[];
    await _pump(tester, total: 100, pageSize: 10, current: 5, pages: pages);

    for (final label in ['1', '4', '5', '6', '10']) {
      expect(find.widgetWithText(TButton, label), findsOneWidget);
    }
    for (final label in ['2', '3', '7', '8', '9']) {
      expect(find.widgetWithText(TButton, label), findsNothing);
    }
    expect(find.text('…'), findsNWidgets(2));
    expect(find.widgetWithText(TButton, '…'), findsNothing);
    expect(_button(tester, '5').theme, TButtonTheme.primary);

    await tester.tap(find.text('…').first);
    await tester.pumpAndSettle();
    expect(pages, isEmpty);

    await tester.tap(_navFinder('下一页'));
    await tester.pumpAndSettle();
    expect(pages, [6]);
  });

  testWidgets('drops a duplicate ellipsis when the window touches an end', (
    tester,
  ) async {
    await _pump(tester, total: 100, pageSize: 10, current: 1);
    for (final label in ['1', '2', '10']) {
      expect(find.widgetWithText(TButton, label), findsOneWidget);
    }
    expect(find.text('1'), findsOneWidget);
    expect(find.widgetWithText(TButton, '3'), findsNothing);
    expect(find.text('…'), findsOneWidget);

    await _pump(tester, total: 100, pageSize: 10, current: 10);
    for (final label in ['1', '9', '10']) {
      expect(find.widgetWithText(TButton, label), findsOneWidget);
    }
    expect(find.text('10'), findsOneWidget);
    expect(find.widgetWithText(TButton, '8'), findsNothing);
    expect(find.text('…'), findsOneWidget);

    await _pump(tester, total: 80, pageSize: 10, current: 3);
    for (final label in ['1', '2', '3', '4', '8']) {
      expect(find.widgetWithText(TButton, label), findsOneWidget);
    }
    expect(find.widgetWithText(TButton, '5'), findsNothing);
    expect(find.text('…'), findsOneWidget);

    await _pump(tester, total: 70, pageSize: 10, current: 4);
    for (var page = 1; page <= 7; page++) {
      expect(find.widgetWithText(TButton, '$page'), findsOneWidget);
    }
    expect(find.text('…'), findsNothing);
  });

  testWidgets('jumper clamps the entered page and stays hidden by default', (
    tester,
  ) async {
    final pages = <int>[];
    await _pump(tester, total: 100, pageSize: 10, pages: pages);
    expect(find.text('跳至'), findsNothing);
    expect(find.widgetWithText(TButton, '跳转'), findsNothing);

    await _pump(
      tester,
      total: 100,
      pageSize: 10,
      showJumper: true,
      pages: pages,
    );

    Future<void> jump(String text) async {
      await tester.enterText(find.byType(EditableText), text);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TButton, '跳转'));
      await tester.pumpAndSettle();
    }

    await jump('99');
    await jump('0');
    await jump('-4');
    await jump('abc');
    await jump('   ');
    await jump('  6 ');
    expect(pages, [10, 1, 1, 6]);
  });

  testWidgets('page size control is opt-in and does not change the page', (
    tester,
  ) async {
    final pages = <int>[];
    final sizes = <int>[];
    await _pump(
      tester,
      total: 100,
      pageSize: 10,
      current: 4,
      pages: pages,
      sizes: sizes,
    );
    expect(find.text('10 条/页'), findsNothing);

    await _pump(
      tester,
      total: 100,
      pageSize: 10,
      current: 4,
      pages: pages,
      sizes: sizes,
      pageSizeOptions: const [5, 10, 20, 50],
    );
    expect(find.text('10 条/页'), findsOneWidget);
    expect(find.text('20 条/页'), findsNothing);
    expect(_button(tester, '4').theme, TButtonTheme.primary);

    await tester.tap(find.text('10 条/页'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('20 条/页'));
    await tester.pumpAndSettle();

    expect(sizes, [20]);
    expect(pages, isEmpty);
    expect(_button(tester, '4').theme, TButtonTheme.primary);
  });

  testWidgets('simple theme shows current over page count', (tester) async {
    final pages = <int>[];
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: StatefulBuilder(
          builder: (context, setState) {
            return TPagination(
              total: 100,
              pageSize: 10,
              current: pages.isEmpty ? 2 : pages.last,
              theme: TPaginationTheme.simple,
              onChanged: (page) => setState(() => pages.add(page)),
            );
          },
        ),
      ),
    );

    expect(find.text('2 / 10'), findsOneWidget);
    expect(find.text('3'), findsNothing);
    await tester.tap(_navFinder('下一页'));
    await tester.pump();
    expect(pages, [3]);
    expect(find.text('3 / 10'), findsOneWidget);
  });
}
