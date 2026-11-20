import 'package:flutter/widgets.dart';

import 'tdesign_tokens.g.dart';

/// Inherited [TDesignTokenSet] for one subtree.
///
/// [of] returns [TDesignTokens.light] when no scope is present, so existing
/// call sites keep light colors. Pass [TDesignTokens.dark] to recolor that
/// subtree only. This is not an application theme switch.
class TDesignTokenScope extends InheritedWidget {
  /// Provides [tokens] to [child].
  const TDesignTokenScope({
    super.key,
    required this.tokens,
    required super.child,
  });

  /// Token set read by descendants. Use [TDesignTokens.light] or
  /// [TDesignTokens.dark].
  final TDesignTokenSet tokens;

  /// The nearest scope, or [TDesignTokens.light] when none is present.
  static TDesignTokenSet of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<TDesignTokenScope>();
    return scope?.tokens ?? TDesignTokens.light;
  }

  @override
  bool updateShouldNotify(TDesignTokenScope oldWidget) {
    return oldWidget.tokens != tokens;
  }
}
