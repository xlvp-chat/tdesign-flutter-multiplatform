import 'package:flutter/widgets.dart';

import '../token/t_token_color.dart';

/// One collapsible section.
class TCollapsePanel {
  const TCollapsePanel({
    required this.title,
    required this.child,
    this.disabled = false,
  });

  final String title;
  final Widget child;
  final bool disabled;
}

/// Accordion or multi-expand panels. [value] is the expanded indexes.
class TCollapse extends StatelessWidget {
  const TCollapse({
    super.key,
    required this.panels,
    required this.value,
    required this.onChanged,
    this.accordion = false,
  });

  final List<TCollapsePanel> panels;
  final List<int> value;
  final ValueChanged<List<int>> onChanged;
  final bool accordion;

  @override
  Widget build(BuildContext context) {
    final border = tTokenColor(context, 'componentBorder');
    return Column(
      children: [
        for (var i = 0; i < panels.length; i++)
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: border)),
            ),
            child: _Panel(
              panel: panels[i],
              expanded: value.contains(i),
              onTap: panels[i].disabled
                  ? null
                  : () {
                      if (accordion) {
                        onChanged(value.contains(i) ? const [] : [i]);
                      } else if (value.contains(i)) {
                        onChanged([...value]..remove(i));
                      } else {
                        onChanged([...value, i]);
                      }
                    },
            ),
          ),
      ],
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.panel,
    required this.expanded,
    required this.onTap,
  });

  final TCollapsePanel panel;
  final bool expanded;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final text = tTokenColor(context, 'textColorPrimary');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(panel.title, style: TextStyle(fontSize: 14, color: text)),
          ),
        ),
        if (expanded)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: panel.child,
          ),
      ],
    );
  }
}
