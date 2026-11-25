import 'package:flutter/widgets.dart';
import 'package:tdesign_flutter_icons/tdesign_flutter_icons.dart';

/// Whether [a] and [b] fall on the same calendar day (ignores time).
bool dateSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

/// Nullable variant of [dateSameDay]; both null counts as equal.
bool dateSameDayNullable(DateTime? a, DateTime? b) {
  if (a == null || b == null) return a == b;
  return dateSameDay(a, b);
}

/// Compact calendar navigation control used by date / month / year panels.
class DateCalendarNavButton extends StatelessWidget {
  const DateCalendarNavButton({
    super.key,
    required this.child,
    required this.onPressed,
  });

  final Widget child;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: SizedBox(
        width: 28,
        height: 28,
        child: Center(child: child),
      ),
    );
  }
}

/// Month title, weekday labels, and six week rows for a date panel.
///
/// Callers spread the result into their own column so presets and the
/// "today" action stay outside this chrome. [days] is the 42-day grid.
List<Widget> dateCalendarMonthRows({
  required DateTime visibleMonth,
  required List<DateTime> days,
  required List<String> weekdayNames,
  required TextStyle weekdayStyle,
  required VoidCallback onPreviousYear,
  required VoidCallback onPreviousMonth,
  required VoidCallback onNextMonth,
  required VoidCallback onNextYear,
  required Widget Function(DateTime day) dayCell,
}) {
  return [
    Row(
      children: [
        DateCalendarNavButton(
          onPressed: onPreviousYear,
          child: const Icon(TIcons.chevron_left_double, size: 16),
        ),
        DateCalendarNavButton(
          onPressed: onPreviousMonth,
          child: const Icon(TIcons.chevron_left, size: 16),
        ),
        Expanded(
          child: Text(
            '${visibleMonth.year}年 ${visibleMonth.month}月',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        DateCalendarNavButton(
          onPressed: onNextMonth,
          child: const Icon(TIcons.chevron_right, size: 16),
        ),
        DateCalendarNavButton(
          onPressed: onNextYear,
          child: const Icon(TIcons.chevron_right_double, size: 16),
        ),
      ],
    ),
    const SizedBox(height: 4),
    Row(
      children: [
        for (final name in weekdayNames)
          Expanded(
            child: Text(
              name,
              textAlign: TextAlign.center,
              style: weekdayStyle,
            ),
          ),
      ],
    ),
    for (var week = 0; week < 6; week++)
      Row(
        children: [
          for (var i = 0; i < 7; i++)
            Expanded(child: dayCell(days[week * 7 + i])),
        ],
      ),
  ];
}
