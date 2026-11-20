import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tdesign_flutter_desktop/tdesign_flutter_desktop.dart';

void main() {
  test('formats with and without seconds', () {
    const time = TTime(hour: 20, minute: 22, second: 5);
    expect(time.format(), '20:22:05');
    expect(time.format(withSeconds: false), '20:22');
  });

  testWidgets('picking hour and minute updates the value', (tester) async {
    TTime? time;
    await tester.pumpWidget(
      _host(
        StatefulBuilder(
          builder: (context, setState) {
            return TTimePicker(
              value: time,
              onChanged: (value) => setState(() => time = value),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('请选择时间'));
    await tester.pump();
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('hour-1')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('minute-2')));
    await tester.pump();

    expect(time, const TTime(hour: 1, minute: 2));
    expect(find.text('01:02:00'), findsOneWidget);
  });

  testWidgets('clear removes the value', (tester) async {
    TTime? time = const TTime(hour: 8, minute: 30);
    await tester.pumpWidget(
      _host(
        StatefulBuilder(
          builder: (context, setState) {
            return TTimePicker(
              value: time,
              clearable: true,
              onChanged: (value) => setState(() => time = value),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('×'));
    await tester.pump();

    expect(time, isNull);
    expect(find.text('请选择时间'), findsOneWidget);
  });

  testWidgets('hiding seconds omits the second column', (tester) async {
    await tester.pumpWidget(
      _host(
        TTimePicker(
          value: const TTime(hour: 9, minute: 5),
          showSeconds: false,
          onChanged: (_) {},
        ),
      ),
    );
    await tester.tap(find.text('09:05'));
    await tester.pump();
    await tester.pump();

    expect(find.byKey(const ValueKey('second-0')), findsNothing);
    expect(find.byKey(const ValueKey('minute-5')), findsOneWidget);
  });

  testWidgets('steps skip intermediate values', (tester) async {
    TTime? time = const TTime(hour: 0, minute: 0);
    await tester.pumpWidget(
      _host(
        StatefulBuilder(
          builder: (context, setState) {
            return TTimePicker(
              value: time,
              steps: const TTimeSteps(hour: 2, minute: 15, second: 30),
              onChanged: (value) => setState(() => time = value),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('00:00:00'));
    await tester.pump();
    await tester.pump();

    expect(find.byKey(const ValueKey('hour-1')), findsNothing);
    expect(find.byKey(const ValueKey('hour-2')), findsOneWidget);
    expect(find.byKey(const ValueKey('minute-15')), findsOneWidget);
    expect(find.byKey(const ValueKey('second-30')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('hour-2')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('minute-15')));
    await tester.pump();

    expect(time, const TTime(hour: 2, minute: 15));
  });

  testWidgets('disableTime hides blocked hours by default', (tester) async {
    await tester.pumpWidget(
      _host(
        TTimePicker(
          value: const TTime(hour: 0, minute: 0),
          disableTime: (h, m, s) => const TDisabledTime(hour: [1, 2]),
          onChanged: (_) {},
        ),
      ),
    );
    await tester.tap(find.text('00:00:00'));
    await tester.pump();
    await tester.pump();

    expect(find.byKey(const ValueKey('hour-1')), findsNothing);
    expect(find.byKey(const ValueKey('hour-3')), findsOneWidget);
  });

  testWidgets('allowInput commits a typed time on submit', (tester) async {
    TTime? time = const TTime(hour: 8, minute: 0);
    await tester.pumpWidget(
      _host(
        StatefulBuilder(
          builder: (context, setState) {
            return TTimePicker(
              value: time,
              allowInput: true,
              onChanged: (value) => setState(() => time = value),
            );
          },
        ),
      ),
    );
    await tester.enterText(
      find.byKey(const ValueKey<String>('TTimePicker.input')),
      '12:34:56',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(time, const TTime(hour: 12, minute: 34, second: 56));
  });

  testWidgets('preset selects that time', (tester) async {
    TTime? time;
    await tester.pumpWidget(
      _host(
        TTimePicker(
          onChanged: (value) => time = value,
          presets: [
            TTimePreset(
              label: '正午',
              time: () => const TTime(hour: 12, minute: 0),
            ),
          ],
        ),
      ),
    );
    await tester.tap(find.text('请选择时间'));
    await tester.pump();
    await tester.pump();
    await tester.tap(
      find.byKey(const ValueKey<String>('TTimePicker.preset.正午')),
    );
    await tester.pump();

    expect(time, const TTime(hour: 12, minute: 0));
  });

  test('parseTime validates ranges', () {
    expect(
      parseTime('09:05:01', withSeconds: true),
      const TTime(hour: 9, minute: 5, second: 1),
    );
    expect(parseTime('24:00:00', withSeconds: true), isNull);
    expect(
      parseTime('09:05', withSeconds: false),
      const TTime(hour: 9, minute: 5),
    );
  });
}

Widget _host(Widget child) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: Overlay(
      initialEntries: [
        OverlayEntry(
          builder: (context) =>
              Center(child: SizedBox(width: 240, child: child)),
        ),
      ],
    ),
  );
}
