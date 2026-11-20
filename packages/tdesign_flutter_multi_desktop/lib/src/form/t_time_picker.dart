import 'package:flutter/widgets.dart';
import 'package:tdesign_flutter_multi_core/tdesign_flutter_multi_core.dart';

import '../basic/t_button.dart';
import '../token/t_token_color.dart';
import '_picker_editable_field.dart';
import '_popup_shell.dart';
import '_time_columns.dart';

/// A clock time. [hour] is 0–23. [minute] and [second] are 0–59.
class TTime {
  const TTime({required this.hour, required this.minute, this.second = 0});

  final int hour;
  final int minute;
  final int second;

  /// `HH:mm:ss` when [withSeconds] is true, otherwise `HH:mm`.
  String format({bool withSeconds = true}) {
    final hourText = hour.toString().padLeft(2, '0');
    final minuteText = minute.toString().padLeft(2, '0');
    if (!withSeconds) return '$hourText:$minuteText';
    final secondText = second.toString().padLeft(2, '0');
    return '$hourText:$minuteText:$secondText';
  }

  @override
  bool operator ==(Object other) {
    return other is TTime &&
        other.hour == hour &&
        other.minute == minute &&
        other.second == second;
  }

  @override
  int get hashCode => Object.hash(hour, minute, second);
}

/// Named shortcut for [TTimePicker.presets].
class TTimePreset {
  const TTimePreset({required this.label, required this.time});

  /// Button label in the panel.
  final String label;

  /// Produces the time to select when the shortcut is activated.
  final TTime Function() time;
}

/// Column step sizes for [TTimePicker.steps]. Defaults match Vue `[1, 1, 1]`.
class TTimeSteps {
  const TTimeSteps({this.hour = 1, this.minute = 1, this.second = 1})
    : assert(hour > 0),
      assert(minute > 0),
      assert(second > 0);

  final int hour;
  final int minute;
  final int second;
}

/// Disabled values for each column, returned by [TDisableTime].
class TDisabledTime {
  const TDisabledTime({
    this.hour = const [],
    this.minute = const [],
    this.second = const [],
  });

  final List<int> hour;
  final List<int> minute;
  final List<int> second;
}

/// Matches Vue Next `disableTime(h, m, s, ms)`.
typedef TDisableTime = TDisabledTime Function(int hour, int minute, int second);

/// Single time picker. The panel stays open after a column pick.
///
/// [showSeconds] defaults to true, matching Vue Next `HH:mm:ss`.
///
/// With [allowInput], the trigger accepts typed `HH:mm:ss` (or `HH:mm` when
/// [showSeconds] is false). Blur and Enter commit a valid time; invalid,
/// off-step, or disabled input reverts to [value].
class TTimePicker extends StatefulWidget {
  const TTimePicker({
    super.key,
    this.value,
    this.onChanged,
    this.placeholder = '请选择时间',
    this.clearable = false,
    this.enabled = true,
    this.allowInput = false,
    this.showSeconds = true,
    this.steps = const TTimeSteps(),
    this.disableTime,
    this.hideDisabledTime = true,
    this.presets = const [],
  });

  final TTime? value;
  final ValueChanged<TTime?>? onChanged;
  final String placeholder;
  final bool clearable;
  final bool enabled;
  final bool allowInput;
  final bool showSeconds;
  final TTimeSteps steps;
  final TDisableTime? disableTime;
  final bool hideDisabledTime;
  final List<TTimePreset> presets;

  @override
  State<TTimePicker> createState() => _TTimePickerState();
}

class _TTimePickerState extends State<TTimePicker> {
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
  void didUpdateWidget(covariant TTimePicker oldWidget) {
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

  String _displayText(TTime? value) {
    if (value == null) return '';
    return value.format(withSeconds: widget.showSeconds);
  }

  void _handleFocus() {
    if (!mounted) return;
    if (!_focusNode.hasFocus) _commitInput();
    setState(() {});
  }

  void _setOpen(bool value) => setState(() => _open = value);

  void _change(TTime next) {
    widget.onChanged?.call(next);
    final text = next.format(withSeconds: widget.showSeconds);
    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  void _clear() {
    widget.onChanged?.call(null);
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
    final parsed = parseTime(raw, withSeconds: widget.showSeconds);
    if (parsed == null || !_allowed(parsed)) {
      final fallback = _displayText(widget.value);
      _controller.value = TextEditingValue(
        text: fallback,
        selection: TextSelection.collapsed(offset: fallback.length),
      );
      return;
    }
    if (widget.value != parsed) widget.onChanged?.call(parsed);
    final text = parsed.format(withSeconds: widget.showSeconds);
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
    final current = widget.value ?? const TTime(hour: 0, minute: 0);
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
        inputKey: const ValueKey<String>('TTimePicker.input'),
        openKey: const ValueKey<String>('TTimePicker.open'),
      ),
      overlayBuilder: (context) {
        final disabled =
            widget.disableTime?.call(
              current.hour,
              current.minute,
              current.second,
            ) ??
            const TDisabledTime();
        return _Panel(
          value: current,
          showSeconds: widget.showSeconds,
          steps: widget.steps,
          disabled: disabled,
          hideDisabledTime: widget.hideDisabledTime,
          presets: widget.presets,
          tokens: tokens,
          onHour: (hour) => _change(
            TTime(hour: hour, minute: current.minute, second: current.second),
          ),
          onMinute: (minute) => _change(
            TTime(hour: current.hour, minute: minute, second: current.second),
          ),
          onSecond: (second) => _change(
            TTime(hour: current.hour, minute: current.minute, second: second),
          ),
          onPreset: (preset) {
            final time = preset.time();
            if (!_allowed(time)) return;
            _change(time);
            _setOpen(false);
          },
        );
      },
    );
  }
}

/// Parses `HH:mm:ss` or `HH:mm`. Returns null when out of range or malformed.
TTime? parseTime(String text, {required bool withSeconds}) {
  final pattern = withSeconds
      ? RegExp(r'^(\d{2}):(\d{2}):(\d{2})$')
      : RegExp(r'^(\d{2}):(\d{2})$');
  final match = pattern.firstMatch(text.trim());
  if (match == null) return null;
  final hour = int.parse(match[1]!);
  final minute = int.parse(match[2]!);
  final second = withSeconds ? int.parse(match[3]!) : 0;
  if (hour > 23 || minute > 59 || second > 59) return null;
  return TTime(hour: hour, minute: minute, second: second);
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.value,
    required this.showSeconds,
    required this.steps,
    required this.disabled,
    required this.hideDisabledTime,
    required this.presets,
    required this.tokens,
    required this.onHour,
    required this.onMinute,
    required this.onSecond,
    required this.onPreset,
  });

  final TTime value;
  final bool showSeconds;
  final TTimeSteps steps;
  final TDisabledTime disabled;
  final bool hideDisabledTime;
  final List<TTimePreset> presets;
  final TDesignTokenSet tokens;
  final ValueChanged<int> onHour;
  final ValueChanged<int> onMinute;
  final ValueChanged<int> onSecond;
  final ValueChanged<TTimePreset> onPreset;

  @override
  Widget build(BuildContext context) {
    final brand = tTokenColorOf(tokens, 'brandColor7');
    return TPopupShell(
      tokens: tokens,
      child: SizedBox(
        width: showSeconds ? 180 : 120,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 220,
              child: TTimeColumnsRow(
                kindPrefix: '',
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
                markBlockedDisabled: true,
                brand: brand,
                tokens: tokens,
                onHour: onHour,
                onMinute: onMinute,
                onSecond: onSecond,
              ),
            ),
            if (presets.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
                child: Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    for (final preset in presets)
                      TButton(
                        key: ValueKey<String>(
                          'TTimePicker.preset.${preset.label}',
                        ),
                        variant: TButtonVariant.text,
                        theme: TButtonTheme.primary,
                        onPressed: () => onPreset(preset),
                        child: Text(preset.label),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
