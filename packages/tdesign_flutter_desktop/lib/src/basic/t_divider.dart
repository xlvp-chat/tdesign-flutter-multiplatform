import 'package:flutter/widgets.dart';

import '../token/t_token_color.dart';

/// Desktop horizontal/vertical divider.
///
/// [color] defaults to the `borderLevel1Color` token.
class TDivider extends StatelessWidget {
  const TDivider({
    super.key,
    this.vertical = false,
    this.color,
    this.thickness = 1,
    this.indent = 0,
    this.endIndent = 0,
  });

  final bool vertical;

  /// Line color. Null uses `borderLevel1Color`.
  final Color? color;
  final double thickness;
  final double indent;
  final double endIndent;

  @override
  Widget build(BuildContext context) {
    final line = color ?? tTokenColor(context, 'borderLevel1Color');
    if (vertical) {
      return Container(
        margin: EdgeInsets.only(top: indent, bottom: endIndent),
        width: thickness,
        color: line,
      );
    }
    return Container(
      margin: EdgeInsets.only(left: indent, right: endIndent),
      height: thickness,
      color: line,
    );
  }
}
