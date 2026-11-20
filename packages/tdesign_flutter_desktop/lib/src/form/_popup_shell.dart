import 'package:flutter/widgets.dart';
import 'package:tdesign_flutter_core/tdesign_flutter_core.dart';

import '../token/t_token_color.dart';

/// Shared overlay chrome: container fill, optional border, radius, and shadow.
///
/// Package-internal; not exported from the barrel.
class TPopupShell extends StatelessWidget {
  const TPopupShell({
    super.key,
    required this.tokens,
    required this.child,
    this.colorKey = 'bgColorContainer',
    this.bordered = true,
    this.shadowKey = 'shadow1',
  });

  final TDesignTokenSet tokens;
  final Widget child;

  /// Fill color token name. Defaults to `bgColorContainer`.
  final String colorKey;

  /// When true, draws a 1px `componentBorder`. Defaults to true.
  final bool bordered;

  /// Shadow token name (`shadow1` / `shadow2`), or `null` for no shadow.
  final String? shadowKey;

  @override
  Widget build(BuildContext context) {
    final shadow = shadowKey;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tTokenColorOf(tokens, colorKey),
        borderRadius: BorderRadius.circular(tTokenRadius(tokens)),
        border: bordered
            ? Border.all(color: tTokenColorOf(tokens, 'componentBorder'))
            : null,
        boxShadow: shadow == null ? null : tTokenShadows(tokens, shadow),
      ),
      child: child,
    );
  }
}
