import 'package:flutter/widgets.dart';
import 'package:tdesign_flutter_multi_core/tdesign_flutter_multi_core.dart';

import '../token/t_token_color.dart';

enum TLinkTheme { defaultTheme, primary, danger, success, warning }

/// Desktop text link.
class TLink extends StatelessWidget {
  const TLink({
    super.key,
    required this.child,
    this.onPressed,
    this.theme = TLinkTheme.primary,
    this.disabled = false,
    this.underline = true,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final TLinkTheme theme;
  final bool disabled;
  final bool underline;

  String _colorKey(bool disabled) {
    if (disabled) return 'textColorSecondary';
    switch (theme) {
      case TLinkTheme.primary:
        return 'brandColor7';
      case TLinkTheme.danger:
        return 'errorColor';
      case TLinkTheme.success:
        return 'successColor';
      case TLinkTheme.warning:
        return 'warningColor';
      case TLinkTheme.defaultTheme:
        return 'textColorPrimary';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = tTokenColor(context, _colorKey(disabled));
    return TInteractiveRegion(
      enabled: !disabled && onPressed != null,
      onActivate: onPressed,
      builder: (context, state) {
        final hovered = state == TComponentState.hovered;
        return DefaultTextStyle(
          style: TextStyle(
            color: color,
            fontSize: 14,
            decoration: underline || hovered
                ? TextDecoration.underline
                : TextDecoration.none,
            decorationColor: color,
          ),
          child: child,
        );
      },
    );
  }
}
