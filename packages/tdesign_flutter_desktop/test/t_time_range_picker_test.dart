import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tdesign_flutter_desktop/tdesign_flutter_desktop.dart';

void main() {
  testWidgets('picking start and end updates the range label', (tester) async {
    var range = const TTimeRange();
    await tester.pumpWidget(
      _host(
        StatefulBuilder(
          builder: (context, setState) {
            return TTimeRangePicker(
              value: range,
              onChanged: (value) => setState(() => range = value),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('请选择时间区间'));
    await tester.pump();
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('start-hour-1')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('end-hour-2')));
    await tester.pump();

    expect(range.start, const TTime(hour: 1, minute: 0));
    expect(range.end?.hour, 2);
    expect(find.textContaining('至'), findsOneWidget);
  });

  testWidgets('clear resets both ends', (tester) async {
    var range = const TTimeRange(
      start: TTime(hour: 8, minute: 0),
      end: TTime(hour: 18, minute: 0),
    );
    await tester.pumpWidget(
      _host(
        StatefulBuilder(
          builder: (context, setState) {
            return TTimeRangePicker(
              value: range,
              clearable: true,
              showSeconds: false,
              onChanged: (value) => setState(() => range = value),
            );
          },
        ),
      ),
    );

    expect(find.text('08:00 至 18:00'), findsOneWidget);
    await tester.tap(find.text('×'));
    await tester.pump();
    expect(range.isEmpty, isTrue);
  });

  testWidgets('typed range and preset commit both ends', (tester) async {
    var range = const TTimeRange();
    await tester.pumpWidget(
      _host(
        StatefulBuilder(
          builder: (context, setState) {
            return TTimeRangePicker(
              value: range,
              allowInput: true,
              showSeconds: false,
              presets: [
                TTimeRangePreset(
                  label: '工作时间',
                  range: () => const TTimeRange(
                    start: TTime(hour: 9, minute: 0),
                    end: TTime(hour: 18, minute: 0),
                  ),
                ),
              ],
              onChanged: (value) => setState(() => range = value),
            );
          },
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('TTimeRangePicker.open')));
    await tester.pump();
    await tester.pump();
    await tester.tap(find.text('工作时间'));
    await tester.pump();
    expect(range.start, const TTime(hour: 9, minute: 0));
    expect(range.end, const TTime(hour: 18, minute: 0));

    await tester.enterText(
      find.byKey(const ValueKey('TTimeRangePicker.input')),
      '10:30 至 11:00',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(range.start, const TTime(hour: 10, minute: 30));
    expect(range.end, const TTime(hour: 11, minute: 0));
  });

  testWidgets('disableTime hides a blocked hour', (tester) async {
    await tester.pumpWidget(
      _host(
        TTimeRangePicker(
          value: const TTimeRange(
            start: TTime(hour: 1, minute: 0),
            end: TTime(hour: 2, minute: 0),
          ),
          showSeconds: false,
          disableTime: (hour, minute, second) =>
              const TDisabledTime(hour: [0]),
          onChanged: (_) {},
        ),
      ),
    );
    await tester.tap(find.text('01:00 至 02:00'));
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const ValueKey('start-hour-0')), findsNothing);
    expect(find.byKey(const ValueKey('start-hour-1')), findsOneWidget);
  });
}

Widget _host(Widget child) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: Overlay(
      initialEntries: [
        OverlayEntry(
          builder: (context) =>
              Center(child: SizedBox(width: 360, child: child)),
        ),
      ],
    ),
  );
}
