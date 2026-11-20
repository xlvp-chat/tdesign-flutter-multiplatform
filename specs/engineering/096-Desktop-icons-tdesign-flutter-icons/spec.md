# Desktop 接入 tdesign_flutter_icons

挂在 [085 Desktop 架构基线](../085-Desktop-architecture-baseline/spec.md)。实现落在 `packages/tdesign_flutter_multi_desktop` 与 `examples/desktop_gallery`。不修改 Mobile 组件；本轮不把 icons 依赖下沉到 Core。

## 背景与目标

Desktop 组件与 Gallery 曾用 Unicode `Text` 充当 close / caret / add 等 affordance。Web 与桌面字体回退不同，导致箭头、加号等尺寸与基线不稳定。目标是统一依赖 `tdesign_flutter_icons`，用 `Icon(TIcons.…)` 替换内置 affordance，并让 Gallery Demo 同步使用同一套图标。

## 范围与非目标

涉及：

- `tdesign_flutter_multi_desktop` 依赖 `tdesign_flutter_icons ^0.0.7`，barrel 导出 `TIcons`。
- 组件内 Unicode affordance → `Icon(TIcons.…)`；`DateCalendarNavButton` 由字符串标签改为 `Widget child`。
- Gallery Demo 图标改为 `TIcons`；补齐 Upload image 主题添加格 Demo。
- 对应 widget 测试与 `analyze --fatal-infos`。

不涉及：

- 移植 Mobile `TIcon` / `TIconStyleScope`。
- Core 包承接 Icon 依赖。
- Vue 参考锁 / 像素级 Visual Diff。
- Web 目视专项（可另记验收，不阻塞本契约落地）。

## 最终方案与行为契约

| 契约 | 要求 |
| --- | --- |
| 依赖 | desktop `pubspec` 声明 `tdesign_flutter_icons: ^0.0.7`（与 Mobile 对齐）。 |
| 导出 | `tdesign_flutter_multi_desktop.dart` re-export `TIcons`；不强制 re-export 其它 icons 符号。 |
| 渲染 | 内置 affordance 使用 `Icon(TIcons.xxx)`；优先继承周围 `IconTheme`；必要时显式 `size`/`color` 对齐原字号与 Token。 |
| 映射 | `×`→`close`；`+`/`-`→`add`/`minus`；下拉/折叠 caret→`caret_*_small`；层级/导航 chevron→`chevron_*`（含 double）；勾选→`check`/`minus`；行拖拽柄→`move`；分页省略号 `…` 仍为文案 `Text`。 |
| 日历导航 | `DateCalendarNavButton` 接收 `child`（`Icon`），不再传 Unicode 字符串。 |
| Upload image | 图片主题以 add 格为触发入口（展示 `TIcons.add`），不再依赖纯文案「选择文件」按钮作为唯一入口。 |
| Gallery | Demo 使用 `Icon(TIcons.…)`；含 image 主题 Upload 区。 |

## 兼容性

Desktop 仍为 `0.x`。`DateCalendarNavButton` 为库内共享控件；若外部误用旧 `label: String` 需改为 `child`。公开组件构造签名不因本次替换而 breaking（icon 仍为调用方 `Widget` 插槽）。

## 验证要求

- `packages/tdesign_flutter_multi_desktop`：`flutter analyze --fatal-infos` + `flutter test`。
- `examples/desktop_gallery`：`flutter analyze --fatal-infos` + `flutter test`。
- macOS 目视：Button / Select / InputNumber / Tree / Upload / Menu 图标尺寸与对齐可接受（证据见 `evidence/`）。
