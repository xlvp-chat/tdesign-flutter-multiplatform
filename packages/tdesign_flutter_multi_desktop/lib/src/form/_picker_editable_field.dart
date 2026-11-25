import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:tdesign_flutter_icons/tdesign_flutter_icons.dart';
import 'package:tdesign_flutter_multi_core/tdesign_flutter_multi_core.dart';

import '../basic/t_icon.dart';
import '../token/t_token_color.dart';
import '_text_field_chrome.dart';

/// Shared 32px date/time picker trigger with optional [EditableText] and open/clear icons.
///
/// Package-internal; not exported from the barrel.
class TPickerEditableField extends StatelessWidget {
  const TPickerEditableField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.displayText,
    required this.muted,
    required this.enabled,
    required this.allowInput,
    required this.clearable,
    required this.onOpen,
    required this.onClear,
    required this.tokens,
    this.onSubmit,
    this.inputKey,
    this.openKey,

    /// When true, ▾ is always shown (DatePicker). When false, only if
    /// [allowInput] (Time / range pickers).
    this.alwaysShowOpen = false,
    this.textInputAction = TextInputAction.done,
  });

  final TextEditingController controller;
  final FocusNode focusNode;

  /// Label shown when [allowInput] is false (placeholder or formatted value).
  final String displayText;
  final bool muted;
  final bool enabled;
  final bool allowInput;
  final bool clearable;
  final VoidCallback? onOpen;
  final VoidCallback? onClear;
  final VoidCallback? onSubmit;
  final TDesignTokenSet tokens;
  final Key? inputKey;
  final Key? openKey;
  final bool alwaysShowOpen;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    final text = muted
        ? tTokenColorOf(tokens, 'textColorPlaceholder')
        : tTokenColorOf(tokens, 'textColorPrimary');
    final border = tTokenColorOf(tokens, 'componentBorder');
    final showOpen = alwaysShowOpen || allowInput;
    return DecoratedBox(
      decoration: tStaticFieldChrome(
        tokens,
        enabled: enabled,
        borderColor: border,
      ),
      child: SizedBox(
        height: 32,
        child: Row(
          children: [
            Expanded(
              child: allowInput
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: EditableText(
                        key: inputKey,
                        controller: controller,
                        focusNode: focusNode,
                        readOnly: !enabled,
                        style: TextStyle(fontSize: 14, color: text),
                        cursorColor: text,
                        backgroundCursorColor: border,
                        maxLines: 1,
                        textInputAction: textInputAction,
                        onSubmitted: (_) => onSubmit?.call(),
                        onTapOutside: (_) => focusNode.unfocus(),
                      ),
                    )
                  : GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onOpen,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            displayText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 14, color: text),
                          ),
                        ),
                      ),
                    ),
            ),
            if (showOpen)
              GestureDetector(
                key: openKey,
                behavior: HitTestBehavior.opaque,
                onTap: onOpen,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: TIcon(TIcons.calendar, size: TIconSizes.medium),
                ),
              ),
            if (clearable)
              GestureDetector(
                onTap: onClear,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: TIcon(
                    TIcons.close_circle_filled,
                    size: TIconSizes.input,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
