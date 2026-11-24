import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:tdesign_flutter_icons/tdesign_flutter_icons.dart';
import 'package:tdesign_flutter_multi_core/tdesign_flutter_multi_core.dart';

import '../basic/t_icon.dart';
import '../token/t_token_color.dart';

/// Message theme. Maps to Vue Next `info` / `success` / `warning` / `error`.
enum TMessageTheme { info, success, warning, error }

/// Inserts a top-center message into the nearest [Overlay].
abstract final class TMessage {
  static OverlayEntry? _entry;

  static void show(
    BuildContext context, {
    required String content,
    TMessageTheme theme = TMessageTheme.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    _entry?.remove();
    _entry = null;
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _MessageBanner(
        content: content,
        theme: theme,
        duration: duration,
        onClose: () {
          entry.remove();
          if (_entry == entry) _entry = null;
        },
      ),
    );
    _entry = entry;
    Overlay.of(context).insert(entry);
  }
}

class _MessageBanner extends StatefulWidget {
  const _MessageBanner({
    required this.content,
    required this.theme,
    required this.duration,
    required this.onClose,
  });

  final String content;
  final TMessageTheme theme;
  final Duration duration;
  final VoidCallback onClose;

  @override
  State<_MessageBanner> createState() => _MessageBannerState();
}

class _MessageBannerState extends State<_MessageBanner> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.duration > Duration.zero) {
      _timer = Timer(widget.duration, widget.onClose);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = TDesignTokenScope.of(context);
    return Positioned(
      top: 16,
      left: 0,
      right: 0,
      child: Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: tTokenColorOf(tokens, 'bgColorContainer'),
            borderRadius: BorderRadius.circular(tTokenRadius(tokens)),
            boxShadow: tTokenShadows(tokens, 'shadow2'),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TIcon(_icon, size: 20, color: _color(tokens)),
                const SizedBox(width: 8),
                Text(
                  widget.content,
                  style: TextStyle(
                    fontSize: 14,
                    color: tTokenColorOf(tokens, 'textColorPrimary'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData get _icon {
    switch (widget.theme) {
      case TMessageTheme.info:
        return TIcons.info_circle_filled;
      case TMessageTheme.success:
        return TIcons.check_circle_filled;
      case TMessageTheme.warning:
        return TIcons.error_circle_filled;
      case TMessageTheme.error:
        return TIcons.error_circle_filled;
    }
  }

  Color _color(TDesignTokenSet tokens) {
    switch (widget.theme) {
      case TMessageTheme.info:
        return tTokenColorOf(tokens, 'brandColor7');
      case TMessageTheme.success:
        return tTokenColorOf(tokens, 'successColor5');
      case TMessageTheme.warning:
        return tTokenColorOf(tokens, 'warningColor5');
      case TMessageTheme.error:
        return tTokenColorOf(tokens, 'errorColor');
    }
  }
}
