import 'package:flutter/widgets.dart';
import 'package:tdesign_flutter_icons/tdesign_flutter_icons.dart';
import 'package:tdesign_flutter_multi_core/tdesign_flutter_multi_core.dart';

import '../basic/t_icon.dart';
import '../token/t_token_color.dart';
import '_text_field_chrome.dart';

/// Shared 32px static label trigger (Cascader / TreeSelect): background, border,
/// clear or caret affordance. Package-internal; not exported from the barrel.
class TPopupLabelField extends StatelessWidget {
  const TPopupLabelField({
    super.key,
    required this.label,
    required this.muted,
    required this.enabled,
    required this.clearable,
    required this.onOpen,
    required this.onClear,
    required this.tokens,
  });

  final String label;
  final bool muted;
  final bool enabled;
  final bool clearable;
  final VoidCallback? onOpen;
  final VoidCallback onClear;
  final TDesignTokenSet tokens;

  @override
  Widget build(BuildContext context) {
    final text = muted
        ? tTokenColorOf(tokens, 'textColorPlaceholder')
        : tTokenColorOf(tokens, 'textColorPrimary');
    return DecoratedBox(
      decoration: tStaticFieldChrome(tokens, enabled: enabled),
      child: SizedBox(
        height: 32,
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onOpen,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14, color: text),
                    ),
                  ),
                ),
              ),
            ),
            if (clearable)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onClear,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: TIcon(
                    TIcons.close_circle_filled,
                    size: TIconSizes.input,
                  ),
                ),
              )
            else
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: TIcon(
                  TIcons.caret_down_small,
                  size: TIconSizes.medium,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
