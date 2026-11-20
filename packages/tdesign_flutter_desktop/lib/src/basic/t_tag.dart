import 'package:flutter/widgets.dart';
import 'package:tdesign_flutter_core/tdesign_flutter_core.dart';

import '../token/t_token_color.dart';

enum TTagTheme { defaultTheme, primary, warning, danger, success }

/// Compact desktop tag.
class TTag extends StatelessWidget {
  const TTag({
    super.key,
    required this.child,
    this.theme = TTagTheme.defaultTheme,
    this.size = TComponentSize.medium,
    this.closable = false,
    this.onClose,
  });

  final Widget child;
  final TTagTheme theme;
  final TComponentSize size;
  final bool closable;
  final VoidCallback? onClose;

  static const _tokenKeys = <TTagTheme, (String, String)>{
    TTagTheme.primary: ('brandColorLight', 'brandColor7'),
    TTagTheme.warning: ('warningColorLight', 'warningColor'),
    TTagTheme.danger: ('errorColorLight', 'errorColor'),
    TTagTheme.success: ('successColorLight', 'successColor'),
    TTagTheme.defaultTheme: ('bgColorContainerHover', 'textColorPrimary'),
  };

  @override
  Widget build(BuildContext context) {
    final tokens = TDesignTokenScope.of(context);
    final (bgKey, fgKey) = _tokenKeys[theme]!;
    final pad = size == TComponentSize.small
        ? const EdgeInsets.symmetric(horizontal: 6, vertical: 1)
        : const EdgeInsets.symmetric(horizontal: 8, vertical: 2);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tTokenColorOf(tokens, bgKey),
        borderRadius: BorderRadius.circular(tTokenRadius(tokens)),
      ),
      child: Padding(
        padding: pad,
        child: DefaultTextStyle(
          style: TextStyle(color: tTokenColorOf(tokens, fgKey), fontSize: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              child,
              if (closable) ...[
                const SizedBox(width: 4),
                TInteractiveRegion(
                  onActivate: onClose,
                  builder: (context, state) => const Text('×'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
