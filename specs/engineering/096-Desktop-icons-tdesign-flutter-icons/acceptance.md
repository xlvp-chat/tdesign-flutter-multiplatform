# Desktop icons — 验收

## 环境

- Flutter：FVM `3.32.8`
- 包：`tdesign_flutter_multi_desktop` + `examples/desktop_gallery`
- 图标：`tdesign_flutter_icons ^0.0.7`

## 自动化

| 项 | 结论 |
| --- | --- |
| desktop `analyze --fatal-infos` | Pass |
| desktop `flutter test` | Pass（约 108） |
| gallery `analyze --fatal-infos` | Pass |
| gallery `flutter test` | Pass（约 5） |

## macOS 目视

| 页面 | 结论 | 说明 |
| --- | --- | --- |
| Button | Pass | `add` / `chevron_right` 与文案对齐 |
| Select | Pass | caret / close；后续将 caret 提升到 IconTheme 14 |
| InputNumber | Pass | `+/-` 居中 |
| Tree | Pass | 展开 caret 对齐 |
| Upload file | Pass | 行内 close |
| Upload image add | 逻辑已补 | Gallery 已加「图片卡片上传」；待补截图 |
| Menu | Pass | `home` / `view_list` / `user` / `circle` |

证据目录：`evidence/`（若存在 `macos-*.webp` 则作为附件；缺失时以本表文字结论为准）。

## 未覆盖

- Web 目视未做。
- Tree caret 仍约 12（与原 `fontSize: 12` 一致），未强行放大。
