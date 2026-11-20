import 'package:flutter/widgets.dart';

import 'gallery/shell.dart';

void main() {
  runApp(const DesktopGalleryApp());
}

class DesktopGalleryApp extends StatelessWidget {
  const DesktopGalleryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return WidgetsApp(
      color: const Color(0xFF0052D9),
      title: 'TDesign Flutter Desktop Gallery',
      home: const GalleryShell(),
      pageRouteBuilder: <T>(RouteSettings settings, WidgetBuilder builder) {
        return PageRouteBuilder<T>(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
        );
      },
    );
  }
}
