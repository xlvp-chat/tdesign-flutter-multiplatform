import 'package:flutter/widgets.dart';
import 'package:tdesign_flutter_icons/tdesign_flutter_icons.dart';

import '../basic/t_icon.dart';
import '../token/t_token_color.dart';

/// Scroll-to-top control. Visible after [controller] passes [visibilityHeight].
class TBackTop extends StatefulWidget {
  const TBackTop({
    super.key,
    required this.controller,
    this.visibilityHeight = 200,
    this.child,
  });

  final ScrollController controller;
  final double visibilityHeight;
  final Widget? child;

  @override
  State<TBackTop> createState() => _TBackTopState();
}

class _TBackTopState extends State<TBackTop> {
  var _visible = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onScroll);
    _sync();
  }

  @override
  void didUpdateWidget(covariant TBackTop oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) return;
    oldWidget.controller.removeListener(_onScroll);
    widget.controller.addListener(_onScroll);
    _sync();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() => _sync();

  void _sync() {
    if (!widget.controller.hasClients) return;
    final next = widget.controller.offset >= widget.visibilityHeight;
    if (next == _visible) return;
    setState(() => _visible = next);
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();
    final bg = tTokenColor(context, 'bgColorContainer');
    final border = tTokenColor(context, 'componentBorder');
    return GestureDetector(
      onTap: () {
        widget.controller.animateTo(
          0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: border),
          borderRadius: BorderRadius.circular(3),
        ),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Center(
            child: widget.child ??
                TIcon(
                  TIcons.chevron_up,
                  color: tTokenColor(context, 'textColorPrimary'),
                ),
          ),
        ),
      ),
    );
  }
}
