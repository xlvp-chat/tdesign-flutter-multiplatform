import 'package:flutter/widgets.dart';

import '../basic/t_link.dart';
import '../token/t_token_color.dart';

class TBreadcrumbItem {
  const TBreadcrumbItem({required this.label, this.onPressed});
  final Widget label;
  final VoidCallback? onPressed;
}

/// Desktop breadcrumb trail.
class TBreadcrumb extends StatelessWidget {
  const TBreadcrumb({
    super.key,
    required this.items,
    this.separator = '/',
  });

  final List<TBreadcrumbItem> items;
  final String separator;

  @override
  Widget build(BuildContext context) {
    final primary = tTokenColor(context, 'textColorPrimary');
    final secondary = tTokenColor(context, 'textColorSecondary');
    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                separator,
                style: TextStyle(color: secondary, fontSize: 12),
              ),
            ),
          if (i == items.length - 1 || items[i].onPressed == null)
            DefaultTextStyle(
              style: TextStyle(
                color: i == items.length - 1 ? primary : secondary,
                fontSize: 14,
              ),
              child: items[i].label,
            )
          else
            TLink(
              onPressed: items[i].onPressed,
              underline: false,
              child: items[i].label,
            ),
        ],
      ],
    );
  }
}
