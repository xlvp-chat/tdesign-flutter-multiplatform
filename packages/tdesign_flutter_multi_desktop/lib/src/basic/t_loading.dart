import 'package:flutter/widgets.dart';

import '../token/t_token_color.dart';

/// Covers [child] with a spinner while [loading] is true.
class TLoading extends StatefulWidget {
  const TLoading({
    super.key,
    required this.child,
    this.loading = true,
    this.text,
  });

  final Widget child;
  final bool loading;
  final String? text;

  @override
  State<TLoading> createState() => _TLoadingState();
}

class _TLoadingState extends State<TLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  );

  @override
  void initState() {
    super.initState();
    if (widget.loading) _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant TLoading oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.loading && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.loading && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        widget.child,
        if (widget.loading)
          Positioned.fill(
            child: ColoredBox(
              color: tTokenColor(context, 'bgColorContainer').withValues(
                alpha: 0.72,
              ),
              child: Center(
                child: OverflowBox(
                  maxWidth: 240,
                  maxHeight: 80,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RotationTransition(
                        turns: _controller,
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CustomPaint(
                            painter: _SpinnerPainter(
                              tTokenColor(context, 'brandColor7'),
                            ),
                          ),
                        ),
                      ),
                      if (widget.text != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          widget.text!,
                          style: TextStyle(
                            fontSize: 12,
                            color: tTokenColor(context, 'textColorSecondary'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _SpinnerPainter extends CustomPainter {
  _SpinnerPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Offset.zero & size,
      0,
      4.2,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _SpinnerPainter oldDelegate) =>
      oldDelegate.color != color;
}
