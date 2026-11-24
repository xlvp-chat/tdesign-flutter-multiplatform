import 'package:flutter/widgets.dart';
import 'package:tdesign_flutter_icons/tdesign_flutter_icons.dart';

import '../basic/t_icon.dart';
import '../token/t_token_color.dart';

/// One step label.
class TStepItem {
  const TStepItem({required this.title, this.content});

  final String title;
  final String? content;
}

/// Horizontal steps. Indexes before [current] are done; [current] is active.
class TSteps extends StatelessWidget {
  const TSteps({
    super.key,
    required this.items,
    this.current = 0,
  });

  final List<TStepItem> items;
  final int current;

  @override
  Widget build(BuildContext context) {
    final brand = tTokenColor(context, 'brandColor7');
    final muted = tTokenColor(context, 'textColorPlaceholder');
    final text = tTokenColor(context, 'textColorPrimary');
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < items.length; i++)
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _marker(i, brand, muted),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        items[i].title,
                        style: TextStyle(
                          fontSize: 14,
                          color: i <= current ? text : muted,
                        ),
                      ),
                      if (items[i].content != null)
                        Text(
                          items[i].content!,
                          style: TextStyle(fontSize: 12, color: muted),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _marker(int index, Color brand, Color muted) {
    if (index < current) {
      return TIcon(TIcons.check_circle_filled, color: brand, size: 22);
    }
    final active = index == current;
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? brand : null,
        border: Border.all(color: active ? brand : muted),
      ),
      child: Text(
        '${index + 1}',
        style: TextStyle(
          fontSize: 12,
          color: active ? const Color(0xFFFFFFFF) : muted,
        ),
      ),
    );
  }
}
