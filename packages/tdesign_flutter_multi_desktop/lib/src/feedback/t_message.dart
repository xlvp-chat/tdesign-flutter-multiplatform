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
  static const _styles = <TMessageTheme, (IconData, String)>{
    TMessageTheme.info: (TIcons.info_circle_filled, 'brandColor7'),
    TMessageTheme.success: (TIcons.check_circle_filled, 'successColor5'),
    TMessageTheme.warning: (TIcons.error_circle_filled, 'warningColor5'),
    TMessageTheme.error: (TIcons.error_circle_filled, 'errorColor'),
  };

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
    final (icon, colorKey) = _styles[widget.theme]!;
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
                TIcon(icon, size: 20, color: tTokenColorOf(tokens, colorKey)),
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
}
