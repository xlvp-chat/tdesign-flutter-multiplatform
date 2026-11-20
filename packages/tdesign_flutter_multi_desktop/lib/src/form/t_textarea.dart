import 'package:flutter/widgets.dart';
import 'package:tdesign_flutter_multi_core/tdesign_flutter_multi_core.dart';

import '../token/t_token_color.dart';
import '_text_field_chrome.dart';

/// Desktop multiline text input — controlled [value] + [onChanged].
class TTextarea extends StatefulWidget {
  const TTextarea({
    super.key,
    this.value,
    this.onChanged,
    this.placeholder,
    this.enabled = true,
    this.minLines = 3,
    this.maxLines = 6,
  });

  final String? value;
  final ValueChanged<String>? onChanged;
  final String? placeholder;
  final bool enabled;
  final int minLines;
  final int maxLines;

  @override
  State<TTextarea> createState() => _TTextareaState();
}

class _TTextareaState extends State<TTextarea> {
  late final TextEditingController _controller;
  final _focusNode = FocusNode();
  var _hovered = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value ?? '');
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void didUpdateWidget(covariant TTextarea oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != null && widget.value != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.value!,
        selection: TextSelection.collapsed(offset: widget.value!.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _setHovered(bool hovered) {
    if (_hovered == hovered) return;
    setState(() => _hovered = hovered);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = TDesignTokenScope.of(context);
    final focused = _focusNode.hasFocus;
    final brand = tTokenColorOf(tokens, 'brandColor7');

    return MouseRegion(
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tTextFieldFillColor(tokens, enabled: widget.enabled),
          borderRadius: BorderRadius.circular(tTokenRadius(tokens)),
          border: Border.all(
            color: tTextFieldBorderColor(
              tokens,
              enabled: widget.enabled,
              focused: focused,
              hovered: _hovered,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: EditableText(
            controller: _controller,
            focusNode: _focusNode,
            maxLines: widget.maxLines,
            minLines: widget.minLines,
            style: TextStyle(
              color: tTokenColorOf(tokens, 'textColorPrimary'),
              fontSize: 14,
              height: 1.5,
            ),
            cursorColor: brand,
            backgroundCursorColor: tTokenColorOf(tokens, 'textColorSecondary'),
            onChanged: widget.onChanged,
            readOnly: !widget.enabled,
          ),
        ),
      ),
    );
  }
}
