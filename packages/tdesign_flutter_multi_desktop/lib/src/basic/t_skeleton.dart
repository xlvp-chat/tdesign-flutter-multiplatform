import 'package:flutter/widgets.dart';

import '../token/t_token_color.dart';

/// Shows placeholder bars while [loading], otherwise [child].
class TSkeleton extends StatelessWidget {
  const TSkeleton({
    super.key,
    this.loading = true,
    this.rows = 3,
    this.child,
  });

  final bool loading;
  final int rows;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    if (!loading) return child ?? const SizedBox.shrink();
    final color = tTokenColor(context, 'bgColorComponentDisabled');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < rows; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          Container(
            key: ValueKey<String>('TSkeleton.row.$i'),
            height: 16,
            width: i == rows - 1 ? 120 : double.infinity,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ],
      ],
    );
  }
}
