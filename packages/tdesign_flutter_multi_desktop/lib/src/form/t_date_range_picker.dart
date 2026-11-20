import 'package:flutter/widgets.dart';
import 'package:tdesign_flutter_multi_core/tdesign_flutter_multi_core.dart';

import '../basic/t_button.dart';
import '../token/t_token_color.dart';
import '_picker_editable_field.dart';
import '_popup_shell.dart';
import 'date_calendar_shared.dart';
import 't_date_picker.dart';

/// Named shortcut that writes both ends of [TDateRangePicker].
class TDateRangePreset {
  const TDateRangePreset({required this.label, required this.range});

  final String label;
  final TDateRange Function() range;
}

/// Controlled start/end dates for [TDateRangePicker]. Time parts are ignored.
class TDateRange {
  const TDateRange({this.start, this.end});

  final DateTime? start;
  final DateTime? end;

  bool get isEmpty => start == null && end == null;
  bool get isComplete => start != null && end != null;

  @override
  bool operator ==(Object other) {
    return other is TDateRange &&
        dateSameDayNullable(start, other.start) &&
        dateSameDayNullable(end, other.end);
  }

  @override
  int get hashCode => Object.hash(
    start == null ? null : formatDate(start!),
    end == null ? null : formatDate(end!),
  );
}

/// Desktop date range picker — dual month panels.
///
/// Spec source: local tdesign-vue-next `DateRangePicker`.
/// [enableTime] keeps hour and minute on each end.
class TDateRangePicker extends StatefulWidget {
  const TDateRangePicker({
    super.key,
    this.value = const TDateRange(),
    this.onChanged,
    this.placeholder = '请选择日期区间',
    this.clearable = false,
    this.enabled = true,
    this.allowInput = false,
    this.enableTime = false,
    this.presets = const [],
    this.disableDate,
    this.firstDayOfWeek = DateTime.sunday,
  });

  final TDateRange value;
  final ValueChanged<TDateRange>? onChanged;
  final String placeholder;
  final bool clearable;
  final bool enabled;
  final bool allowInput;
  final bool enableTime;
  final List<TDateRangePreset> presets;
  final bool Function(DateTime date)? disableDate;
  final int firstDayOfWeek;

  @override
  State<TDateRangePicker> createState() => _TDateRangePickerState();
}

class _TDateRangePickerState extends State<TDateRangePicker> {
  var _open = false;
  late DateTime _leftMonth;
  late DateTime _rightMonth;
  DateTime? _draftStart;
  late final TextEditingController _controller;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _syncMonths(widget.value);
    _controller = TextEditingController(text: _inputText(widget.value));
    _focusNode.addListener(_handleFocus);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocus);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleFocus() {
    if (!mounted) return;
    if (!_focusNode.hasFocus) _commitInput();
    setState(() {});
  }

  String _inputText(TDateRange value) {
    if (!value.isComplete) return '';
    return '${_format(value.start!)} 至 ${_format(value.end!)}';
  }

  String _format(DateTime date) =>
      formatDateTime(date, withTime: widget.enableTime);

  void _writeController(TDateRange value) {
    final text = _inputText(value);
    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  @override
  void didUpdateWidget(covariant TDateRangePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _syncMonths(widget.value);
      if (!_focusNode.hasFocus) _writeController(widget.value);
    }
  }

  void _syncMonths(TDateRange value) {
    final base = _monthOf(value.start ?? DateTime.now());
    _leftMonth = base;
    _rightMonth = DateTime(base.year, base.month + 1);
  }

  DateTime _monthOf(DateTime date) => DateTime(date.year, date.month);

  void _shiftLeft({int years = 0, int months = 0}) {
    setState(() {
      _leftMonth = DateTime(_leftMonth.year + years, _leftMonth.month + months);
    });
  }

  void _shiftRight({int years = 0, int months = 0}) {
    setState(() {
      _rightMonth = DateTime(
        _rightMonth.year + years,
        _rightMonth.month + months,
      );
    });
  }

  void _setOpen(bool value) {
    if (!widget.enabled && value) return;
    setState(() {
      _open = value;
      if (value) {
        _draftStart = null;
        _syncMonths(widget.value);
      }
    });
  }

  void _pick(DateTime day) {
    final date = DateTime(day.year, day.month, day.day);
    if (widget.disableDate?.call(date) ?? false) return;
    if (_draftStart == null) {
      setState(() => _draftStart = date);
      return;
    }
    var start = _draftStart!;
    var end = date;
    if (end.isBefore(start)) {
      final swap = start;
      start = end;
      end = swap;
    }
    if (widget.enableTime) {
      start = DateTime(start.year, start.month, start.day);
      end = DateTime(end.year, end.month, end.day, 23, 59);
    }
    _apply(TDateRange(start: start, end: end));
    _draftStart = null;
    _setOpen(false);
  }

  void _apply(TDateRange next) {
    widget.onChanged?.call(next);
    _writeController(next);
  }

  void _commitInput() {
    if (!widget.allowInput) return;
    final raw = _controller.text.trim();
    if (raw.isEmpty) {
      if (widget.clearable || widget.value.isEmpty) {
        if (!widget.value.isEmpty) widget.onChanged?.call(const TDateRange());
        _writeController(const TDateRange());
        return;
      }
    }
    final parsed = parseDateRange(raw, withTime: widget.enableTime);
    DateTime day(DateTime date) => DateTime(date.year, date.month, date.day);
    if (parsed == null ||
        (widget.disableDate?.call(day(parsed.start!)) ?? false) ||
        (widget.disableDate?.call(day(parsed.end!)) ?? false)) {
      _writeController(widget.value);
      return;
    }
    _apply(parsed);
  }

  void _preset(TDateRangePreset preset) {
    _apply(preset.range());
    _draftStart = null;
    _setOpen(false);
  }

  void _setTime({
    required bool start,
    required int? hour,
    required int? minute,
  }) {
    final current = start ? widget.value.start : widget.value.end;
    if (current == null) return;
    final next = DateTime(
      current.year,
      current.month,
      current.day,
      hour ?? current.hour,
      minute ?? current.minute,
    );
    _apply(
      TDateRange(
        start: start ? next : widget.value.start,
        end: start ? widget.value.end : next,
      ),
    );
  }

  void _clear() {
    widget.onChanged?.call(const TDateRange());
    _writeController(const TDateRange());
    _draftStart = null;
    _setOpen(false);
  }

  String get _label {
    final start = widget.value.start;
    final end = widget.value.end;
    if (start == null && end == null) return widget.placeholder;
    if (start != null && end != null) {
      return '${_format(start)} 至 ${_format(end)}';
    }
    if (start != null) return _format(start);
    return _format(end!);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = TDesignTokenScope.of(context);
    final muted = widget.value.isEmpty;
    return TOverlayPortal(
      visible: _open,
      onVisibleChanged: _setOpen,
      options: const TOverlayPortalOptions(
        preferredPlacement: TPlacement.bottomLeft,
      ),
      anchor: TPickerEditableField(
        controller: _controller,
        focusNode: _focusNode,
        displayText: _label,
        muted: muted,
        enabled: widget.enabled,
        allowInput: widget.allowInput,
        clearable: widget.clearable && !widget.value.isEmpty,
        onOpen: widget.enabled ? () => _setOpen(!_open) : null,
        onClear: _clear,
        onSubmit: widget.allowInput ? _commitInput : null,
        tokens: tokens,
        inputKey: const ValueKey<String>('TDateRangePicker.input'),
        openKey: const ValueKey<String>('TDateRangePicker.open'),
        textInputAction: null,
      ),
      overlayBuilder: (context) {
        final rangeStart = _draftStart ?? widget.value.start;
        final rangeEnd = _draftStart != null ? null : widget.value.end;
        final panels =
            <({DateTime month, void Function({int years, int months}) shift})>[
              (month: _leftMonth, shift: _shiftLeft),
              (month: _rightMonth, shift: _shiftRight),
            ];
        return TPopupShell(
          tokens: tokens,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < panels.length; i++) ...[
                    if (i > 0)
                      ColoredBox(
                        color: tTokenColorOf(tokens, 'borderLevel1Color'),
                        child: const SizedBox(width: 1, height: 280),
                      ),
                    _MonthPanel(
                      visibleMonth: panels[i].month,
                      rangeStart: rangeStart,
                      rangeEnd: rangeEnd,
                      firstDayOfWeek: widget.firstDayOfWeek,
                      disableDate: widget.disableDate,
                      tokens: tokens,
                      onPreviousYear: () => panels[i].shift(years: -1),
                      onNextYear: () => panels[i].shift(years: 1),
                      onPreviousMonth: () => panels[i].shift(months: -1),
                      onNextMonth: () => panels[i].shift(months: 1),
                      onPick: _pick,
                    ),
                  ],
                ],
              ),
              if (widget.enableTime && widget.value.isComplete)
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                  child: Row(
                    children: [
                      _TimeEnd(
                        label: '开始',
                        value: widget.value.start!,
                        onHour: (hour) =>
                            _setTime(start: true, hour: hour, minute: null),
                        onMinute: (minute) =>
                            _setTime(start: true, hour: null, minute: minute),
                      ),
                      const SizedBox(width: 12),
                      _TimeEnd(
                        label: '结束',
                        value: widget.value.end!,
                        onHour: (hour) =>
                            _setTime(start: false, hour: hour, minute: null),
                        onMinute: (minute) =>
                            _setTime(start: false, hour: null, minute: minute),
                      ),
                    ],
                  ),
                ),
              if (widget.presets.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                  child: Wrap(
                    spacing: 4,
                    children: [
                      for (final preset in widget.presets)
                        TButton(
                          key: ValueKey<String>(
                            'TDateRangePicker.preset.${preset.label}',
                          ),
                          variant: TButtonVariant.text,
                          theme: TButtonTheme.primary,
                          onPressed: () => _preset(preset),
                          child: Text(preset.label),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

String formatDateTime(DateTime date, {required bool withTime}) {
  if (!withTime) return formatDate(date);
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '${formatDate(date)} $hour:$minute';
}

TDateRange? parseDateRange(String text, {required bool withTime}) {
  final parts = text.trim().split(RegExp(r'\s*至\s*'));
  if (parts.length != 2) return null;
  final start = _parseEnd(parts[0], withTime: withTime);
  final end = _parseEnd(parts[1], withTime: withTime);
  if (start == null || end == null) return null;
  return TDateRange(start: start, end: end);
}

DateTime? _parseEnd(String text, {required bool withTime}) {
  if (!withTime) return parseDate(text);
  final match = RegExp(
    r'^(\d{4}-\d{2}-\d{2}) (\d{2}):(\d{2})$',
  ).firstMatch(text.trim());
  if (match == null) return null;
  final day = parseDate(match.group(1)!);
  if (day == null) return null;
  final hour = int.parse(match.group(2)!);
  final minute = int.parse(match.group(3)!);
  if (hour > 23 || minute > 59) return null;
  return DateTime(day.year, day.month, day.day, hour, minute);
}

class _TimeEnd extends StatelessWidget {
  const _TimeEnd({
    required this.label,
    required this.value,
    required this.onHour,
    required this.onMinute,
  });

  final String label;
  final DateTime value;
  final ValueChanged<int> onHour;
  final ValueChanged<int> onMinute;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 4),
        _Step(
          keyName: '$label-hour',
          value: value.hour,
          limit: 24,
          onChanged: onHour,
        ),
        const Text(':'),
        _Step(
          keyName: '$label-minute',
          value: value.minute,
          limit: 60,
          onChanged: onMinute,
        ),
      ],
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.keyName,
    required this.value,
    required this.limit,
    required this.onChanged,
  });

  final String keyName;
  final int value;
  final int limit;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: ValueKey<String>('TDateRangePicker.$keyName'),
      onTap: () => onChanged((value + 1) % limit),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Text(value.toString().padLeft(2, '0')),
      ),
    );
  }
}

class _MonthPanel extends StatelessWidget {
  const _MonthPanel({
    required this.visibleMonth,
    required this.rangeStart,
    required this.rangeEnd,
    required this.firstDayOfWeek,
    required this.disableDate,
    required this.tokens,
    required this.onPreviousYear,
    required this.onNextYear,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onPick,
  });

  final DateTime visibleMonth;
  final DateTime? rangeStart;
  final DateTime? rangeEnd;
  final int firstDayOfWeek;
  final bool Function(DateTime date)? disableDate;
  final TDesignTokenSet tokens;
  final VoidCallback onPreviousYear;
  final VoidCallback onNextYear;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<DateTime> onPick;

  @override
  Widget build(BuildContext context) {
    final brand = tTokenColorOf(tokens, 'brandColor7');
    final days = calendarDays(visibleMonth, firstDayOfWeek);
    return SizedBox(
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
                      style: const TextStyle(fontSize: 12),
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
                        rangeStart: rangeStart,
                        rangeEnd: rangeEnd,
                        brand: brand,
                        tokens: tokens,
                        disabled:
                            disableDate?.call(
                              DateTime(
                                days[week * 7 + i].year,
                                days[week * 7 + i].month,
                                days[week * 7 + i].day,
                              ),
                            ) ??
                            false,
                        onPick: onPick,
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.visibleMonth,
    required this.rangeStart,
    required this.rangeEnd,
    required this.brand,
    required this.tokens,
    required this.disabled,
    required this.onPick,
  });

  final DateTime day;
  final DateTime visibleMonth;
  final DateTime? rangeStart;
  final DateTime? rangeEnd;
  final Color brand;
  final TDesignTokenSet tokens;
  final bool disabled;
  final ValueChanged<DateTime> onPick;

  @override
  Widget build(BuildContext context) {
    final inMonth = day.month == visibleMonth.month;
    final isStart = rangeStart != null && dateSameDay(rangeStart!, day);
    final isEnd = rangeEnd != null && dateSameDay(rangeEnd!, day);
    final inRange =
        rangeStart != null &&
        rangeEnd != null &&
        !day.isBefore(rangeStart!) &&
        !day.isAfter(rangeEnd!);
    final disabledText = tTokenColorOf(tokens, 'textColorDisabled');
    final anti = tTokenColorOf(tokens, 'textColorAnti');
    final primary = tTokenColorOf(tokens, 'textColorPrimary');
    final Color color;
    if (!inMonth || disabled) {
      color = disabledText;
    } else if (isStart || isEnd) {
      color = anti;
    } else {
      color = primary;
    }
    final Color? fill;
    if (isStart || isEnd) {
      fill = brand;
    } else if (inRange) {
      fill = brand.withValues(alpha: 0.12);
    } else {
      fill = null;
    }
    return GestureDetector(
      onTap: disabled ? null : () => onPick(day),
      child: Container(
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: fill, shape: BoxShape.circle),
        child: Text('${day.day}', style: TextStyle(fontSize: 13, color: color)),
      ),
    );
  }
}
