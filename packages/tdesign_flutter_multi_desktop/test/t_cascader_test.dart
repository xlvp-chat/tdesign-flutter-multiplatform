import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tdesign_flutter_multi_desktop/tdesign_flutter_multi_desktop.dart';

const _options = <TCascaderOption>[
  TCascaderOption(
    value: '1',
    label: '选项一',
    children: [
      TCascaderOption(value: '1.1', label: '子选项一'),
      TCascaderOption(value: '1.2', label: '子选项二'),
    ],
  ),
  TCascaderOption(
    value: '2',
    label: '选项二',
    children: [
      TCascaderOption(value: '2.1', label: '子选项一'),
    ],
  ),
];

void main() {
  testWidgets('picking a leaf reports the leaf value', (tester) async {
    String? picked;
    await tester.pumpWidget(
      _host(
        StatefulBuilder(
          builder: (context, setState) {
            return TCascader(
              options: _options,
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
    await tester.tap(find.text('选项一'));
    await tester.pump();
    await tester.tap(find.text('子选项二'));
    await tester.pump();
    await tester.pump();

    expect(picked, '1.2');
    expect(find.text('选项一 / 子选项二'), findsOneWidget);
  });

  testWidgets('clear removes the value', (tester) async {
    String? picked = '1.1';
    await tester.pumpWidget(
      _host(
        StatefulBuilder(
          builder: (context, setState) {
            return TCascader(
              options: _options,
              value: picked,
              clearable: true,
              onChanged: (value) => setState(() => picked = value),
            );
          },
        ),
      ),
    );

    expect(find.text('选项一 / 子选项一'), findsOneWidget);
    await tester.tap(find.byIcon(TIcons.close_circle_filled));
    await tester.pump();
    expect(picked, isNull);
    expect(find.text('请选择'), findsOneWidget);
  });

  testWidgets('showAllLevels false shows only the leaf label', (tester) async {
    await tester.pumpWidget(
      _host(
        const TCascader(
          options: _options,
          value: '1.1',
          showAllLevels: false,
        ),
      ),
    );
    expect(find.text('子选项一'), findsOneWidget);
    expect(find.text('选项一 / 子选项一'), findsNothing);
  });

  testWidgets('checkStrictly selects a parent', (tester) async {
    String? picked;
    await tester.pumpWidget(
      _host(
        StatefulBuilder(
          builder: (context, setState) {
            return TCascader(
              options: _options,
              checkStrictly: true,
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
    await tester.tap(find.text('选项一'));
    await tester.pump();
    expect(picked, '1');
  });

  testWidgets('multiple toggles leaf values and stays open', (tester) async {
    var picked = <String>[];
    await tester.pumpWidget(
      _host(
        StatefulBuilder(
          builder: (context, setState) {
            return TCascader(
              options: _options,
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
    await tester.tap(find.text('选项一'));
    await tester.pump();
    await tester.tap(find.text('子选项一'));
    await tester.pump();
    await tester.tap(find.text('子选项二'));
    await tester.pump();
    expect(picked, ['1.1', '1.2']);
    expect(find.text('子选项二'), findsWidgets);
  });

  testWidgets('filterable selects a matching path', (tester) async {
    String? picked;
    await tester.pumpWidget(
      _host(
        StatefulBuilder(
          builder: (context, setState) {
            return TCascader(
              options: _options,
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
      find.byKey(const ValueKey('TCascader.filter')),
      '子选项二',
    );
    await tester.pump();
    await tester.tap(find.text('选项一 / 子选项二'));
    await tester.pump();
    expect(picked, '1.2');
  });
}

Widget _host(Widget child) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: Overlay(
      initialEntries: [
        OverlayEntry(
          builder: (context) => Center(child: SizedBox(width: 280, child: child)),
        ),
      ],
    ),
  );
}
