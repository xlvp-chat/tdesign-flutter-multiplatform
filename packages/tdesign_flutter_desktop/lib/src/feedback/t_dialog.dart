import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:tdesign_flutter_core/tdesign_flutter_core.dart';

import '../basic/t_button.dart';
import '../form/_popup_shell.dart';
import '../token/t_token_color.dart';

/// Desktop modal dialog — barrier, Esc, default confirm/cancel actions.
class TDialog extends StatefulWidget {
  const TDialog({
    super.key,
    required this.visible,
    required this.onVisibleChanged,
    required this.title,
    required this.body,
    this.confirmText = '确定',
    this.cancelText = '取消',
    this.onConfirm,
    this.onCancel,
  });

  final bool visible;
  final ValueChanged<bool> onVisibleChanged;
  final Widget title;
  final Widget body;
  final String confirmText;
  final String cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  @override
  State<TDialog> createState() => _TDialogState();
}

class _TDialogState extends State<TDialog> {
  final _controller = OverlayPortalController();
  FocusNode? _previousFocus;

  @override
  void initState() {
    super.initState();
    if (widget.visible) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _open());
    }
  }

  @override
  void didUpdateWidget(covariant TDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible == oldWidget.visible) return;
    final shouldOpen = widget.visible;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (shouldOpen) {
        _open();
      } else {
        _close(notify: false);
      }
    });
  }

  void _open() {
    _previousFocus = FocusManager.instance.primaryFocus;
    if (!_controller.isShowing) {
      _controller.show();
    }
  }

  void _close({bool notify = true}) {
    if (_controller.isShowing) {
      _controller.hide();
    }
    _previousFocus?.requestFocus();
    if (notify) {
      widget.onVisibleChanged(false);
    }
  }

  void _cancel() {
    widget.onCancel?.call();
    _close();
  }

  void _confirm() {
    widget.onConfirm?.call();
    _close();
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _controller,
      overlayChildBuilder: (context) {
        final tokens = TDesignTokenScope.of(context);
        return CallbackShortcuts(
          bindings: <ShortcutActivator, VoidCallback>{
            const SingleActivator(LogicalKeyboardKey.escape): _cancel,
          },
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _cancel,
                  child: ColoredBox(color: tTokenColorOf(tokens, 'maskActive')),
                ),
              ),
              Center(
                child: Focus(
                  autofocus: true,
                  child: GestureDetector(
                    onTap: () {}, // prevent barrier dismiss when clicking panel
                    child: TPopupShell(
                      tokens: tokens,
                      bordered: false,
                      shadowKey: 'shadow2',
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          minWidth: 360,
                          maxWidth: 480,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              DefaultTextStyle(
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: tTokenColorOf(
                                    tokens,
                                    'textColorPrimary',
                                  ),
                                ),
                                child: widget.title,
                              ),
                              const SizedBox(height: 16),
                              widget.body,
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TButton(
                                    theme: TButtonTheme.defaultTheme,
                                    variant: TButtonVariant.outline,
                                    onPressed: _cancel,
                                    child: Text(widget.cancelText),
                                  ),
                                  const SizedBox(width: 8),
                                  TButton(
                                    theme: TButtonTheme.primary,
                                    onPressed: _confirm,
                                    child: Text(widget.confirmText),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      child: const SizedBox.shrink(),
    );
  }
}
