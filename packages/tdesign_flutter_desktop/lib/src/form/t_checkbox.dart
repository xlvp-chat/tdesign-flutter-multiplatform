import 'package:flutter/widgets.dart';
import 'package:tdesign_flutter_core/tdesign_flutter_core.dart';

import '../token/t_token_color.dart';

/// Desktop checkbox — controlled [checked] + [onChanged].
class TCheckbox extends StatelessWidget {
  const TCheckbox({
    super.key,
    required this.checked,
    this.onChanged,
    this.label,
    this.enabled = true,
    this.indeterminate = false,
  });

  final bool checked;
  final ValueChanged<bool>? onChanged;
  final Widget? label;
  final bool enabled;
  final bool indeterminate;

  @override
  Widget build(BuildContext context) {
    final tokens = TDesignTokenScope.of(context);
    final active = checked || indeterminate;
    final color = tTokenColorOf(tokens, 'brandColor7');
    final border = tTokenColorOf(tokens, 'componentBorder');
    final mark = tTokenColorOf(tokens, 'textColorAnti');
    final enabledText = tTokenColorOf(tokens, 'textColorPrimary');
    final disabledText = tTokenColorOf(tokens, 'textColorSecondary');
    final String glyph;
    if (indeterminate) {
      glyph = '—';
    } else if (checked) {
      glyph = '✓';
    } else {
      glyph = '';
    }

    return TInteractiveRegion(
      enabled: enabled && onChanged != null,
      onActivate: () => onChanged?.call(!checked),
      builder: (context, state) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: active ? color : const Color(0x00000000),
                borderRadius: BorderRadius.circular(2),
                border: Border.all(
                  color: active ? color : border,
                  width: state == TComponentState.focused ? 2 : 1,
                ),
              ),
              child: SizedBox(
                width: 16,
                height: 16,
                child: Center(
                  child: Text(
                    glyph,
                    style: TextStyle(
                      color: active ? mark : null,
                      fontSize: 11,
                      height: 1,
                    ),
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
