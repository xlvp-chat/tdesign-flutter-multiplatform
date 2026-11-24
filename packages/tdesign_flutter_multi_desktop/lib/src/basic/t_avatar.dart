import 'package:flutter/widgets.dart';
import 'package:tdesign_flutter_icons/tdesign_flutter_icons.dart';

import '../token/t_token_color.dart';
import 't_icon.dart';

/// Avatar edge for [TAvatarSize]. Matches Vue Next small / medium / large.
enum TAvatarSize {
  small(24),
  medium(32),
  large(40);

  const TAvatarSize(this.edge);
  final double edge;
}

/// Avatar outline. [circle] is the Vue default. [round] uses a small radius.
enum TAvatarShape { circle, round }

/// Desktop avatar. Shows [image], otherwise [icon], otherwise [child] text.
class TAvatar extends StatelessWidget {
  const TAvatar({
    super.key,
    this.child,
    this.icon,
    this.image,
    this.size = TAvatarSize.medium,
    this.shape = TAvatarShape.circle,
  });

  final Widget? child;
  final Widget? icon;
  final ImageProvider? image;
  final TAvatarSize size;
  final TAvatarShape shape;

  @override
  Widget build(BuildContext context) {
    final edge = size.edge;
    final bg = tTokenColor(context, 'brandColor1');
    final fg = tTokenColor(context, 'brandColor7');
    final radius = shape == TAvatarShape.circle ? edge / 2 : 4.0;
    Widget content;
    if (image != null) {
      content = Image(image: image!, fit: BoxFit.cover, width: edge, height: edge);
    } else if (icon != null) {
      content = IconTheme(
        data: IconThemeData(color: fg, size: edge * 0.55),
        child: icon!,
      );
    } else {
      content = DefaultTextStyle(
        style: TextStyle(color: fg, fontSize: edge * 0.4),
        child: child ?? const SizedBox.shrink(),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: ColoredBox(
        color: bg,
        child: SizedBox(
          width: edge,
          height: edge,
          child: Center(child: content),
        ),
      ),
    );
  }
}

/// Overlapping avatars. Items past [max] collapse into a `+N` avatar.
class TAvatarGroup extends StatelessWidget {
  const TAvatarGroup({
    super.key,
    required this.children,
    this.max,
    this.size = TAvatarSize.medium,
  });

  final List<Widget> children;
  final int? max;
  final TAvatarSize size;

  @override
  Widget build(BuildContext context) {
    final limit = max;
    final visible = limit == null || children.length <= limit
        ? children
        : children.take(limit).toList();
    final hidden = children.length - visible.length;
    final edge = size.edge;
    final step = edge * 0.75;
    final count = visible.length + (hidden > 0 ? 1 : 0);
    return SizedBox(
      width: edge + (count - 1) * step,
      height: edge,
      child: Stack(
        children: [
          for (var i = 0; i < visible.length; i++)
            Positioned(
              left: i * step,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: tTokenColor(context, 'bgColorContainer'),
                    width: 2,
                  ),
                ),
                child: visible[i],
              ),
            ),
          if (hidden > 0)
            Positioned(
              left: visible.length * step,
              child: TAvatar(
                size: size,
                child: Text('+$hidden'),
              ),
            ),
        ],
      ),
    );
  }
}

/// Empty placeholder. [type] picks the Vue status icon.
enum TEmptyType { empty, success, fail, networkError, maintenance }

class TEmpty extends StatelessWidget {
  const TEmpty({
    super.key,
    this.title,
    this.description,
    this.type = TEmptyType.empty,
    this.action,
  });

  final String? title;
  final String? description;
  final TEmptyType type;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final muted = tTokenColor(context, 'textColorSecondary');
    final titleColor = tTokenColor(context, 'textColorPrimary');
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TIcon(_icon, size: 48, color: _color(context)),
        if (title != null) ...[
          const SizedBox(height: 8),
          Text(title!, style: TextStyle(fontSize: 14, color: titleColor)),
        ],
        if (description != null) ...[
          const SizedBox(height: 4),
          Text(description!, style: TextStyle(fontSize: 12, color: muted)),
        ],
        if (action != null) ...[const SizedBox(height: 12), action!],
      ],
    );
  }

  IconData get _icon {
    switch (type) {
      case TEmptyType.empty:
        return TIcons.image;
      case TEmptyType.success:
        return TIcons.check_circle_filled;
      case TEmptyType.fail:
        return TIcons.error_circle_filled;
      case TEmptyType.networkError:
        return TIcons.info_circle_filled;
      case TEmptyType.maintenance:
        return TIcons.info_circle;
    }
  }

  Color _color(BuildContext context) {
    switch (type) {
      case TEmptyType.success:
        return tTokenColor(context, 'successColor5');
      case TEmptyType.fail:
        return tTokenColor(context, 'errorColor');
      case TEmptyType.networkError:
      case TEmptyType.maintenance:
        return tTokenColor(context, 'warningColor5');
      case TEmptyType.empty:
        return tTokenColor(context, 'textColorPlaceholder');
    }
  }
}
