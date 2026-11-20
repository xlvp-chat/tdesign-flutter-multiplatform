import 'package:flutter/widgets.dart';
import 'package:tdesign_flutter_multi_desktop/tdesign_flutter_multi_desktop.dart';

import 'catalog.dart';

class GalleryShell extends StatefulWidget {
  const GalleryShell({super.key});

  @override
  State<GalleryShell> createState() => _GalleryShellState();
}

class _GalleryShellState extends State<GalleryShell> {
  var _id = 'button';

  GalleryComponent get _current {
    return galleryComponents.firstWhere((component) => component.id == _id);
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF5F5F5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TMenu(
            width: 248,
            value: _id,
            onChanged: (value) => setState(() => _id = value),
            items: [
              for (final category in galleryCategories)
                TMenuItem(
                  value: 'group:${category.title}',
                  label: Text(category.title),
                  children: [
                    for (final component in category.components)
                      TMenuItem(
                        value: component.id,
                        label: Text(component.title),
                      ),
                  ],
                ),
            ],
          ),
          Expanded(child: _current.create()),
        ],
      ),
    );
  }
}
