import 'package:flutter/widgets.dart';
import 'package:tdesign_flutter_multi_core/tdesign_flutter_multi_core.dart';

import '../token/t_token_color.dart';

/// One selectable (or disabled) value in a time column.
///
/// Package-internal; not exported from the barrel.
class TTimeColumnSlot {
  const TTimeColumnSlot({required this.value, this.disabled = false});

  final int value;
  final bool disabled;
}

/// Builds stepped slots for a time column.
///
/// When [hideDisabledTime] is true, blocked values are omitted. When
/// [markBlockedDisabled] is true, remaining blocked values render disabled;
/// when false they stay tappable (TimeRange historical behavior).
List<TTimeColumnSlot> tTimeColumnSlots({
  required int limit,
  required int step,
  List<int> blocked = const [],
  bool hideDisabledTime = true,
  bool markBlockedDisabled = true,
}) {
  final blockedSet = blocked.toSet();
  final slots = <TTimeColumnSlot>[];
  for (var i = 0; i < limit; i += step) {
    final isBlocked = blockedSet.contains(i);
    if (isBlocked && hideDisabledTime) continue;
    slots.add(
      TTimeColumnSlot(value: i, disabled: markBlockedDisabled && isBlocked),
    );
  }
  return slots;
}

/// Scrollable hour/minute/second column shared by time pickers.
class TTimeColumn extends StatelessWidget {
  const TTimeColumn({
    super.key,
    required this.kind,
    required this.values,
    required this.selected,
    required this.brand,
    required this.tokens,
    required this.onSelected,
  });

  final String kind;
  final List<TTimeColumnSlot> values;
  final int selected;
  final Color brand;
  final TDesignTokenSet tokens;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final disabledColor = tTokenColorOf(tokens, 'textColorDisabled');
    final anti = tTokenColorOf(tokens, 'textColorAnti');
    final primary = tTokenColorOf(tokens, 'textColorPrimary');
    return Expanded(
      child: ListView.builder(
        itemExtent: 32,
        itemCount: values.length,
        itemBuilder: (context, index) {
          final slot = values[index];
          final chosen = slot.value == selected;
          final Color color;
          if (slot.disabled) {
            color = disabledColor;
          } else if (chosen) {
            color = anti;
          } else {
            color = primary;
          }
          return GestureDetector(
            key: ValueKey<String>('$kind-${slot.value}'),
            onTap: slot.disabled ? null : () => onSelected(slot.value),
            child: ColoredBox(
              color: chosen ? brand : const Color(0x00000000),
              child: Center(
                child: Text(
                  slot.value.toString().padLeft(2, '0'),
                  style: TextStyle(fontSize: 14, color: color),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Hour / minute / (optional) second columns for a single [TTime]-like value.
class TTimeColumnsRow extends StatelessWidget {
  const TTimeColumnsRow({
    super.key,
    required this.kindPrefix,
    required this.hour,
    required this.minute,
    required this.second,
    required this.showSeconds,
    required this.hourStep,
    required this.minuteStep,
    required this.secondStep,
    required this.blockedHours,
    required this.blockedMinutes,
    required this.blockedSeconds,
    required this.hideDisabledTime,
    required this.markBlockedDisabled,
    required this.brand,
    required this.tokens,
    required this.onHour,
    required this.onMinute,
    required this.onSecond,
  });

  final String kindPrefix;
  final int hour;
  final int minute;
  final int second;
  final bool showSeconds;
  final int hourStep;
  final int minuteStep;
  final int secondStep;
  final List<int> blockedHours;
  final List<int> blockedMinutes;
  final List<int> blockedSeconds;
  final bool hideDisabledTime;
  final bool markBlockedDisabled;
  final Color brand;
  final TDesignTokenSet tokens;
  final ValueChanged<int> onHour;
  final ValueChanged<int> onMinute;
  final ValueChanged<int> onSecond;

  String _kind(String unit) => kindPrefix.isEmpty ? unit : '$kindPrefix-$unit';

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TTimeColumn(
          kind: _kind('hour'),
          values: tTimeColumnSlots(
            limit: 24,
            step: hourStep,
            blocked: blockedHours,
            hideDisabledTime: hideDisabledTime,
            markBlockedDisabled: markBlockedDisabled,
          ),
          selected: hour,
          brand: brand,
          tokens: tokens,
          onSelected: onHour,
        ),
        TTimeColumn(
          kind: _kind('minute'),
          values: tTimeColumnSlots(
            limit: 60,
            step: minuteStep,
            blocked: blockedMinutes,
            hideDisabledTime: hideDisabledTime,
            markBlockedDisabled: markBlockedDisabled,
          ),
          selected: minute,
          brand: brand,
          tokens: tokens,
          onSelected: onMinute,
        ),
        if (showSeconds)
          TTimeColumn(
            kind: _kind('second'),
            values: tTimeColumnSlots(
              limit: 60,
              step: secondStep,
              blocked: blockedSeconds,
              hideDisabledTime: hideDisabledTime,
              markBlockedDisabled: markBlockedDisabled,
            ),
            selected: second,
            brand: brand,
            tokens: tokens,
            onSelected: onSecond,
          ),
      ],
    );
  }
}
