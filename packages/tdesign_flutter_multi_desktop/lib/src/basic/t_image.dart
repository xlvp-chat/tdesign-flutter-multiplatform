import 'package:flutter/widgets.dart';
import 'package:tdesign_flutter_icons/tdesign_flutter_icons.dart';

import '../token/t_token_color.dart';
import 't_icon.dart';

/// Image with a Vue-style error placeholder when [image] and [src] are absent
/// or the network image fails.
class TImage extends StatelessWidget {
  const TImage({
    super.key,
    this.image,
    this.src,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.alt,
  });

  final ImageProvider? image;
  final String? src;
  final double? width;
  final double? height;
  final BoxFit fit;
  final String? alt;

  ImageProvider? get _provider {
    if (image != null) return image;
    final source = src;
    if (source == null || source.isEmpty) return null;
    return NetworkImage(source);
  }

  @override
  Widget build(BuildContext context) {
    final provider = _provider;
    return SizedBox(
      width: width,
      height: height,
      child: provider == null
          ? _fallback(context)
          : Image(
              image: provider,
              fit: fit,
              errorBuilder: (context, error, stackTrace) => _fallback(context),
            ),
    );
  }

  Widget _fallback(BuildContext context) {
    final bg = tTokenColor(context, 'bgColorComponentDisabled');
    final fg = tTokenColor(context, 'textColorPlaceholder');
    return ColoredBox(
      color: bg,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TIcon(TIcons.image_error, color: fg, size: 24),
            if (alt != null)
              Text(alt!, style: TextStyle(fontSize: 12, color: fg)),
          ],
        ),
      ),
    );
  }
}
