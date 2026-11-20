import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tdesign_flutter_multi_desktop/tdesign_flutter_multi_desktop.dart';

const _items = <TTreeNode>[
  TTreeNode(
    value: '1',
    label: '部门一',
    children: [
      TTreeNode(value: '1.1', label: '研发'),
      TTreeNode(value: '1.2', label: '设计'),
    ],
  ),
  TTreeNode(value: '2', label: '部门二'),
];

void main() {
  testWidgets('expand reveals children', (tester) async {
    var expanded = <String>{};
    await tester.pumpWidget(
      _host(
        StatefulBuilder(
          builder: (context, setState) {
            return TTree(
              items: _items,
              expandedKeys: expanded,
              onExpandedKeysChanged: (value) {
                setState(() => expanded = value);
              },
            );
          },
        ),
      ),
    );

    expect(find.text('研发'), findsNothing);
    await tester.tap(find.text('▸'));
    await tester.pump();
    expect(find.text('研发'), findsOneWidget);
    expect(expanded, {'1'});
  });

  testWidgets('activable highlights a single node', (tester) async {
    var actived = <String>{};
    await tester.pumpWidget(
      _host(
        StatefulBuilder(
          builder: (context, setState) {
            return TTree(
              items: _items,
              expandedKeys: const {'1'},
              activable: true,
              activedKeys: actived,
              onActivedChanged: (value) {
                setState(() => actived = value);
              },
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('研发'));
    await tester.pump();
    expect(actived, {'1.1'});

    await tester.tap(find.text('设计'));
    await tester.pump();
    expect(actived, {'1.2'});
  });

  testWidgets('checkable cascades leaves in onlyLeaf mode', (tester) async {
    var checked = <String>{};
    await tester.pumpWidget(
      _host(
        StatefulBuilder(
          builder: (context, setState) {
            return TTree(
              items: _items,
              expandedKeys: const {'1'},
              checkable: true,
              checkedKeys: checked,
              onCheckedChanged: (value) {
                setState(() => checked = value);
              },
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('部门一'));
    await tester.pump();
    expect(checked, {'1.1', '1.2'});
  });

  testWidgets('checkStrictly toggles only the tapped node', (tester) async {
    var checked = <String>{};
    await tester.pumpWidget(
      _host(
        StatefulBuilder(
          builder: (context, setState) {
            return TTree(
              items: _items,
              expandedKeys: const {'1'},
              checkable: true,
              checkStrictly: true,
              checkedKeys: checked,
              onCheckedChanged: (value) {
                setState(() => checked = value);
              },
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('部门一'));
    await tester.pump();
    expect(checked, {'1'});
  });

  testWidgets('filter shows a match and its ancestors', (tester) async {
    await tester.pumpWidget(
      _host(const TTree(items: _items, filter: '研发')),
    );
    expect(find.text('部门一'), findsOneWidget);
    expect(find.text('研发'), findsOneWidget);
    expect(find.text('设计'), findsNothing);
    expect(find.text('部门二'), findsNothing);
  });
}

Widget _host(Widget child) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: Center(child: child),
  );
}
