<p align="center">
  <a href="https://tdesign.tencent.com/" target="_blank">
    <img alt="TDesign Logo" width="200" src="https://tdesign.gtimg.com/site/TDesign.png" />
  </a>
</p>

<p align="center">
  <a href="https://github.com/xlvp-chat/tdesign-flutter-multiplatform/blob/develop/LICENSE">
    <img src="https://img.shields.io/github/license/xlvp-chat/tdesign-flutter-multiplatform" alt="License">
  </a>
  <a href="https://pub.dev/packages/tdesign_flutter">
    <img src="https://img.shields.io/pub/v/tdesign_flutter" alt="Version">
  </a>
  <a href="https://pub.dev/packages/tdesign_flutter/score">
    <img src="https://img.shields.io/pub/dm/tdesign_flutter" alt="Downloads">
  </a>
</p>

English | [简体中文](./README_zh_CN.md)

**TDesign Flutter Multiplatform** extends the TDesign Flutter component library with a Desktop/Web layer. It keeps the existing Mobile package (`tdesign_flutter`) and adds shared foundation, Desktop components, and an adaptive entry so you can target iOS, Android, Web, Windows, and macOS from one monorepo.

> Mobile docs and the published `tdesign_flutter` package remain aligned with the upstream [Tencent/tdesign-flutter](https://github.com/Tencent/tdesign-flutter) project. Desktop packages are **0.1.0** at git tag [`desktop-v0.1.0`](https://github.com/xlvp-chat/tdesign-flutter-multiplatform/releases/tag/desktop-v0.1.0). They stay path dependencies (`publish_to: none`) and are not published to pub.dev.

## 🎉 Features

- Mobile UI components that follow TDesign design specifications (`tdesign_flutter`)
- Desktop/Web components for Windows, macOS, and Flutter Web (`tdesign_flutter_multi_desktop`)
- Shared Token / Overlay / Interaction foundation (`tdesign_flutter_multi_core`)
- Adaptive shell that picks Mobile or Desktop morphs from window size and input capability (`tdesign_flutter_multi_adaptive`)
- Theme customization, Icon library, and TDesign color groups (`TColors`)

## 📦 Packages

| Package | Path | Role |
| ------- | ---- | ---- |
| `tdesign_flutter` | [`tdesign-component/`](./tdesign-component) | Mobile components (iOS / Android / Web) |
| `tdesign_flutter_multi_core` | [`packages/tdesign_flutter_multi_core/`](./packages/tdesign_flutter_multi_core) | Shared tokens, overlay, interaction |
| `tdesign_flutter_multi_desktop` | [`packages/tdesign_flutter_multi_desktop/`](./packages/tdesign_flutter_multi_desktop) | Desktop / Web components |
| `tdesign_flutter_multi_adaptive` | [`packages/tdesign_flutter_multi_adaptive/`](./packages/tdesign_flutter_multi_adaptive) | Adaptive entry (`TDesignApp`) |

Desktop coverage currently includes basic, form, feedback, navigation, and data components such as Button, Input, Select, Cascader, TreeSelect, Date/Time Pickers, Upload, Table, Tree, Menu, Tabs, and Dialog. See the package barrel: [`tdesign_flutter_multi_desktop.dart`](./packages/tdesign_flutter_multi_desktop/lib/tdesign_flutter_multi_desktop.dart).

Engineering specs for the Desktop track live under [`specs/engineering/085`–`095`](./specs/engineering/).

## 📱 Preview

### Mobile

**Android**: Scan the QR code to download the preview app

<img width="200" src="https://raw.githubusercontent.com/Tencent/tdesign-flutter/develop/tdesign-site/site/public/assets/qrcode/t_apk_qrcode.png" />

Download link: [tdesign-flutter-example.apk](https://tdesign.gtimg.com/flutter/tdesign_flutter_example.apk)

**iOS**: Run the Mobile example

```bash
cd tdesign-component/example
flutter run
```

### Desktop

Run the Desktop Gallery (Windows / macOS / Web):

```bash
cd examples/desktop_gallery
flutter run -d windows   # or macos / chrome
```

## 🚀 Quick Start

Requires Flutter ≥ 3.32.0 and Dart ≥ 3.8.0.

### Mobile

Upgrading from 0.2.7? Read the [1.0 migration guide (Chinese)](./tdesign-site/site/docs/migration-0.2.7-to-1.0.md) before changing the dependency.

Add `tdesign_flutter: ^1.1.0` to `pubspec.yaml` and run `flutter pub get`. See [Getting started](./tdesign-site/site/docs/getting-started.md) for the complete setup.

```dart
import 'package:tdesign_flutter/tdesign_flutter.dart';

const TButton(child: Text('Button'))
```

### Desktop (path dependency)

Desktop packages are not published to pub.dev yet. Depend on them via path:

```yaml
dependencies:
  tdesign_flutter_multi_core:
    path: packages/tdesign_flutter_multi_core
  tdesign_flutter_multi_desktop:
    path: packages/tdesign_flutter_multi_desktop
  # optional adaptive shell
  tdesign_flutter_multi_adaptive:
    path: packages/tdesign_flutter_multi_adaptive
```

```dart
import 'package:tdesign_flutter_multi_core/tdesign_flutter_multi_core.dart';
import 'package:tdesign_flutter_multi_desktop/tdesign_flutter_multi_desktop.dart';

const TButton(child: Text('Button'))
```

`tdesign_flutter_multi_desktop` does **not** re-export Core. Import Core when you need tokens, overlay, or interaction primitives. Prefer `TDesignApp` from Adaptive when the same app should switch Mobile/Desktop morphs by window and pointer.

## 📚 Documentation

The detailed Mobile guides below are currently in Chinese.

- [Getting started](./tdesign-site/site/docs/getting-started.md)
- [Custom themes](./tdesign-site/site/docs/custom-theme.md)
- [Dark mode](./tdesign-site/site/docs/custom-theme.md#明暗模式)
- [Internationalization](./tdesign-site/site/docs/internationalization.md)
- [FAQ](./tdesign-site/site/docs/faq.md)
- [Component documentation](https://tdesign.tencent.com/flutter/overview)
- [Contributing](./CONTRIBUTING.md)
- [Desktop architecture baseline](./specs/engineering/085-Desktop-architecture-baseline/spec.md)

## 🔗 More Examples

- Mobile: [`tdesign-component/example/lib/page/`](./tdesign-component/example/lib/page)
- Desktop Gallery: [`examples/desktop_gallery/`](./examples/desktop_gallery)

## 🌐 TDesign Component Libraries

TDesign provides component libraries for other platforms and frameworks:

| Platform           | Repository                                                              |
| ------------------ | ----------------------------------------------------------------------- |
| Vue 2.x            | [tdesign-vue](https://github.com/Tencent/tdesign-vue)                   |
| Vue 3.x            | [tdesign-vue-next](https://github.com/Tencent/tdesign-vue-next)         |
| React              | [tdesign-react](https://github.com/Tencent/tdesign-react)               |
| Vue 3.x Mobile     | [tdesign-mobile-vue](https://github.com/Tencent/tdesign-mobile-vue)     |
| React Mobile       | [tdesign-mobile-react](https://github.com/Tencent/tdesign-mobile-react) |
| WeChat Miniprogram | [tdesign-miniprogram](https://github.com/Tencent/tdesign-miniprogram)   |
| Flutter (upstream) | [tdesign-flutter](https://github.com/Tencent/tdesign-flutter)           |

## 🤝 Contributing

Contributions are welcome! Please read the [contributing guidelines](./CONTRIBUTING.md) before submitting a [Pull Request](https://github.com/xlvp-chat/tdesign-flutter-multiplatform/pulls).

## 💬 Feedback

Create [GitHub Issues](https://github.com/xlvp-chat/tdesign-flutter-multiplatform/issues) in this repository. For upstream Mobile discussions you can also use [Tencent/tdesign-flutter Issues](https://github.com/Tencent/tdesign-flutter/issues).

## 🙏 Acknowledgements

TDesign Flutter depends on the following component libraries. We appreciate the authors for their open-source contributions:

- [easy_refresh](https://pub.dev/packages/easy_refresh)
- [flutter_slidable](https://pub.dev/packages/flutter_slidable)
- [image_picker](https://pub.dev/packages/image_picker)

## 📄 License

TDesign Flutter is licensed under the [MIT License](./LICENSE).
