import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:tdesign_flutter_icons/tdesign_flutter_icons.dart';
import 'package:tdesign_flutter_multi_core/tdesign_flutter_multi_core.dart';

import '../basic/t_button.dart';
import '../basic/t_icon.dart';
import 't_input.dart';

/// Desktop numeric stepper input — controlled [value] + [onChanged].
class TInputNumber extends StatelessWidget {
  const TInputNumber({
    super.key,
    required this.value,
    this.onChanged,
    this.min,
    this.max,
    this.step = 1,
    this.enabled = true,
  });

  final num value;
  final ValueChanged<num>? onChanged;
  final num? min;
  final num? max;
  final num step;
  final bool enabled;

  void _emit(num next) {
    var value = next;
    if (min != null && value < min!) value = min!;
    if (max != null && value > max!) value = max!;
    onChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TButton(
          size: TComponentSize.small,
          theme: TButtonTheme.defaultTheme,
          variant: TButtonVariant.outline,
          onPressed: enabled ? () => _emit(value - step) : null,
          child: const TIcon(TIcons.remove),
        ),
        const SizedBox(width: 4),
        SizedBox(
          width: 88,
          child: CallbackShortcuts(
            bindings: <ShortcutActivator, VoidCallback>{
              const SingleActivator(LogicalKeyboardKey.arrowUp): () =>
                  _emit(value + step),
              const SingleActivator(LogicalKeyboardKey.arrowDown): () =>
                  _emit(value - step),
            },
            child: TInput(
              value: '$value',
              enabled: enabled,
              onChanged: (text) {
                final parsed = num.tryParse(text);
                if (parsed != null) _emit(parsed);
              },
            ),
          ),
        ),
        const SizedBox(width: 4),
        TButton(
          size: TComponentSize.small,
          theme: TButtonTheme.defaultTheme,
          variant: TButtonVariant.outline,
          onPressed: enabled ? () => _emit(value + step) : null,
          child: const TIcon(TIcons.add),
        ),
      ],
    );
  }
}
