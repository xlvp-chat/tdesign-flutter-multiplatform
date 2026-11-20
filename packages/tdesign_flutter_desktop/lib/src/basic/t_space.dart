import 'package:flutter/widgets.dart';

/// Desktop spacing layout helper (row/column with gap).
class TSpace extends StatelessWidget {
  const TSpace({
    super.key,
    required this.children,
    this.direction = Axis.horizontal,
    this.size = 8,
    this.align = WrapAlignment.start,
    this.crossAxisAlignment = WrapCrossAlignment.center,
  });

  final List<Widget> children;
  final Axis direction;
  final double size;
  final WrapAlignment align;
  final WrapCrossAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      direction: direction,
      spacing: size,
      runSpacing: size,
      alignment: align,
      crossAxisAlignment: crossAxisAlignment,
      children: children,
    );
  }
}
