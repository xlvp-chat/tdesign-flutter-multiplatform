import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tdesign_flutter_multi_desktop/tdesign_flutter_multi_desktop.dart';

void main() {
  testWidgets('two clicks emit a complete range', (tester) async {
    var range = const TDateRange();
    await tester.pumpWidget(
      _host(
        StatefulBuilder(
          builder: (context, setState) {
            return TDateRangePicker(
              value: range,
              onChanged: (value) => setState(() => range = value),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('请选择日期区间'));
    await tester.pump();
    await tester.pump();

    await tester.tap(find.text('10').first);
    await tester.pump();
    await tester.tap(find.text('15').first);
    await tester.pump();
    await tester.pump();

    expect(range.isComplete, isTrue);
    expect(range.start!.day, 10);
    expect(range.end!.day, 15);
    expect(find.textContaining('至'), findsOneWidget);
  });

  testWidgets('clear resets both ends', (tester) async {
    var range = TDateRange(
      start: DateTime(2026, 3, 10),
      end: DateTime(2026, 3, 15),
    );
    await tester.pumpWidget(
      _host(
        StatefulBuilder(
          builder: (context, setState) {
            return TDateRangePicker(
              value: range,
              clearable: true,
              onChanged: (value) => setState(() => range = value),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('×'));
    await tester.pump();
    expect(range.isEmpty, isTrue);
  });

  testWidgets('preset and typed input commit the range', (tester) async {
    var range = const TDateRange();
    await tester.pumpWidget(
      _host(
        StatefulBuilder(
          builder: (context, setState) {
            return TDateRangePicker(
              value: range,
              allowInput: true,
              presets: [
                TDateRangePreset(
                  label: '本周',
                  range: () => TDateRange(
                    start: DateTime(2026, 3, 2),
                    end: DateTime(2026, 3, 8),
                  ),
                ),
              ],
              onChanged: (value) => setState(() => range = value),
            );
          },
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('TDateRangePicker.open')));
    await tester.pump();
    await tester.pump();
    await tester.tap(find.text('本周'));
    await tester.pump();
    expect(range.start, DateTime(2026, 3, 2));
    expect(range.end, DateTime(2026, 3, 8));

    await tester.enterText(
      find.byKey(const ValueKey('TDateRangePicker.input')),
      '2026-04-01 至 2026-04-03',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(range.start, DateTime(2026, 4, 1));
    expect(range.end, DateTime(2026, 4, 3));
  });

  testWidgets('enableTime defaults the end to 23:59 and steps the hour', (
    tester,
  ) async {
    var range = TDateRange(
      start: DateTime(2026, 3, 10),
      end: DateTime(2026, 3, 12, 23, 59),
    );
    await tester.pumpWidget(
      _host(
        StatefulBuilder(
          builder: (context, setState) {
            return TDateRangePicker(
              value: range,
              enableTime: true,
              onChanged: (value) => setState(() => range = value),
            );
          },
        ),
      ),
    );

    expect(find.textContaining('00:00'), findsOneWidget);
    await tester.tap(find.textContaining('00:00'));
    await tester.pump();
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('TDateRangePicker.开始-hour')));
    await tester.pump();
    expect(range.start!.hour, 1);
  });
}

Widget _host(Widget child) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: Overlay(
      initialEntries: [
        OverlayEntry(
          builder: (context) =>
              Center(child: SizedBox(width: 320, child: child)),
        ),
      ],
    ),
  );
}
