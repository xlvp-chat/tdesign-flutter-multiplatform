# tdesign_flutter_multi_desktop

TDesign Desktop / Web components for Windows, macOS, and Flutter Web.

**0.1.0** (tag `desktop-v0.1.0`). Path dependency only (`publish_to: none`).
Depends on `tdesign_flutter_multi_core` 0.1.0 and does **not** re-export it.

0.1.0 includes the P0 set (Button, Input, Select, Form, Date/Time pickers,
Cascader, Tree, TreeSelect, Upload, Table, Menu, Tabs, Dialog, and related
widgets). It does not include tree lazy-load, Upload HTTP/drag-and-drop, or
pixel visual diff. See `CHANGELOG.md`.

## Try it

```bash
cd examples/desktop_gallery
flutter run -d windows   # or macos / chrome
```

## Import

```dart
import 'package:tdesign_flutter_multi_core/tdesign_flutter_multi_core.dart';
import 'package:tdesign_flutter_multi_desktop/tdesign_flutter_multi_desktop.dart';
```
