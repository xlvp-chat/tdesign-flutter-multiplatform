import 'package:flutter/widgets.dart';

import '../token/t_token_color.dart';

/// Horizontal single-value slider. [value] stays within [min] and [max].
class TSlider extends StatelessWidget {
  const TSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 100,
    this.disabled = false,
  });

  final double value;
  final ValueChanged<double> onChanged;
  final double min;
  final double max;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final brand = tTokenColor(context, 'brandColor7');
    final track = tTokenColor(context, 'bgColorComponentDisabled');
    final span = (max - min).abs() < 0.0001 ? 1.0 : max - min;
    final t = ((value - min) / span).clamp(0.0, 1.0);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: disabled
              ? null
              : (details) => onChanged(_valueAt(details.localPosition.dx, width)),
          onHorizontalDragUpdate: disabled
              ? null
              : (details) => onChanged(_valueAt(details.localPosition.dx, width)),
          child: SizedBox(
            height: 24,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: track,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: t,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: brand,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Positioned(
                  left: (width - 16) * t,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: tTokenColor(context, 'bgColorContainer'),
                      shape: BoxShape.circle,
                      border: Border.all(color: brand, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  double _valueAt(double dx, double width) {
    final t = (dx / width).clamp(0.0, 1.0);
    return min + (max - min) * t;
  }
}
