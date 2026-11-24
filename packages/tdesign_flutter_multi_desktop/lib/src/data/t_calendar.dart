import 'package:flutter/widgets.dart';

import '../token/t_token_color.dart';

/// Month calendar. Week starts on Monday, matching Vue `firstDayOfWeek: 1`.
class TCalendar extends StatefulWidget {
  const TCalendar({
    super.key,
    this.value,
    this.onChanged,
  });

  final DateTime? value;
  final ValueChanged<DateTime>? onChanged;

  @override
  State<TCalendar> createState() => _TCalendarState();
}

class _TCalendarState extends State<TCalendar> {
  late DateTime _month = DateTime(
    (widget.value ?? DateTime.now()).year,
    (widget.value ?? DateTime.now()).month,
  );

  @override
  Widget build(BuildContext context) {
    final text = tTokenColor(context, 'textColorPrimary');
    final muted = tTokenColor(context, 'textColorPlaceholder');
    final brand = tTokenColor(context, 'brandColor7');
    final days = _cells(_month);
    return SizedBox(
      width: 280,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => setState(
                  () => _month = DateTime(_month.year, _month.month - 1),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('<'),
                ),
              ),
              Expanded(
                child: Text(
                  '${_month.year}-${_month.month.toString().padLeft(2, '0')}',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: text, fontWeight: FontWeight.w600),
                ),
              ),
              GestureDetector(
                onTap: () => setState(
                  () => _month = DateTime(_month.year, _month.month + 1),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('>'),
                ),
              ),
            ],
          ),
          Row(
            children: [
              for (final label in const ['一', '二', '三', '四', '五', '六', '日'])
                Expanded(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: muted),
                  ),
                ),
            ],
          ),
          for (var week = 0; week < days.length; week += 7)
            Row(
              children: [
                for (var i = 0; i < 7; i++)
                  Expanded(child: _day(days[week + i], text, brand)),
              ],
            ),
        ],
      ),
    );
  }

  Widget _day(DateTime? day, Color text, Color brand) {
    if (day == null) return const SizedBox(height: 32);
    final selected = widget.value != null &&
        widget.value!.year == day.year &&
        widget.value!.month == day.month &&
        widget.value!.day == day.day;
    return GestureDetector(
      onTap: widget.onChanged == null ? null : () => widget.onChanged!(day),
      child: SizedBox(
        height: 32,
        child: Center(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: selected ? brand : null,
              shape: BoxShape.circle,
            ),
            child: SizedBox(
              width: 28,
              height: 28,
              child: Center(
                child: Text(
                  '${day.day}',
                  style: TextStyle(
                    fontSize: 12,
                    color: selected ? const Color(0xFFFFFFFF) : text,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

List<DateTime?> _cells(DateTime month) {
  final first = DateTime(month.year, month.month, 1);
  final leading = first.weekday - 1;
  final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
  final cells = <DateTime?>[
    for (var i = 0; i < leading; i++) null,
    for (var day = 1; day <= daysInMonth; day++)
      DateTime(month.year, month.month, day),
  ];
  while (cells.length % 7 != 0) {
    cells.add(null);
  }
  return cells;
}
