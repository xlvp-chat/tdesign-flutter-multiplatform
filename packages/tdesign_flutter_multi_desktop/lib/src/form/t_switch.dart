import 'package:flutter/widgets.dart';
import 'package:tdesign_flutter_multi_core/tdesign_flutter_multi_core.dart';

import '../token/t_token_color.dart';

/// Desktop switch — controlled [value] + [onChanged].
class TSwitch extends StatelessWidget {
  const TSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.enabled = true,
    this.size = TComponentSize.medium,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool enabled;
  final TComponentSize size;

  @override
  Widget build(BuildContext context) {
    final width = size == TComponentSize.small ? 32.0 : 40.0;
    final height = size == TComponentSize.small ? 18.0 : 22.0;
    final tokens = TDesignTokenScope.of(context);
    final brand = tTokenColorOf(tokens, 'brandColor7');
    final idle = tTokenColorOf(tokens, 'componentBorder');
    final track = enabled && value ? brand : idle;

    return TInteractiveRegion(
      enabled: enabled && onChanged != null,
      onActivate: () => onChanged?.call(!value),
      builder: (context, state) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: width,
          height: height,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: track,
            borderRadius: BorderRadius.circular(height),
            border: state == TComponentState.focused
                ? Border.all(color: brand, width: 2)
                : null,
          ),
          child: Align(
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: tTokenColorOf(tokens, 'textColorAnti'),
                shape: BoxShape.circle,
              ),
              child: SizedBox(width: height - 4, height: height - 4),
            ),
          ),
        );
      },
    );
  }
}
