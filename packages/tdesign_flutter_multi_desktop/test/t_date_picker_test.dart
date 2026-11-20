import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tdesign_flutter_multi_desktop/tdesign_flutter_multi_desktop.dart';

void main() {
  test('calendar starts on Sunday for March 2026', () {
    final days = calendarDays(DateTime(2026, 3), DateTime.sunday);
    expect(days.first, DateTime(2026, 3));
    expect(days[14].day, 15);
    expect(weekdayLabels(DateTime.sunday).first, '日');
    expect(weekdayLabels(DateTime.monday).first, '一');
  });

  testWidgets('picking a day reports that date', (tester) async {
    DateTime? picked;
    await tester.pumpWidget(
      _host(
        TDatePicker(
          value: DateTime(2026, 3),
          onChanged: (value) => picked = value,
        ),
      ),
    );
    await tester.tap(find.text('2026-03-01'));
    await tester.pump();
    await tester.pump();

    expect(find.text('2026年 3月'), findsOneWidget);
    await tester.tap(find.text('15'));
    await tester.pump();
    await tester.pump();

    expect(picked, DateTime(2026, 3, 15));
    expect(find.text('2026年 3月'), findsNothing);
  });

  testWidgets('month mode picks the first day of the month', (tester) async {
    DateTime? picked;
    await tester.pumpWidget(
      _host(
        TDatePicker(
          mode: TDatePickerMode.month,
          value: DateTime(2026, 3, 1),
          onChanged: (value) => picked = value,
        ),
      ),
    );
    expect(find.text('2026-03'), findsOneWidget);
    await tester.tap(find.text('2026-03'));
    await tester.pump();
    await tester.pump();
    await tester.tap(find.text('6月'));
    await tester.pump();
    expect(picked, DateTime(2026, 6, 1));
  });

  testWidgets('year mode picks 1 January', (tester) async {
    DateTime? picked;
    await tester.pumpWidget(
      _host(
        TDatePicker(
          mode: TDatePickerMode.year,
          value: DateTime(2026, 1, 1),
          onChanged: (value) => picked = value,
        ),
      ),
    );
    await tester.tap(find.text('2026'));
    await tester.pump();
    await tester.pump();
    await tester.tap(find.text('2024'));
    await tester.pump();
    expect(picked, DateTime(2024, 1, 1));
  });

  testWidgets('clear removes the value', (tester) async {
    DateTime? picked = DateTime(2026, 3);
    var cleared = false;
    await tester.pumpWidget(
      _host(
        TDatePicker(
          value: picked,
          clearable: true,
          onChanged: (value) {
            picked = value;
            cleared = value == null;
          },
        ),
      ),
    );

    await tester.tap(find.byIcon(TIcons.close));
    await tester.pump();

    expect(cleared, isTrue);
    expect(picked, isNull);
  });

  testWidgets('a disabled day is not selected', (tester) async {
    var calls = 0;
    await tester.pumpWidget(
      _host(
        TDatePicker(
          value: DateTime(2026, 3),
          disableDate: (date) => date.day == 31,
          onChanged: (_) => calls++,
        ),
      ),
    );
    await tester.tap(find.text('2026-03-01'));
    await tester.pump();
    await tester.pump();
    await tester.tap(find.text('31'));
    await tester.pump();

    expect(calls, 0);
  });

  testWidgets('next month changes the panel only', (tester) async {
    var calls = 0;
    await tester.pumpWidget(
      _host(TDatePicker(value: DateTime(2026, 3), onChanged: (_) => calls++)),
    );
    await tester.tap(find.text('2026-03-01'));
    await tester.pump();
    await tester.pump();
    await tester.tap(find.byIcon(TIcons.chevron_right));
    await tester.pump();

    expect(find.text('2026年 4月'), findsOneWidget);
    expect(calls, 0);
  });

  testWidgets('allowInput commits a typed date on submit', (tester) async {
    DateTime? picked = DateTime(2026, 3, 1);
    await tester.pumpWidget(
      _host(
        StatefulBuilder(
          builder: (context, setState) {
            return TDatePicker(
              value: picked,
              allowInput: true,
              onChanged: (value) => setState(() => picked = value),
            );
          },
        ),
      ),
    );
    await tester.enterText(
      find.byKey(const ValueKey<String>('TDatePicker.input')),
      '2026-03-20',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(picked, DateTime(2026, 3, 20));
  });

  testWidgets('allowInput rejects an invalid date', (tester) async {
    DateTime? picked = DateTime(2026, 3, 1);
    await tester.pumpWidget(
      _host(
        StatefulBuilder(
          builder: (context, setState) {
            return TDatePicker(
              value: picked,
              allowInput: true,
              onChanged: (value) => setState(() => picked = value),
            );
          },
        ),
      ),
    );
    await tester.enterText(
      find.byKey(const ValueKey<String>('TDatePicker.input')),
      '2026-13-40',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(picked, DateTime(2026, 3, 1));
    expect(find.text('2026-03-01'), findsOneWidget);
  });

  testWidgets('preset selects that date', (tester) async {
    DateTime? picked;
    await tester.pumpWidget(
      _host(
        TDatePicker(
          onChanged: (value) => picked = value,
          presets: [
            TDatePreset(label: '元旦', date: () => DateTime(2026, 1, 1)),
          ],
        ),
      ),
    );
    await tester.tap(find.byKey(const ValueKey<String>('TDatePicker.open')));
    await tester.pump();
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey<String>('TDatePicker.preset.元旦')));
    await tester.pump();

    expect(picked, DateTime(2026, 1, 1));
  });

  test('parseDate accepts only real calendar days', () {
    expect(parseDate('2026-03-15'), DateTime(2026, 3, 15));
    expect(parseDate('2026-02-30'), isNull);
    expect(parseDate('03-15'), isNull);
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
