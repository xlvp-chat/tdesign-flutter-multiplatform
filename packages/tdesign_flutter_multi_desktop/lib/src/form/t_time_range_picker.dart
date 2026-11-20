import 'package:flutter/widgets.dart';
import 'package:tdesign_flutter_multi_core/tdesign_flutter_multi_core.dart';

import '../basic/t_button.dart';
import '../token/t_token_color.dart';
import '_picker_editable_field.dart';
import '_popup_shell.dart';
import '_time_columns.dart';
import 't_time_picker.dart';

/// Named shortcut that writes both ends of [TTimeRangePicker].
class TTimeRangePreset {
  const TTimeRangePreset({required this.label, required this.range});

  final String label;
  final TTimeRange Function() range;
}

/// Controlled start/end times for [TTimeRangePicker].
class TTimeRange {
  const TTimeRange({this.start, this.end});

  final TTime? start;
  final TTime? end;

  bool get isEmpty => start == null && end == null;

  @override
  bool operator ==(Object other) {
    return other is TTimeRange && other.start == start && other.end == end;
  }

  @override
  int get hashCode => Object.hash(start, end);
}

/// Desktop time range picker — dual panels for start and end.
///
/// Spec source: local tdesign-vue-next `TimeRangePicker`.
///
/// With [allowInput], the trigger accepts `HH:mm:ss 至 HH:mm:ss` (or `HH:mm`
/// when [showSeconds] is false). Blur and Enter commit both ends; invalid
/// input reverts to [value].
class TTimeRangePicker extends StatefulWidget {
  const TTimeRangePicker({
    super.key,
    this.value = const TTimeRange(),
    this.onChanged,
    this.placeholder = '请选择时间区间',
    this.clearable = false,
    this.enabled = true,
    this.allowInput = false,
    this.showSeconds = true,
    this.steps = const TTimeSteps(),
    this.disableTime,
    this.hideDisabledTime = true,
    this.presets = const [],
  });

  final TTimeRange value;
  final ValueChanged<TTimeRange>? onChanged;
  final String placeholder;
  final bool clearable;
  final bool enabled;
  final bool allowInput;
  final bool showSeconds;
  final TTimeSteps steps;
  final TDisableTime? disableTime;
  final bool hideDisabledTime;
  final List<TTimeRangePreset> presets;

  @override
  State<TTimeRangePicker> createState() => _TTimeRangePickerState();
}

class _TTimeRangePickerState extends State<TTimeRangePicker> {
  var _open = false;
  late final TextEditingController _controller;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _displayText(widget.value));
    _focusNode.addListener(_handleFocus);
  }

  @override
  void didUpdateWidget(covariant TTimeRangePicker oldWidget) {
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

  void _handleFocus() {
    if (!mounted) return;
    if (!_focusNode.hasFocus) _commitInput();
    setState(() {});
  }

  String _displayText(TTimeRange value) {
    if (value.isEmpty) return '';
    final withSeconds = widget.showSeconds;
    final left = value.start?.format(withSeconds: withSeconds) ?? '';
    final right = value.end?.format(withSeconds: withSeconds) ?? '';
    if (left.isEmpty && right.isEmpty) return '';
    return '$left 至 $right';
  }

  void _setOpen(bool value) {
    if (!widget.enabled && value) return;
    setState(() => _open = value);
  }

  void _apply(TTimeRange next) {
    widget.onChanged?.call(next);
    final text = _displayText(next);
    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  void _clear() {
    widget.onChanged?.call(const TTimeRange());
    _controller.value = const TextEditingValue(
      text: '',
      selection: TextSelection.collapsed(offset: 0),
    );
    _setOpen(false);
  }

  bool _allowed(TTime time) {
    if (time.hour % widget.steps.hour != 0) return false;
    if (time.minute % widget.steps.minute != 0) return false;
    if (widget.showSeconds && time.second % widget.steps.second != 0) {
      return false;
    }
    final disabled =
        widget.disableTime?.call(time.hour, time.minute, time.second) ??
        const TDisabledTime();
    if (disabled.hour.contains(time.hour)) return false;
    if (disabled.minute.contains(time.minute)) return false;
    if (widget.showSeconds && disabled.second.contains(time.second)) {
      return false;
    }
    return true;
  }

  void _commitInput() {
    if (!widget.allowInput) return;
    final raw = _controller.text.trim();
    if (raw.isEmpty) {
      if (widget.clearable || widget.value.isEmpty) {
        if (!widget.value.isEmpty) widget.onChanged?.call(const TTimeRange());
        _controller.value = const TextEditingValue(
          text: '',
          selection: TextSelection.collapsed(offset: 0),
        );
        return;
      }
    }
    final parsed = parseTimeRange(raw, withSeconds: widget.showSeconds);
    if (parsed == null ||
        parsed.start == null ||
        parsed.end == null ||
        !_allowed(parsed.start!) ||
        !_allowed(parsed.end!)) {
      final fallback = _displayText(widget.value);
      _controller.value = TextEditingValue(
        text: fallback,
        selection: TextSelection.collapsed(offset: fallback.length),
      );
      return;
    }
    _apply(parsed);
  }

  void _preset(TTimeRangePreset preset) {
    _apply(preset.range());
    _setOpen(false);
  }

  void _updateStart(TTime start) {
    _apply(TTimeRange(start: start, end: widget.value.end));
  }

  void _updateEnd(TTime end) {
    _apply(TTimeRange(start: widget.value.start, end: end));
  }

  String get _label {
    final start = widget.value.start;
    final end = widget.value.end;
    if (start == null && end == null) return widget.placeholder;
    final withSeconds = widget.showSeconds;
    final left = start?.format(withSeconds: withSeconds) ?? '--:--';
    final right = end?.format(withSeconds: withSeconds) ?? '--:--';
    return '$left 至 $right';
  }

  @override
  Widget build(BuildContext context) {
    final tokens = TDesignTokenScope.of(context);
    final start = widget.value.start ?? const TTime(hour: 0, minute: 0);
    final end =
        widget.value.end ?? const TTime(hour: 23, minute: 59, second: 59);
    final sides =
        <
          ({
            String title,
            TTime value,
            String kindPrefix,
            ValueChanged<TTime> onChanged,
          })
        >[
          (
            title: '开始',
            value: start,
            kindPrefix: 'start',
            onChanged: _updateStart,
          ),
          (title: '结束', value: end, kindPrefix: 'end', onChanged: _updateEnd),
        ];
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
        muted: widget.value.isEmpty,
        enabled: widget.enabled,
        allowInput: widget.allowInput,
        clearable: widget.clearable && !widget.value.isEmpty,
        onOpen: widget.enabled ? () => _setOpen(!_open) : null,
        onClear: _clear,
        onSubmit: widget.allowInput ? _commitInput : null,
        tokens: tokens,
        inputKey: const ValueKey<String>('TTimeRangePicker.input'),
        openKey: const ValueKey<String>('TTimeRangePicker.open'),
        textInputAction: null,
      ),
      overlayBuilder: (context) {
        final brand = tTokenColorOf(tokens, 'brandColor7');
        return TPopupShell(
          tokens: tokens,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < sides.length; i++) ...[
                    if (i > 0)
                      ColoredBox(
                        color: tTokenColorOf(tokens, 'borderLevel1Color'),
                        child: const SizedBox(width: 1, height: 248),
                      ),
                    _SidePanel(
                      title: sides[i].title,
                      value: sides[i].value,
                      showSeconds: widget.showSeconds,
                      steps: widget.steps,
                      disableTime: widget.disableTime,
                      hideDisabledTime: widget.hideDisabledTime,
                      brand: brand,
                      tokens: tokens,
                      kindPrefix: sides[i].kindPrefix,
                      onChanged: sides[i].onChanged,
                    ),
                  ],
                ],
              ),
              if (widget.presets.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                  child: Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      for (final preset in widget.presets)
                        TButton(
                          key: ValueKey<String>(
                            'TTimeRangePicker.preset.${preset.label}',
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

/// Parses `HH:mm:ss 至 HH:mm:ss` or `HH:mm 至 HH:mm`.
TTimeRange? parseTimeRange(String text, {required bool withSeconds}) {
  final parts = text.trim().split(RegExp(r'\s*至\s*'));
  if (parts.length != 2) return null;
  final start = parseTime(parts[0], withSeconds: withSeconds);
  final end = parseTime(parts[1], withSeconds: withSeconds);
  if (start == null || end == null) return null;
  return TTimeRange(start: start, end: end);
}

class _SidePanel extends StatelessWidget {
  const _SidePanel({
    required this.title,
    required this.value,
    required this.showSeconds,
    required this.steps,
    required this.disableTime,
    required this.hideDisabledTime,
    required this.brand,
    required this.tokens,
    required this.kindPrefix,
    required this.onChanged,
  });

  final String title;
  final TTime value;
  final bool showSeconds;
  final TTimeSteps steps;
  final TDisableTime? disableTime;
  final bool hideDisabledTime;
  final Color brand;
  final TDesignTokenSet tokens;
  final String kindPrefix;
  final ValueChanged<TTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final disabled =
        disableTime?.call(value.hour, value.minute, value.second) ??
        const TDisabledTime();
    return SizedBox(
      width: showSeconds ? 180 : 120,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(title, style: const TextStyle(fontSize: 12)),
          ),
          SizedBox(
            height: 220,
            child: TTimeColumnsRow(
              kindPrefix: kindPrefix,
              hour: value.hour,
              minute: value.minute,
              second: value.second,
              showSeconds: showSeconds,
              hourStep: steps.hour,
              minuteStep: steps.minute,
              secondStep: steps.second,
              blockedHours: disabled.hour,
              blockedMinutes: disabled.minute,
              blockedSeconds: disabled.second,
              hideDisabledTime: hideDisabledTime,
              // Preserve prior TimeRange behavior: blocked values that remain
              // visible stay tappable (not grayed out).
              markBlockedDisabled: false,
              brand: brand,
              tokens: tokens,
              onHour: (hour) => onChanged(
                TTime(hour: hour, minute: value.minute, second: value.second),
              ),
              onMinute: (minute) => onChanged(
                TTime(hour: value.hour, minute: minute, second: value.second),
              ),
              onSecond: (second) => onChanged(
                TTime(hour: value.hour, minute: value.minute, second: second),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
