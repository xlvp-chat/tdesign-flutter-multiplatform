import 'package:flutter/widgets.dart';
import 'package:tdesign_flutter_core/tdesign_flutter_core.dart';

import '../form/_popup_shell.dart';
import '../token/t_token_color.dart';

class TDropdownOption {
  const TDropdownOption({required this.value, required this.label});
  final String value;
  final Widget label;
}

/// Desktop dropdown menu triggered by [child] activate.
class TDropdown extends StatefulWidget {
  const TDropdown({
    super.key,
    required this.child,
    required this.options,
    required this.onSelected,
  });

  final Widget child;
  final List<TDropdownOption> options;
  final ValueChanged<String> onSelected;

  @override
  State<TDropdown> createState() => _TDropdownState();
}

class _TDropdownState extends State<TDropdown> {
  var _open = false;

  void _setOpen(bool value) => setState(() => _open = value);

  @override
  Widget build(BuildContext context) {
    return TOverlayPortal(
      visible: _open,
      onVisibleChanged: _setOpen,
      options: const TOverlayPortalOptions(
        preferredPlacement: TPlacement.bottomLeft,
        layer: TOverlayLayer.dropdown,
      ),
      anchor: TInteractiveRegion(
        onActivate: () => _setOpen(!_open),
        builder: (context, state) => widget.child,
      ),
      overlayBuilder: (context) {
        final tokens = TDesignTokenScope.of(context);
        return TPopupShell(
          tokens: tokens,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 140, maxWidth: 240),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final option in widget.options)
                  TInteractiveRegion(
                    onActivate: () {
                      widget.onSelected(option.value);
                      _setOpen(false);
                    },
                    builder: (context, state) {
                      return ColoredBox(
                        color: state == TComponentState.hovered
                            ? tTokenColorOf(tokens, 'bgColorContainerHover')
                            : const Color(0x00000000),
                        child: SizedBox(
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: DefaultTextStyle(
                              style: TextStyle(
                                color: tTokenColorOf(
                                  tokens,
                                  'textColorPrimary',
                                ),
                                fontSize: 14,
                              ),
                              child: option.label,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
