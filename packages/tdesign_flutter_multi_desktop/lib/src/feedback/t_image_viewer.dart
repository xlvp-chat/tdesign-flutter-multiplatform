import 'package:flutter/widgets.dart';
import 'package:tdesign_flutter_icons/tdesign_flutter_icons.dart';

import '../basic/t_icon.dart';

/// Full-screen image preview. [index] is controlled by the caller.
class TImageViewer extends StatefulWidget {
  const TImageViewer({
    super.key,
    required this.visible,
    required this.images,
    required this.index,
    required this.onVisibleChanged,
    required this.onIndexChanged,
  });

  final bool visible;
  final List<ImageProvider> images;
  final int index;
  final ValueChanged<bool> onVisibleChanged;
  final ValueChanged<int> onIndexChanged;

  @override
  State<TImageViewer> createState() => _TImageViewerState();
}

class _TImageViewerState extends State<TImageViewer> {
  final _controller = OverlayPortalController();

  @override
  void initState() {
    super.initState();
    if (widget.visible) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
    }
  }

  @override
  void didUpdateWidget(covariant TImageViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible == oldWidget.visible) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _sync();
    });
  }

  void _sync() {
    if (widget.visible && widget.images.isNotEmpty) {
      if (!_controller.isShowing) _controller.show();
    } else if (_controller.isShowing) {
      _controller.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _controller,
      overlayChildBuilder: (context) {
        final index = widget.index.clamp(0, widget.images.length - 1);
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () => widget.onVisibleChanged(false),
                child: const ColoredBox(color: Color(0xCC000000)),
              ),
            ),
            Center(
              child: Image(
                image: widget.images[index],
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                key: const ValueKey<String>('TImageViewer.close'),
                onTap: () => widget.onVisibleChanged(false),
                child: const TIcon(TIcons.close, color: Color(0xFFFFFFFF), size: 24),
              ),
            ),
            if (index > 0)
              Positioned(
                left: 16,
                top: 0,
                bottom: 0,
                child: Center(
                  child: GestureDetector(
                    key: const ValueKey<String>('TImageViewer.prev'),
                    onTap: () => widget.onIndexChanged(index - 1),
                    child: const TIcon(
                      TIcons.chevron_left,
                      color: Color(0xFFFFFFFF),
                      size: 32,
                    ),
                  ),
                ),
              ),
            if (index < widget.images.length - 1)
              Positioned(
                right: 16,
                top: 0,
                bottom: 0,
                child: Center(
                  child: GestureDetector(
                    key: const ValueKey<String>('TImageViewer.next'),
                    onTap: () => widget.onIndexChanged(index + 1),
                    child: const TIcon(
                      TIcons.chevron_right,
                      color: Color(0xFFFFFFFF),
                      size: 32,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
      child: const SizedBox.shrink(),
    );
  }
}
