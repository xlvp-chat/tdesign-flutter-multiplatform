import 'package:flutter/widgets.dart';

import '../token/t_token_color.dart';

/// Desktop badge overlay count/dot.
class TBadge extends StatelessWidget {
  const TBadge({
    super.key,
    required this.child,
    this.count,
    this.dot = false,
    this.max = 99,
    this.showZero = false,
  });

  final Widget child;
  final int? count;
  final bool dot;
  final int max;
  final bool showZero;

  bool get _visible {
    if (dot) return true;
    final value = count ?? 0;
    return showZero || value > 0;
  }

  String get _label {
    final value = count ?? 0;
    if (value > max) return '$max+';
    return '$value';
  }

  @override
  Widget build(BuildContext context) {
    final badge = tTokenColor(context, 'errorColor');
    final label = tTokenColor(context, 'textColorAnti');
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (_visible)
          Positioned(
            top: -6,
            right: -6,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: badge,
                shape: dot ? BoxShape.circle : BoxShape.rectangle,
                borderRadius: dot ? null : BorderRadius.circular(10),
              ),
              child: dot
                  ? const SizedBox(width: 8, height: 8)
                  : Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1,
                      ),
                      child: Text(
                        _label,
                        style: TextStyle(
                          color: label,
                          fontSize: 11,
                          height: 1.2,
                        ),
                      ),
                    ),
            ),
          ),
      ],
    );
  }
}
