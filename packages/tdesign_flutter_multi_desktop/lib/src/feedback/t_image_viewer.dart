import 'package:flutter/widgets.dart';
import 'package:tdesign_flutter_icons/tdesign_flutter_icons.dart';

import '../basic/t_icon.dart';

const Color _kViewerScrim = Color(0xCC000000);
const Color _kViewerForeground = Color(0xFFFFFFFF);

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

  void _close() => widget.onVisibleChanged(false);

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _controller,
      overlayChildBuilder: _buildOverlay,
      child: const SizedBox.shrink(),
    );
  }

  Widget _buildOverlay(BuildContext _) {
    final images = widget.images;
    final index = widget.index.clamp(0, images.length - 1);
    return Stack(
      children: [
        Positioned.fill(child: _scrim()),
        Center(
          child: Image(image: images[index], fit: BoxFit.contain),
        ),
        _closeButton(),
        if (index > 0)
          _navButton(
            atStart: true,
            buttonKey: const ValueKey<String>('TImageViewer.prev'),
            icon: TIcons.chevron_left,
            onTap: () => widget.onIndexChanged(index - 1),
          ),
        if (index < images.length - 1)
          _navButton(
            atStart: false,
            buttonKey: const ValueKey<String>('TImageViewer.next'),
            icon: TIcons.chevron_right,
            onTap: () => widget.onIndexChanged(index + 1),
          ),
      ],
    );
  }

  Widget _scrim() {
    return GestureDetector(
      onTap: _close,
      child: const ColoredBox(color: _kViewerScrim),
    );
  }

  Widget _closeButton() {
    return Positioned(
      top: 16,
      right: 16,
      child: GestureDetector(
        key: const ValueKey<String>('TImageViewer.close'),
        onTap: _close,
        child: const TIcon(TIcons.close, color: _kViewerForeground, size: 24),
      ),
    );
  }

  Widget _navButton({
    required bool atStart,
    required Key buttonKey,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Positioned(
      left: atStart ? 16 : null,
      right: atStart ? null : 16,
      top: 0,
      bottom: 0,
      child: Center(
        child: GestureDetector(
          key: buttonKey,
          onTap: onTap,
          child: TIcon(icon, color: _kViewerForeground, size: 32),
        ),
      ),
    );
  }
}
