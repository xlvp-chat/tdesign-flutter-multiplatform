import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tdesign_flutter_desktop/tdesign_flutter_desktop.dart';

const _items = <TTreeNode>[
  TTreeNode(
    value: 'guangdong',
    label: '广东省',
    children: [
      TTreeNode(value: 'guangzhou', label: '广州市'),
      TTreeNode(value: 'shenzhen', label: '深圳市'),
    ],
  ),
  TTreeNode(
    value: 'jiangsu',
    label: '江苏省',
    disabled: true,
    children: [
      TTreeNode(value: 'nanjing', label: '南京市'),
    ],
  ),
];

void main() {
  testWidgets('picking a node reports its value', (tester) async {
    String? picked;
    await tester.pumpWidget(
      _host(
        StatefulBuilder(
          builder: (context, setState) {
            return TTreeSelect(
              items: _items,
              value: picked,
              onChanged: (value) => setState(() => picked = value),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('请选择'));
    await tester.pump();
    await tester.pump();
    await tester.tap(find.text('▸').first);
    await tester.pump();
    await tester.tap(find.text('深圳市'));
    await tester.pump();
    await tester.pump();

    expect(picked, 'shenzhen');
    expect(find.text('深圳市'), findsOneWidget);
  });

  testWidgets('clear removes the value', (tester) async {
    String? picked = 'guangzhou';
    await tester.pumpWidget(
      _host(
        StatefulBuilder(
          builder: (context, setState) {
            return TTreeSelect(
              items: _items,
              value: picked,
              clearable: true,
              onChanged: (value) => setState(() => picked = value),
            );
          },
        ),
      ),
    );

    expect(find.text('广州市'), findsOneWidget);
    await tester.tap(find.text('×'));
    await tester.pump();
    expect(picked, isNull);
  });

  testWidgets('multiple checks leaves and keeps the popup open', (tester) async {
    var picked = <String>[];
    await tester.pumpWidget(
      _host(
        StatefulBuilder(
          builder: (context, setState) {
            return TTreeSelect(
              items: _items,
              multiple: true,
              values: picked,
              onValuesChanged: (value) => setState(() => picked = value),
            );
          },
        ),
      ),
    );
    await tester.tap(find.text('请选择'));
    await tester.pump();
    await tester.pump();
    await tester.tap(find.text('▸').first);
    await tester.pump();
    await tester.tap(find.text('广州市'));
    await tester.pump();
    await tester.tap(find.text('深圳市'));
    await tester.pump();
    expect(picked, containsAll(<String>['guangzhou', 'shenzhen']));
    expect(find.text('广州市'), findsWidgets);
  });

  testWidgets('filterable reveals a matching node', (tester) async {
    String? picked;
    await tester.pumpWidget(
      _host(
        StatefulBuilder(
          builder: (context, setState) {
            return TTreeSelect(
              items: _items,
              filterable: true,
              value: picked,
              onChanged: (value) => setState(() => picked = value),
            );
          },
        ),
      ),
    );
    await tester.tap(find.text('请选择'));
    await tester.pump();
    await tester.pump();
    await tester.enterText(
      find.byKey(const ValueKey('TTreeSelect.filter')),
      '深圳',
    );
    await tester.pump();
    expect(find.text('深圳市'), findsOneWidget);
    expect(find.text('广州市'), findsNothing);
    await tester.tap(find.text('深圳市'));
    await tester.pump();
    expect(picked, 'shenzhen');
  });
}

Widget _host(Widget child) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: Overlay(
      initialEntries: [
        OverlayEntry(
          builder: (context) =>
              Center(child: SizedBox(width: 280, child: child)),
        ),
      ],
    ),
  );
}
