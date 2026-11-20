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

[English](./README.md) | 简体中文

**TDesign Flutter Multiplatform** 在既有移动端组件库基础上扩展了桌面端 / Web 能力。仓库保留 Mobile 包（`tdesign_flutter`），并新增共享基础层、Desktop 组件与自适应入口，可在同一 monorepo 中面向 iOS、Android、Web、Windows、macOS 开发。

> Mobile 文档与已发布的 `tdesign_flutter` 仍与上游 [Tencent/tdesign-flutter](https://github.com/Tencent/tdesign-flutter) 对齐。Desktop 三个包的首个稳定版本是 **0.1.0**，对应 git tag [`desktop-v0.1.0`](https://github.com/xlvp-chat/tdesign-flutter-multiplatform/releases/tag/desktop-v0.1.0)。它们仍用 path 依赖（`publish_to: none`），不发布到 pub.dev。

## 🎉 特性

- 遵循 TDesign 设计规范的移动端组件（`tdesign_flutter`）
- 面向 Windows / macOS / Flutter Web 的桌面端组件（`tdesign_flutter_multi_desktop`）
- 共享 Token / Overlay / Interaction 基础层（`tdesign_flutter_multi_core`）
- 按窗口尺寸与输入能力选择 Mobile / Desktop 形态的自适应入口（`tdesign_flutter_multi_adaptive`）
- 主题定制、图标库与 TDesign 色板（`TColors`）

## 📦 包结构

| 包名 | 路径 | 职责 |
| ---- | ---- | ---- |
| `tdesign_flutter` | [`tdesign-component/`](./tdesign-component) | 移动端组件（iOS / Android / Web） |
| `tdesign_flutter_multi_core` | [`packages/tdesign_flutter_multi_core/`](./packages/tdesign_flutter_multi_core) | 共享 Token、Overlay、Interaction |
| `tdesign_flutter_multi_desktop` | [`packages/tdesign_flutter_multi_desktop/`](./packages/tdesign_flutter_multi_desktop) | 桌面端 / Web 组件 |
| `tdesign_flutter_multi_adaptive` | [`packages/tdesign_flutter_multi_adaptive/`](./packages/tdesign_flutter_multi_adaptive) | 自适应入口（`TDesignApp`） |

Desktop 当前覆盖基础、表单、反馈、导航与数据类组件，例如 Button、Input、Select、Cascader、TreeSelect、Date/Time 选择器、Upload、Table、Tree、Menu、Tabs、Dialog 等。完整导出见 [`tdesign_flutter_multi_desktop.dart`](./packages/tdesign_flutter_multi_desktop/lib/tdesign_flutter_multi_desktop.dart)。

Desktop 工程 Spec 见 [`specs/engineering/085`–`095`](./specs/engineering/)。

## 📱 预览

### 移动端

**Android**：扫描二维码下载预览应用

<img width="200" src="https://raw.githubusercontent.com/Tencent/tdesign-flutter/develop/tdesign-site/site/public/assets/qrcode/t_apk_qrcode.png" />

下载链接：[tdesign-flutter-example.apk](https://tdesign.gtimg.com/flutter/tdesign_flutter_example.apk)

**iOS**：运行移动端示例

```bash
cd tdesign-component/example
flutter run
```

### 桌面端

运行 Desktop Gallery（Windows / macOS / Web）：

```bash
cd examples/desktop_gallery
flutter run -d windows   # 或 macos / chrome
```

## 🚀 快速开始

要求 Flutter ≥ 3.32.0、Dart ≥ 3.8.0。

### 移动端

从 0.2.7 升级时，请先阅读 [1.0 迁移指南](./tdesign-site/site/docs/migration-0.2.7-to-1.0.md)。

在 `pubspec.yaml` 中添加 `tdesign_flutter: ^1.1.0`，运行 `flutter pub get`。完整接入步骤见[快速开始](./tdesign-site/site/docs/getting-started.md)。

```dart
import 'package:tdesign_flutter/tdesign_flutter.dart';

const TButton(child: Text('按钮'))
```

### 桌面端（path 依赖）

Desktop 相关包尚未发布到 pub.dev，请使用 path 依赖：

```yaml
dependencies:
  tdesign_flutter_multi_core:
    path: packages/tdesign_flutter_multi_core
  tdesign_flutter_multi_desktop:
    path: packages/tdesign_flutter_multi_desktop
  # 可选：自适应壳
  tdesign_flutter_multi_adaptive:
    path: packages/tdesign_flutter_multi_adaptive
```

```dart
import 'package:tdesign_flutter_multi_core/tdesign_flutter_multi_core.dart';
import 'package:tdesign_flutter_multi_desktop/tdesign_flutter_multi_desktop.dart';

const TButton(child: Text('按钮'))
```

`tdesign_flutter_multi_desktop` **不会**再导出 Core。需要 Token / Overlay / Interaction 时请单独 import Core。同一应用需按窗口与指针在 Mobile / Desktop 形态间切换时，优先使用 Adaptive 的 `TDesignApp`。

## 📚 文档

- [快速开始](./tdesign-site/site/docs/getting-started.md)
- [自定义主题](./tdesign-site/site/docs/custom-theme.md)
- [深色模式](./tdesign-site/site/docs/custom-theme.md#明暗模式)
- [国际化](./tdesign-site/site/docs/internationalization.md)
- [常见问题](./tdesign-site/site/docs/faq.md)
- [在线组件文档](https://tdesign.tencent.com/flutter/overview)
- [贡献指南](./CONTRIBUTING.md)
- [Desktop 架构基线](./specs/engineering/085-Desktop-architecture-baseline/spec.md)

## 🔗 更多示例

- 移动端：[`tdesign-component/example/lib/page/`](./tdesign-component/example/lib/page)
- Desktop Gallery：[`examples/desktop_gallery/`](./examples/desktop_gallery)

## 🌐 TDesign 组件库

TDesign 还提供其他平台和框架的组件库：

| 平台 | 仓库 |
|------|------|
| Vue 2.x | [tdesign-vue](https://github.com/Tencent/tdesign-vue) |
| Vue 3.x | [tdesign-vue-next](https://github.com/Tencent/tdesign-vue-next) |
| React | [tdesign-react](https://github.com/Tencent/tdesign-react) |
| Vue 3.x 移动端 | [tdesign-mobile-vue](https://github.com/Tencent/tdesign-mobile-vue) |
| React 移动端 | [tdesign-mobile-react](https://github.com/Tencent/tdesign-mobile-react) |
| 微信小程序 | [tdesign-miniprogram](https://github.com/Tencent/tdesign-miniprogram) |
| Flutter（上游） | [tdesign-flutter](https://github.com/Tencent/tdesign-flutter) |

## 🤝 参与贡献

欢迎贡献代码！请在提交 [Pull Request](https://github.com/xlvp-chat/tdesign-flutter-multiplatform/pulls) 前阅读[贡献指南](./CONTRIBUTING.md)。

## 💬 交流反馈

请在本仓库创建 [GitHub Issues](https://github.com/xlvp-chat/tdesign-flutter-multiplatform/issues)。与上游 Mobile 相关的讨论也可前往 [Tencent/tdesign-flutter Issues](https://github.com/Tencent/tdesign-flutter/issues)。

## 🙏 致谢

TDesign Flutter 依赖以下组件库，感谢作者的开源贡献：

- [easy_refresh](https://pub.dev/packages/easy_refresh)
- [flutter_slidable](https://pub.dev/packages/flutter_slidable)
- [image_picker](https://pub.dev/packages/image_picker)

## 📄 开源协议

TDesign Flutter 遵循 [MIT 协议](./LICENSE)。
