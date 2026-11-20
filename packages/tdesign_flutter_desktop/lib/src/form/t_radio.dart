import 'package:flutter/widgets.dart';
import 'package:tdesign_flutter_core/tdesign_flutter_core.dart';

import '../token/t_token_color.dart';

/// Single radio option. Prefer [TRadioGroup] for exclusive selection.
class TRadio<T> extends StatelessWidget {
  const TRadio({
    super.key,
    required this.value,
    required this.groupValue,
    this.onChanged,
    this.label,
    this.enabled = true,
  });

  final T value;
  final T? groupValue;
  final ValueChanged<T>? onChanged;
  final Widget? label;
  final bool enabled;

  bool get _checked => value == groupValue;

  @override
  Widget build(BuildContext context) {
    final tokens = TDesignTokenScope.of(context);
    final brand = tTokenColorOf(tokens, 'brandColor7');
    final border = tTokenColorOf(tokens, 'componentBorder');
    final enabledText = tTokenColorOf(tokens, 'textColorPrimary');
    final disabledText = tTokenColorOf(tokens, 'textColorSecondary');
    return TInteractiveRegion(
      enabled: enabled && onChanged != null,
      onActivate: () => onChanged?.call(value),
      builder: (context, state) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _checked ? brand : border,
                  width: state == TComponentState.focused ? 2 : 1,
                ),
              ),
              child: SizedBox(
                width: 16,
                height: 16,
                child: Center(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: _checked ? brand : const Color(0x00000000),
                      shape: BoxShape.circle,
                    ),
                    child: const SizedBox(width: 8, height: 8),
                  ),
                ),
              ),
            ),
            if (label != null) ...[
              const SizedBox(width: 8),
              DefaultTextStyle(
                style: TextStyle(
                  color: enabled ? enabledText : disabledText,
                  fontSize: 14,
                ),
                child: label!,
              ),
            ],
          ],
        );
      },
    );
  }
}

/// Exclusive radio group.
class TRadioGroup<T> extends StatelessWidget {
  const TRadioGroup({
    super.key,
    required this.value,
    required this.onChanged,
    required this.children,
    this.direction = Axis.horizontal,
    this.spacing = 16,
  });

  final T? value;
  final ValueChanged<T> onChanged;
  final List<TRadio<T>> children;
  final Axis direction;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final items = [
      for (final child in children)
        TRadio<T>(
          value: child.value,
          groupValue: value,
          onChanged: onChanged,
          label: child.label,
          enabled: child.enabled,
        ),
    ];
    if (direction == Axis.vertical) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) SizedBox(height: spacing),
            items[i],
          ],
        ],
      );
    }
    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) SizedBox(width: spacing),
          items[i],
        ],
      ],
    );
  }
}
