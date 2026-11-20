import 'package:flutter/widgets.dart';

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
