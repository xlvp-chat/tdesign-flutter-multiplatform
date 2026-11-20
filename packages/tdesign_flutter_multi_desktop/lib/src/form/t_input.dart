import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:tdesign_flutter_multi_core/tdesign_flutter_multi_core.dart';

import '../token/t_token_color.dart';
import '_text_field_chrome.dart';
import 't_form.dart';

/// Border status for [TInput].
///
/// Only the border color changes. Height, padding, and background stay the
/// same as [normal].
enum TInputStatus {
  /// Resting, hover, focus, and disabled borders.
  normal,

  /// Border color `successColor5`.
  success,

  /// Border color `warningColor5`.
  warning,

  /// Border color `errorColor6`.
  error,
}

/// Desktop single-line text field.
///
/// Horizontal padding is 8px, or 12px when [size] is [TComponentSize.large].
/// Status, brand, text, and container colors come from [TDesignTokenScope].
/// With no scope that is [TDesignTokens.light].
class TInput extends StatefulWidget {
  const TInput({
    super.key,
    this.value,
    this.onChanged,
    this.placeholder,
    this.enabled = true,
    this.size = TComponentSize.medium,
    this.prefix,
    this.suffix,
    this.clearable = false,
    this.obscureText = false,
    this.status = TInputStatus.normal,
    this.maxLength,
    this.showLimit = false,
  }) : assert(maxLength == null || maxLength >= 0);

  /// Controlled text. Null leaves the current text in place after the first build.
  final String? value;

  /// Called with the field text after an edit.
  ///
  /// The clear control calls this with `''`.
  final ValueChanged<String>? onChanged;

  /// Hint drawn when the current text is empty.
  ///
  /// The color is `textColorPlaceholder` (`#66000000` in the light tokens).
  /// A null or empty hint draws nothing. Hidden while the field has text.
  final String? placeholder;

  /// When false, the field is read-only and the clear control is hidden.
  final bool enabled;

  /// Height token. small is 28, medium is 32, large is 40.
  final TComponentSize size;

  /// Widget before the text, separated by 8px.
  final Widget? prefix;

  /// Widget after the built-in suffix controls, separated by 8px.
  final Widget? suffix;

  /// Shows a clear control when [enabled] is true and the text is not empty.
  ///
  /// Activating it calls [onChanged] with `''`. Defaults to false.
  final bool clearable;

  /// Masks the text and shows a suffix control that toggles visibility.
  ///
  /// Matches Vue `type="password"`. The toggle changes local visibility only,
  /// not the field value. Other HTML input types are not represented.
  /// Defaults to false.
  final bool obscureText;

  /// Border status. Defaults to [TInputStatus.normal].
  ///
  /// [TInputStatus.success], [TInputStatus.warning], and [TInputStatus.error]
  /// replace the border color with `successColor5`, `warningColor5`, and
  /// `errorColor6`. The height does not change.
  ///
  /// When this is [TInputStatus.normal] and the field sits in a
  /// [TFormFieldScope] whose rules failed, the border uses
  /// [TInputStatus.error]. Any other explicit status wins over that failure.
  final TInputStatus status;

  /// Maximum [String.length] of text the user can enter.
  ///
  /// One Chinese character counts as 1. This is not Vue `maxcharacter`.
  /// A longer edit is cut to this length when the field is still under the
  /// limit. A collapsed edit that starts already at the limit is ignored.
  /// Null means no limit. Defaults to null.
  final int? maxLength;

  /// Draws `current/max` on the right when this is true and [maxLength] is set.
  ///
  /// `current` is [String.length] of the current text. Defaults to false.
  final bool showLimit;

  @override
  State<TInput> createState() => _TInputState();
}

class _TInputState extends State<TInput> {
  late final TextEditingController _controller;
  final _focusNode = FocusNode();
  var _hovered = false;
  var _revealed = false;
  var _seenField = false;
  var _resetGeneration = -1;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value ?? '');
    _controller.addListener(_rebuild);
    _focusNode.addListener(_handleFocus);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = TFormFieldScope.maybeOf(context);
    if (scope == null) {
      _seenField = false;
      return;
    }
    if (scope.resetGeneration != _resetGeneration) {
      final seen = _seenField;
      _seenField = true;
      _resetGeneration = scope.resetGeneration;
      if (seen) {
        final restored = scope.value is String ? scope.value! as String : '';
        scope.report(restored);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          if (_controller.text != restored) _replaceText(restored);
          if (widget.value != restored) widget.onChanged?.call(restored);
        });
        return;
      }
    }
    _seenField = true;
    scope.report(_controller.text);
  }

  @override
  void didUpdateWidget(covariant TInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.obscureText != oldWidget.obscureText) {
      _revealed = false;
    }
    final next = widget.value;
    if (next != null && next != _controller.text) {
      _replaceText(next);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_rebuild);
    _focusNode.removeListener(_handleFocus);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _rebuild() {
    if (!mounted) return;
    setState(() {});
  }

  void _handleFocus() {
    if (!mounted) return;
    final focused = _focusNode.hasFocus;
    _rebuild();
    if (!focused) _report(_controller.text, TFormTrigger.blur);
  }

  void _emit(String value) {
    widget.onChanged?.call(value);
    _report(value, TFormTrigger.change);
  }

  void _report(String value, TFormTrigger? trigger) {
    if (!mounted) return;
    TFormFieldScope.maybeOf(context)?.report(value, trigger);
  }

  TInputStatus _resolvedStatus(BuildContext context) {
    if (widget.status != TInputStatus.normal) return widget.status;
    final scope = TFormFieldScope.maybeOf(context);
    if (scope != null && scope.hasError) return TInputStatus.error;
    return TInputStatus.normal;
  }

  void _replaceText(String text) {
    if (text == _controller.text) return;
    _controller.removeListener(_rebuild);
    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    _controller.addListener(_rebuild);
  }

  void _clear() {
    _replaceText('');
    _rebuild();
    _emit('');
  }

  void _toggleReveal() {
    setState(() => _revealed = !_revealed);
  }

  void _setHovered(bool hovered) {
    if (_hovered == hovered) return;
    setState(() => _hovered = hovered);
  }

  void _onEnter(PointerEnterEvent _) => _setHovered(true);

  void _onExit(PointerExitEvent _) => _setHovered(false);

  double get _height {
    switch (widget.size) {
      case TComponentSize.small:
        return 28;
      case TComponentSize.medium:
        return 32;
      case TComponentSize.large:
        return 40;
    }
  }

  /// Vue Next `@input-padding-default` is `0 8px`; large uses `paddingLR-m` (12).
  double get _horizontalPadding {
    return widget.size == TComponentSize.large ? 12 : 8;
  }

  bool get _obscured => widget.obscureText && !_revealed;

  Color _borderColor(
    TDesignTokenSet tokens, {
    required bool focused,
    required TInputStatus status,
  }) {
    switch (status) {
      case TInputStatus.success:
        return tTokenColorOf(tokens, 'successColor5', fallback: '#2BA471');
      case TInputStatus.warning:
        return tTokenColorOf(tokens, 'warningColor5', fallback: '#E37318');
      case TInputStatus.error:
        return tTokenColorOf(tokens, 'errorColor6', fallback: '#D54941');
      case TInputStatus.normal:
        return tTextFieldBorderColor(
          tokens,
          enabled: widget.enabled,
          focused: focused,
          hovered: _hovered,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = TDesignTokenScope.of(context);
    final focused = _focusNode.hasFocus;
    final status = _resolvedStatus(context);
    final text = _controller.text;
    final placeholder = widget.placeholder;
    final showPlaceholder =
        text.isEmpty && placeholder != null && placeholder.isNotEmpty;
    final affordanceStyle = TextStyle(
      color: tTokenColorOf(
        tokens,
        'textColorPlaceholder',
        fallback: '#66000000',
      ),
      fontSize: 12,
      height: 1,
    );

    return MouseRegion(
      onEnter: _onEnter,
      onExit: _onExit,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tTextFieldFillColor(tokens, enabled: widget.enabled),
          borderRadius: BorderRadius.circular(tTokenRadius(tokens)),
          border: Border.all(
            color: _borderColor(tokens, focused: focused, status: status),
          ),
        ),
        child: SizedBox(
          height: _height,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: _horizontalPadding),
            child: Row(
              children: [
                if (widget.prefix != null) ...[
                  widget.prefix!,
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      if (showPlaceholder)
                        IgnorePointer(
                          child: Text(
                            placeholder,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: tTokenColorOf(
                                tokens,
                                'textColorPlaceholder',
                                fallback: '#66000000',
                              ),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      EditableText(
                        controller: _controller,
                        focusNode: _focusNode,
                        style: TextStyle(
                          color: tTokenColorOf(
                            tokens,
                            'textColorPrimary',
                            fallback: '#000000',
                          ),
                          fontSize: 14,
                        ),
                        cursorColor: tTokenColorOf(
                          tokens,
                          'brandColor7',
                          fallback: '#0052D9',
                        ),
                        backgroundCursorColor: tTokenColorOf(
                          tokens,
                          'textColorSecondary',
                          fallback: '#99000000',
                        ),
                        obscureText: _obscured,
                        inputFormatters: _formatters(),
                        onChanged: _emit,
                        readOnly: !widget.enabled,
                      ),
                    ],
                  ),
                ),
                ..._trailing(text, affordanceStyle),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<TextInputFormatter>? _formatters() {
    final maxLength = widget.maxLength;
    if (maxLength == null) return null;
    return [_StringLengthLimiter(maxLength)];
  }

  List<Widget> _trailing(String text, TextStyle affordanceStyle) {
    final trailing = <Widget>[];
    if (widget.clearable && widget.enabled && text.isNotEmpty) {
      trailing.add(
        _SuffixButton(
          key: const ValueKey<String>('TInput.clear'),
          label: '清空',
          onActivate: _clear,
          child: Text('×', style: affordanceStyle.copyWith(fontSize: 16)),
        ),
      );
    }
    if (widget.obscureText) {
      trailing.add(
        _SuffixButton(
          key: const ValueKey<String>('TInput.obscure'),
          label: _revealed ? '隐藏密码' : '显示密码',
          onActivate: _toggleReveal,
          child: Text(_revealed ? '隐藏' : '显示', style: affordanceStyle),
        ),
      );
    }
    final maxLength = widget.maxLength;
    if (widget.showLimit && maxLength != null) {
      trailing.add(Text('${text.length}/$maxLength', style: affordanceStyle));
    }
    final suffix = widget.suffix;
    if (suffix != null) trailing.add(suffix);
    return [
      for (final item in trailing) ...[const SizedBox(width: 8), item],
    ];
  }
}

class _SuffixButton extends StatelessWidget {
  const _SuffixButton({
    required this.label,
    required this.onActivate,
    required this.child,
    super.key,
  });

  final String label;
  final VoidCallback onActivate;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      container: true,
      label: label,
      child: ExcludeSemantics(
        child: TInteractiveRegion(onActivate: onActivate, builder: _paint),
      ),
    );
  }

  Widget _paint(BuildContext context, TComponentState _) => child;
}

/// Keeps edits within [maxLength] UTF-16 code units.
///
/// A collapsed edit that starts already at the limit is dropped. Otherwise the
/// extra code units are cut off. Composing text may run past the limit while
/// an IME session is open; the commit is cut with [String.length].
class _StringLengthLimiter extends TextInputFormatter {
  const _StringLengthLimiter(this.maxLength);

  final int maxLength;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.length <= maxLength) return newValue;
    if (newValue.composing.isValid && _committedLength(newValue) <= maxLength) {
      return newValue;
    }
    if (oldValue.composing.isValid && !newValue.composing.isValid) {
      return _cut(newValue);
    }
    if (oldValue.text.length >= maxLength && oldValue.selection.isCollapsed) {
      return oldValue;
    }
    return _cut(newValue);
  }

  int _committedLength(TextEditingValue value) {
    final range = value.composing;
    final start = range.start.clamp(0, value.text.length).toInt();
    final end = range.end.clamp(start, value.text.length).toInt();
    return value.text.length - (end - start);
  }

  TextEditingValue _cut(TextEditingValue value) {
    final text = value.text.substring(0, maxLength);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
