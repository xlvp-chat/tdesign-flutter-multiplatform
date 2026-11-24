import 'package:flutter/widgets.dart';
import 'package:tdesign_flutter_icons/tdesign_flutter_icons.dart';

import '../token/t_token_color.dart';
import 't_icon.dart';

/// Integer star rating. Tap a star to set [value].
class TRate extends StatelessWidget {
  const TRate({
    super.key,
    required this.value,
    required this.onChanged,
    this.count = 5,
    this.disabled = false,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int count;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final active = tTokenColor(context, 'warningColor5');
    final idle = tTokenColor(context, 'componentBorder');
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= count; i++)
          GestureDetector(
            onTap: disabled ? null : () => onChanged(i),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: TIcon(
                i <= value ? TIcons.star_filled : TIcons.star,
                color: i <= value ? active : idle,
                size: 24,
              ),
            ),
          ),
      ],
    );
  }
}
