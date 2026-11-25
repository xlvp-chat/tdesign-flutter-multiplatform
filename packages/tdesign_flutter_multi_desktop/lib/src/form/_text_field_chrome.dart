import 'package:flutter/widgets.dart';
import 'package:tdesign_flutter_multi_core/tdesign_flutter_multi_core.dart';

import '../token/t_token_color.dart';

/// Resting / hover / focus / disabled border for [TInput] / [TTextarea].
///
/// Status borders (success / warning / error) stay in [TInput].
Color tTextFieldBorderColor(
  TDesignTokenSet tokens, {
  required bool enabled,
  required bool focused,
  required bool hovered,
}) {
  if (!enabled) return tTokenColorOf(tokens, 'componentBorder');
  if (focused) return tTokenColorOf(tokens, 'brandColor7');
  if (hovered) return tTokenColorOf(tokens, 'textColorSecondary');
  return tTokenColorOf(tokens, 'componentBorder');
}

/// Enabled / disabled fill for single- and multiline text fields.
Color tTextFieldFillColor(TDesignTokenSet tokens, {required bool enabled}) {
  if (enabled) return tTokenColorOf(tokens, 'bgColorContainer');
  return tTokenColorOf(tokens, 'bgColorComponentDisabled');
}

/// Fill, radius, and a 1px border shared by text fields and popup triggers.
///
/// [borderColor] defaults to `componentBorder`. Callers pass a status or
/// error color when the border is not the resting token.
BoxDecoration tStaticFieldChrome(
  TDesignTokenSet tokens, {
  required bool enabled,
  Color? borderColor,
}) {
  return BoxDecoration(
    color: tTextFieldFillColor(tokens, enabled: enabled),
    borderRadius: BorderRadius.circular(tTokenRadius(tokens)),
    border: Border.all(
      color: borderColor ?? tTokenColorOf(tokens, 'componentBorder'),
    ),
  );
}
