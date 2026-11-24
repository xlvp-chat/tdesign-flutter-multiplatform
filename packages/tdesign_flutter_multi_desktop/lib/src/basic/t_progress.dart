import 'package:flutter/widgets.dart';

import '../token/t_token_color.dart';

/// Line, plump, or circle progress. [percentage] is clamped to 0–100.
enum TProgressTheme { line, plump, circle }

class TProgress extends StatelessWidget {
  const TProgress({
    super.key,
    this.percentage = 0,
    this.theme = TProgressTheme.line,
    this.label = true,
  });

  final double percentage;
  final TProgressTheme theme;
  final bool label;

  double get _value => percentage.clamp(0, 100).toDouble();

  @override
  Widget build(BuildContext context) {
    final brand = tTokenColor(context, 'brandColor7');
    final track = tTokenColor(context, 'bgColorComponentDisabled');
    final text = tTokenColor(context, 'textColorPrimary');
    final caption = '${_value.round()}%';
    if (theme == TProgressTheme.circle) {
      return SizedBox(
        width: 112,
        height: 112,
        child: CustomPaint(
          painter: _CircleProgressPainter(
            value: _value / 100,
            color: brand,
            track: track,
          ),
          child: label
              ? Center(child: Text(caption, style: TextStyle(color: text)))
              : null,
        ),
      );
    }
    final height = theme == TProgressTheme.plump ? 20.0 : 8.0;
    final bar = ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: SizedBox(
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: track),
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: _value / 100,
              child: ColoredBox(color: brand),
            ),
            if (label && theme == TProgressTheme.plump)
              Center(
                child: Text(
                  caption,
                  style: TextStyle(
                    color: tTokenColor(context, 'textColorAnti'),
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
    if (!label || theme == TProgressTheme.plump) return bar;
    return Row(
      children: [
        Expanded(child: bar),
        const SizedBox(width: 8),
        Text(caption, style: TextStyle(fontSize: 12, color: text)),
      ],
    );
  }
}

class _CircleProgressPainter extends CustomPainter {
  _CircleProgressPainter({
    required this.value,
    required this.color,
    required this.track,
  });

  final double value;
  final Color color;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 6.0;
    final rect = Offset.zero & size;
    final deflated = rect.deflate(stroke);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(deflated, 0, 6.28318, false, paint..color = track);
    canvas.drawArc(
      deflated,
      -1.5708,
      6.28318 * value,
      false,
      paint..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _CircleProgressPainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.color != color ||
        oldDelegate.track != track;
  }
}
