import 'package:flutter/widgets.dart';
import 'package:tdesign_flutter_core/tdesign_flutter_core.dart';

import '../basic/t_button.dart';
import '../token/t_token_color.dart';
import '_picker_editable_field.dart';
import '_popup_shell.dart';
import 'date_calendar_shared.dart';

/// Which unit [TDatePicker] selects.
enum TDatePickerMode {
  /// A calendar day. Display is `YYYY-MM-DD`.
  date,

  /// A month. Display is `YYYY-MM`. The value is the first day of that month.
  month,

  /// A year. Display is `YYYY`. The value is 1 January of that year.
  year,
}

/// Named shortcut for [TDatePicker.presets].
class TDatePreset {
  const TDatePreset({required this.label, required this.date});

  /// Button label in the panel.
  final String label;

  /// Produces the date to select when the shortcut is activated.
  final DateTime Function() date;
}

/// Single-date picker. Display is `YYYY-MM-DD`. Time on [value] is ignored.
///
/// [firstDayOfWeek] uses [DateTime.monday] through [DateTime.sunday]. The
/// default is Sunday, matching Vue Next `firstDayOfWeek: 7`.
///
/// [disableDate] receives a date-only [DateTime]. Returning true blocks that
/// day. Year and month controls change the panel only.
///
/// With [allowInput], the trigger accepts typed `YYYY-MM-DD`. Blur and Enter
/// commit a valid date; invalid or disabled input reverts to [value].
class TDatePicker extends StatefulWidget {
  const TDatePicker({
    super.key,
    this.value,
    this.onChanged,
    this.placeholder = '请选择日期',
    this.clearable = false,
    this.enabled = true,
    this.allowInput = false,
    this.disableDate,
    this.firstDayOfWeek = DateTime.sunday,
    this.presets = const [],
    this.mode = TDatePickerMode.date,
  });

  final DateTime? value;
  final ValueChanged<DateTime?>? onChanged;
  final String placeholder;
  final bool clearable;
  final bool enabled;
  final bool allowInput;
  final bool Function(DateTime date)? disableDate;
  final int firstDayOfWeek;
  final List<TDatePreset> presets;

  /// [TDatePickerMode.date] by default.
  final TDatePickerMode mode;

  @override
  State<TDatePicker> createState() => _TDatePickerState();
}

class _TDatePickerState extends State<TDatePicker> {
  var _open = false;
  late DateTime _visibleMonth;
  late final TextEditingController _controller;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _visibleMonth = _monthOf(widget.value ?? DateTime.now());
    _controller = TextEditingController(text: _displayText(widget.value));
    _focusNode.addListener(_handleFocus);
  }

  @override
  void didUpdateWidget(covariant TDatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_focusNode.hasFocus) {
      final next = _displayText(widget.value);
      if (_controller.text != next) {
        _controller.value = TextEditingValue(
          text: next,
          selection: TextSelection.collapsed(offset: next.length),
        );
      }
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocus);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  DateTime _monthOf(DateTime date) => DateTime(date.year, date.month);

  String _displayText(DateTime? value) {
    if (value == null) return '';
    return formatDateForMode(value, widget.mode);
  }

  void _handleFocus() {
    if (!mounted) return;
    if (!_focusNode.hasFocus) _commitInput();
    setState(() {});
  }

  void _setOpen(bool value) {
    setState(() {
      _open = value;
      if (value) {
        _visibleMonth = _monthOf(widget.value ?? DateTime.now());
      }
    });
  }

  void _pick(DateTime day) {
    final date = DateTime(day.year, day.month, day.day);
    widget.onChanged?.call(date);
    final text = formatDateForMode(date, widget.mode);
    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    _setOpen(false);
  }

  void _clear() {
    widget.onChanged?.call(null);
    _controller.value = const TextEditingValue(
      text: '',
      selection: TextSelection.collapsed(offset: 0),
    );
    _setOpen(false);
  }

  void _commitInput() {
    if (!widget.allowInput) return;
    final raw = _controller.text.trim();
    if (raw.isEmpty) {
      if (widget.clearable || widget.value == null) {
        if (widget.value != null) widget.onChanged?.call(null);
        _controller.value = const TextEditingValue(
          text: '',
          selection: TextSelection.collapsed(offset: 0),
        );
        return;
      }
      final fallback = _displayText(widget.value);
      _controller.value = TextEditingValue(
        text: fallback,
        selection: TextSelection.collapsed(offset: fallback.length),
      );
      return;
    }
    final parsed = parseDateForMode(raw, widget.mode);
    if (parsed == null || (widget.disableDate?.call(parsed) ?? false)) {
      final fallback = _displayText(widget.value);
      _controller.value = TextEditingValue(
        text: fallback,
        selection: TextSelection.collapsed(offset: fallback.length),
      );
      return;
    }
    if (!dateSameDayNullable(widget.value, parsed)) {
      widget.onChanged?.call(parsed);
    }
    final text = formatDateForMode(parsed, widget.mode);
    if (_controller.text != text) {
      _controller.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = TDesignTokenScope.of(context);
    final muted = widget.value == null && _controller.text.isEmpty;
    return TOverlayPortal(
      visible: _open,
      onVisibleChanged: _setOpen,
      options: const TOverlayPortalOptions(
        preferredPlacement: TPlacement.bottomLeft,
      ),
      anchor: TPickerEditableField(
        controller: _controller,
        focusNode: _focusNode,
        displayText: _controller.text.isEmpty
            ? widget.placeholder
            : _controller.text,
        muted: muted,
        enabled: widget.enabled,
        allowInput: widget.allowInput,
        clearable: widget.clearable && widget.value != null,
        onOpen: widget.enabled ? () => _setOpen(!_open) : null,
        onClear: widget.enabled ? _clear : null,
        onSubmit: widget.allowInput ? _commitInput : null,
        tokens: tokens,
        inputKey: const ValueKey<String>('TDatePicker.input'),
        openKey: const ValueKey<String>('TDatePicker.open'),
        alwaysShowOpen: true,
      ),
      overlayBuilder: (context) {
        if (widget.mode == TDatePickerMode.month) {
          final year = _visibleMonth.year;
          return _UnitGridPanel(
            title: '$year年',
            tokens: tokens,
            onPrevious: () => setState(() {
              _visibleMonth = DateTime(year - 1, 1);
            }),
            onNext: () => setState(() {
              _visibleMonth = DateTime(year + 1, 1);
            }),
            cells: [
              for (var month = 1; month <= 12; month++)
                _UnitCell(
                  label: '$month月',
                  selected:
                      widget.value?.year == year &&
                      widget.value?.month == month,
                  disabled:
                      widget.disableDate?.call(DateTime(year, month)) ?? false,
                  onPick: () => _pick(DateTime(year, month)),
                ),
            ],
          );
        }
        if (widget.mode == TDatePickerMode.year) {
          final start = _visibleMonth.year - (_visibleMonth.year % 12);
          return _UnitGridPanel(
            title: '$start - ${start + 11}',
            tokens: tokens,
            onPrevious: () => setState(() {
              _visibleMonth = DateTime(start - 12, 1);
            }),
            onNext: () => setState(() {
              _visibleMonth = DateTime(start + 12, 1);
            }),
            cells: [
              for (var index = 0; index < 12; index++)
                _UnitCell(
                  label: '${start + index}',
                  selected: widget.value?.year == start + index,
                  disabled:
                      widget.disableDate?.call(DateTime(start + index)) ??
                      false,
                  onPick: () => _pick(DateTime(start + index)),
                ),
            ],
          );
        }
        return _Panel(
          visibleMonth: _visibleMonth,
          selected: widget.value,
          firstDayOfWeek: widget.firstDayOfWeek,
          disableDate: widget.disableDate,
          presets: widget.presets,
          tokens: tokens,
          onPreviousYear: () => setState(() {
            _visibleMonth = DateTime(
              _visibleMonth.year - 1,
              _visibleMonth.month,
            );
          }),
          onNextYear: () => setState(() {
            _visibleMonth = DateTime(
              _visibleMonth.year + 1,
              _visibleMonth.month,
            );
          }),
          onPreviousMonth: () => setState(() {
            _visibleMonth = DateTime(
              _visibleMonth.year,
              _visibleMonth.month - 1,
            );
          }),
          onNextMonth: () => setState(() {
            _visibleMonth = DateTime(
              _visibleMonth.year,
              _visibleMonth.month + 1,
            );
          }),
          onToday: () => _pick(DateTime.now()),
          onPick: _pick,
          onPreset: (preset) => _pick(preset.date()),
        );
      },
    );
  }
}

/// Formats [date] for [mode].
String formatDateForMode(DateTime date, TDatePickerMode mode) {
  switch (mode) {
    case TDatePickerMode.date:
      return formatDate(date);
    case TDatePickerMode.month:
      final month = date.month.toString().padLeft(2, '0');
      return '${date.year}-$month';
    case TDatePickerMode.year:
      return '${date.year}';
  }
}

/// Parses input for [mode]. Month values are the first day; years are 1 January.
DateTime? parseDateForMode(String text, TDatePickerMode mode) {
  switch (mode) {
    case TDatePickerMode.date:
      return parseDate(text);
    case TDatePickerMode.month:
      final match = RegExp(r'^(\d{4})-(\d{2})$').firstMatch(text.trim());
      if (match == null) return null;
      final year = int.parse(match.group(1)!);
      final month = int.parse(match.group(2)!);
      if (month < 1 || month > 12) return null;
      return DateTime(year, month, 1);
    case TDatePickerMode.year:
      final match = RegExp(r'^(\d{4})$').firstMatch(text.trim());
      if (match == null) return null;
      return DateTime(int.parse(match.group(1)!), 1, 1);
  }
}

class _UnitGridPanel extends StatelessWidget {
  const _UnitGridPanel({
    required this.title,
    required this.tokens,
    required this.onPrevious,
    required this.onNext,
    required this.cells,
  });

  final String title;
  final TDesignTokenSet tokens;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final List<_UnitCell> cells;

  @override
  Widget build(BuildContext context) {
    return TPopupShell(
      tokens: tokens,
      child: SizedBox(
        width: 280,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  DateCalendarNavButton(label: '«', onPressed: onPrevious),
                  Expanded(child: Text(title, textAlign: TextAlign.center)),
                  DateCalendarNavButton(label: '»', onPressed: onNext),
                ],
              ),
              for (var row = 0; row < 3; row++)
                Row(
                  children: [
                    for (var column = 0; column < 4; column++)
                      Expanded(child: cells[row * 4 + column]),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UnitCell extends StatelessWidget {
  const _UnitCell({
    required this.label,
    required this.selected,
    required this.disabled,
    required this.onPick,
  });

  final String label;
  final bool selected;
  final bool disabled;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final tokens = TDesignTokenScope.of(context);
    final brand = tTokenColorOf(tokens, 'brandColor7');
    final primary = tTokenColorOf(tokens, 'textColorPrimary');
    final anti = tTokenColorOf(tokens, 'textColorAnti');
    final Color color;
    if (disabled) {
      color = primary.withValues(alpha: 0.35);
    } else if (selected) {
      color = anti;
    } else {
      color = primary;
    }
    return GestureDetector(
      onTap: disabled ? null : onPick,
      child: Container(
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? brand : null,
          borderRadius: BorderRadius.circular(tTokenRadius(tokens)),
        ),
        child: Text(label, style: TextStyle(fontSize: 13, color: color)),
      ),
    );
  }
}

/// `YYYY-MM-DD` for a calendar day.
String formatDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

/// Parses a strict `YYYY-MM-DD` calendar day. Returns null when invalid.
DateTime? parseDate(String text) {
  final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(text.trim());
  if (match == null) return null;
  final year = int.parse(match[1]!);
  final month = int.parse(match[2]!);
  final day = int.parse(match[3]!);
  final date = DateTime(year, month, day);
  if (date.year != year || date.month != month || date.day != day) {
    return null;
  }
  return date;
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.visibleMonth,
    required this.selected,
    required this.firstDayOfWeek,
    required this.disableDate,
    required this.presets,
    required this.tokens,
    required this.onPreviousYear,
    required this.onNextYear,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onToday,
    required this.onPick,
    required this.onPreset,
  });

  final DateTime visibleMonth;
  final DateTime? selected;
  final int firstDayOfWeek;
  final bool Function(DateTime date)? disableDate;
  final List<TDatePreset> presets;
  final TDesignTokenSet tokens;
  final VoidCallback onPreviousYear;
  final VoidCallback onNextYear;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onToday;
  final ValueChanged<DateTime> onPick;
  final ValueChanged<TDatePreset> onPreset;

  @override
  Widget build(BuildContext context) {
    final brand = tTokenColorOf(tokens, 'brandColor7');
    final primary = tTokenColorOf(tokens, 'textColorPrimary');
    final days = calendarDays(visibleMonth, firstDayOfWeek);
    return TPopupShell(
      tokens: tokens,
      child: SizedBox(
        width: 280,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  DateCalendarNavButton(label: '«', onPressed: onPreviousYear),
                  DateCalendarNavButton(label: '‹', onPressed: onPreviousMonth),
                  Expanded(
                    child: Text(
                      '${visibleMonth.year}年 ${visibleMonth.month}月',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  DateCalendarNavButton(label: '›', onPressed: onNextMonth),
                  DateCalendarNavButton(label: '»', onPressed: onNextYear),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  for (final name in weekdayLabels(firstDayOfWeek))
                    Expanded(
                      child: Text(
                        name,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: primary),
                      ),
                    ),
                ],
              ),
              for (var week = 0; week < 6; week++)
                Row(
                  children: [
                    for (var i = 0; i < 7; i++)
                      Expanded(
                        child: _DayCell(
                          day: days[week * 7 + i],
                          visibleMonth: visibleMonth,
                          selected: selected,
                          brand: brand,
                          tokens: tokens,
                          disabled: _isDisabled(days[week * 7 + i]),
                          onPick: onPick,
                        ),
                      ),
                  ],
                ),
              if (presets.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      for (final preset in presets)
                        TButton(
                          key: ValueKey<String>(
                            'TDatePicker.preset.${preset.label}',
                          ),
                          variant: TButtonVariant.text,
                          theme: TButtonTheme.primary,
                          onPressed: () => onPreset(preset),
                          child: Text(preset.label),
                        ),
                    ],
                  ),
                ),
              Align(
                alignment: Alignment.centerRight,
                child: TButton(
                  variant: TButtonVariant.text,
                  theme: TButtonTheme.primary,
                  onPressed: onToday,
                  child: const Text('今天'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isDisabled(DateTime day) {
    final date = DateTime(day.year, day.month, day.day);
    return disableDate?.call(date) ?? false;
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.visibleMonth,
    required this.selected,
    required this.brand,
    required this.tokens,
    required this.disabled,
    required this.onPick,
  });

  final DateTime day;
  final DateTime visibleMonth;
  final DateTime? selected;
  final Color brand;
  final TDesignTokenSet tokens;
  final bool disabled;
  final ValueChanged<DateTime> onPick;

  @override
  Widget build(BuildContext context) {
    final inMonth = day.month == visibleMonth.month;
    final isSelected = selected != null && dateSameDay(selected!, day);
    final isToday = dateSameDay(day, DateTime.now());
    final Color color;
    if (!inMonth || disabled) {
      color = tTokenColorOf(tokens, 'textColorDisabled');
    } else if (isSelected) {
      color = tTokenColorOf(tokens, 'textColorAnti');
    } else {
      color = tTokenColorOf(tokens, 'textColorPrimary');
    }
    return GestureDetector(
      onTap: disabled ? null : () => onPick(day),
      child: Container(
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? brand : null,
          shape: BoxShape.circle,
          border: isToday && !isSelected ? Border.all(color: brand) : null,
        ),
        child: Text('${day.day}', style: TextStyle(fontSize: 13, color: color)),
      ),
    );
  }
}

/// Forty-two days covering [month], starting on [firstDayOfWeek].
List<DateTime> calendarDays(DateTime month, int firstDayOfWeek) {
  final first = DateTime(month.year, month.month);
  final start = firstDayOfWeek % 7;
  final current = first.weekday % 7;
  final leading = (current - start + 7) % 7;
  final origin = first.subtract(Duration(days: leading));
  return [for (var i = 0; i < 42; i++) origin.add(Duration(days: i))];
}

/// Weekday labels beginning at [firstDayOfWeek]. Index 0 is Sunday.
List<String> weekdayLabels(int firstDayOfWeek) {
  const names = ['日', '一', '二', '三', '四', '五', '六'];
  final start = firstDayOfWeek % 7;
  return [for (var i = 0; i < 7; i++) names[(start + i) % 7]];
}
