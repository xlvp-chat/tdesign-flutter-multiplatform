import 'package:flutter/widgets.dart';
import 'package:tdesign_flutter_multi_core/tdesign_flutter_multi_core.dart';

import '../token/t_token_color.dart';

/// Color theme for [TButton].
///
/// [defaultTheme] is the neutral theme. The name avoids the Dart keyword
/// `default`. A brand-filled button uses [primary].
enum TButtonTheme { defaultTheme, primary, danger, warning, success }

/// Visual form of [TButton].
///
/// [base] is filled. [outline] and [dashed] draw a 1px border in the theme
/// color; [dashed] uses a dashed stroke. [text] has no border or fill.
enum TButtonVariant { base, outline, dashed, text }

/// Outer shape of [TButton].
///
/// [rectangle] and [square] use `radiusDefault`. [round] and [circle] use half
/// the size height as the corner radius. [square] and [circle] set the width
/// to that height: small 24, medium 32, large 40.
enum TButtonShape { rectangle, square, round, circle }

/// Desktop button.
///
/// Defaults are [TButtonTheme.defaultTheme], [TButtonVariant.base],
/// [ghost] false, and [TButtonShape.rectangle]. Pass
/// `theme: TButtonTheme.primary` for a brand-filled button.
///
/// [icon] sits before [child]; [suffix] after. [block] stretches to the
/// parent width (ignored for square / circle).
///
/// [href] is link metadata only — Flutter has no `<a>` tag, so navigation
/// stays in [onPressed].
///
/// Status, brand, text, and container colors come from [TDesignTokenScope].
/// With no scope that is [TDesignTokens.light]. A filled
/// [TButtonTheme.defaultTheme] hover uses `bgColorContainerHover`. Other
/// filled themes mix the theme color with white on hover.
class TButton extends StatelessWidget {
  const TButton({
    super.key,
    required this.child,
    this.onPressed,
    this.href,
    this.theme = TButtonTheme.defaultTheme,
    this.variant = TButtonVariant.base,
    this.ghost = false,
    this.shape = TButtonShape.rectangle,
    this.size = TComponentSize.medium,
    this.loading = false,
    this.block = false,
    this.icon,
    this.suffix,
  });

  /// Button content, centered inside the button.
  final Widget child;

  /// Click callback. `null` disables the button.
  final VoidCallback? onPressed;

  /// Optional link URL for semantics. Does not open a browser by itself.
  final String? href;

  /// Color theme. Defaults to [TButtonTheme.defaultTheme].
  final TButtonTheme theme;

  /// Filled, outline, dashed, or text. Defaults to [TButtonVariant.base].
  final TButtonVariant variant;

  /// Transparent background with theme-colored content.
  ///
  /// [TButtonVariant.outline] and [TButtonVariant.dashed] still draw a
  /// theme-colored border. Defaults to false.
  final bool ghost;

  /// Rectangle, square, round, or circle. Defaults to [TButtonShape.rectangle].
  final TButtonShape shape;

  /// Height token. small is 24, medium is 32, large is 40.
  final TComponentSize size;

  /// Uses the disabled color and ignores clicks. Defaults to false.
  final bool loading;

  /// Stretches to the parent's width. Ignored for square / circle.
  ///
  /// Defaults to false.
  final bool block;

  /// Optional leading icon. Colored by the button foreground.
  final Widget? icon;

  /// Optional trailing icon. Colored by the button foreground.
  final Widget? suffix;

  bool get _enabled => onPressed != null && !loading;

  bool get _filled => variant == TButtonVariant.base && !ghost;

  bool get _fixedWidth =>
      shape == TButtonShape.square || shape == TButtonShape.circle;

  double get _extent {
    return switch (size) {
      TComponentSize.small => 24,
      TComponentSize.medium => 32,
      TComponentSize.large => 40,
    };
  }

  double get _fontSize => size == TComponentSize.small ? 12 : 14;

  EdgeInsets get _padding {
    if (_fixedWidth) return EdgeInsets.zero;
    final horizontal = switch (size) {
      TComponentSize.small => 12.0,
      TComponentSize.medium => 16.0,
      TComponentSize.large => 20.0,
    };
    return EdgeInsets.symmetric(horizontal: horizontal);
  }

  double _cornerRadius(TDesignTokenSet tokens) {
    if (shape == TButtonShape.round || shape == TButtonShape.circle) {
      return _extent / 2;
    }
    return tTokenRadius(tokens);
  }

  /// Theme color used for text and for outline / dashed strokes.
  Color _themeColor(TDesignTokenSet tokens) {
    return switch (theme) {
      TButtonTheme.defaultTheme => tTokenColorOf(tokens, 'textColorPrimary'),
      TButtonTheme.primary => tTokenColorOf(tokens, 'brandColor7'),
      TButtonTheme.danger => tTokenColorOf(tokens, 'errorColor6'),
      TButtonTheme.warning => tTokenColorOf(tokens, 'warningColor5'),
      TButtonTheme.success => tTokenColorOf(tokens, 'successColor5'),
    };
  }

  Color _fillBase(TDesignTokenSet tokens) {
    if (theme == TButtonTheme.defaultTheme) {
      return tTokenColorOf(tokens, 'bgColorContainer');
    }
    return _themeColor(tokens);
  }

  /// Filled primary, danger, warning, and success hover mixes 8% white.
  /// Pressed mixes 12% black. Disabled and loading keep 40% alpha.
  /// [TButtonTheme.defaultTheme] hover uses `bgColorContainerHover`.
  Color _fillColor(TDesignTokenSet tokens, TComponentState state) {
    final base = _fillBase(tokens);
    return switch (state) {
      TComponentState.disabled ||
      TComponentState.loading => base.withValues(alpha: 0.4),
      TComponentState.pressed => Color.lerp(
        base,
        const Color(0xFF000000),
        0.12,
      )!,
      TComponentState.hovered =>
        theme == TButtonTheme.defaultTheme
            ? tTokenColorOf(tokens, 'bgColorContainerHover')
            : Color.lerp(base, const Color(0xFFFFFFFF), 0.08)!,
      TComponentState.focused ||
      TComponentState.selected ||
      TComponentState.normal => base,
    };
  }

  Color _contentColor(TDesignTokenSet tokens, TComponentState state) {
    final color = _themeColor(tokens);
    if (state == TComponentState.disabled || state == TComponentState.loading) {
      return color.withValues(alpha: 0.4);
    }
    return color;
  }

  Color _background(TDesignTokenSet tokens, TComponentState state) {
    if (!_filled) return const Color(0x00000000);
    return _fillColor(tokens, state);
  }

  Color _foreground(TDesignTokenSet tokens, TComponentState state) {
    if (_filled && theme != TButtonTheme.defaultTheme) {
      return tTokenColorOf(tokens, 'textColorAnti');
    }
    return _contentColor(tokens, state);
  }

  BoxBorder? _border(TDesignTokenSet tokens, TComponentState state) {
    if (variant == TButtonVariant.outline) {
      return Border.all(color: _contentColor(tokens, state), width: 1);
    }
    if (_filled && state == TComponentState.focused) {
      return Border.all(color: tTokenColorOf(tokens, 'brandColor7'), width: 2);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = TDesignTokenScope.of(context);
    final link = href;
    Widget button = TInteractiveRegion(
      enabled: _enabled,
      onActivate: onPressed,
      builder: (context, state) {
        final effective = loading ? TComponentState.loading : state;
        final radius = _cornerRadius(tokens);
        final foreground = _foreground(tokens, effective);
        final label = DefaultTextStyle(
          style: TextStyle(color: foreground, fontSize: _fontSize),
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.clip,
          child: IconTheme(
            data: IconThemeData(color: foreground, size: _fontSize + 2),
            child: _content(),
          ),
        );
        Widget body = DecoratedBox(
          decoration: BoxDecoration(
            color: _background(tokens, effective),
            borderRadius: BorderRadius.circular(radius),
            border: _border(tokens, effective),
          ),
          child: Padding(
            padding: _padding,
            child: Align(
              alignment: Alignment.center,
              widthFactor: _fixedWidth || block ? null : 1,
              child: label,
            ),
          ),
        );
        body = SizedBox(
          width: _fixedWidth
              ? _extent
              : block
              ? double.infinity
              : null,
          height: _extent,
          child: body,
        );
        if (variant == TButtonVariant.dashed) {
          body = CustomPaint(
            foregroundPainter: TButtonDashedBorderPainter(
              color: _contentColor(tokens, effective),
              radius: radius,
            ),
            child: body,
          );
        }
        return body;
      },
    );
    if (link == null || link.isEmpty) return button;
    return Semantics(
      link: true,
      button: true,
      enabled: _enabled,
      tooltip: link,
      child: button,
    );
  }

  Widget _content() {
    if (icon == null && suffix == null) return child;
    return Row(
      mainAxisSize: block ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[icon!, const SizedBox(width: 4)],
        Flexible(child: child),
        if (suffix != null) ...[const SizedBox(width: 4), suffix!],
      ],
    );
  }
}

/// 1px dashed border drawn for [TButtonVariant.dashed].
@visibleForTesting
class TButtonDashedBorderPainter extends CustomPainter {
  const TButtonDashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  static const strokeWidth = 1.0;
  static const dashLength = 4.0;
  static const gapLength = 3.0;

  /// Continuous rounded-rect outline before dashes are removed.
  Path outlinePath(Size size) {
    if (size.width <= strokeWidth || size.height <= strokeWidth) {
      return Path();
    }
    const inset = strokeWidth / 2;
    final rect = Rect.fromLTWH(
      inset,
      inset,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );
    final corner = (radius - inset).clamp(0.0, double.infinity);
    return Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(corner)));
  }

  /// Dashed outline. Its length is shorter than [outlinePath] by the gaps.
  Path dashedPath(Size size) {
    final dest = Path();
    for (final metric in outlinePath(size).computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = distance + dashLength < metric.length
            ? distance + dashLength
            : metric.length;
        dest.addPath(metric.extractPath(distance, end), Offset.zero);
        distance = end + gapLength;
      }
    }
    return dest;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = dashedPath(size);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(TButtonDashedBorderPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}
