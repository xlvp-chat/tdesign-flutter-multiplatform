# TDesign Flutter Desktop 架构基线 — 验收记录

## 候选与环境

| 项 | 值 |
| --- | --- |
| 候选 | architecture-baseline-v1（可执行实施基线） |
| 源方案 | TDesign_Flutter_Desktop_技术方案_V1.docx V1.0 / 2026-11-15 |
| 仓库 | tdesign-flutter monorepo |
| 日期 | 2026-11-15 |
| 工具链 | `C:\develop\devtool\flutter-3.32.0`（Flutter 3.32.0 / Dart 3.8.0） |

## Phase 0 PoC Go/No-Go

**结论：Go**

| Gate 条件 | 结论 | 证据 |
| --- | --- | --- |
| Token 自动生成 | **Pass** | `tools/token_codegen`：`dart test` 全绿 |
| Select Overlay / Focus / Keyboard | **Pass** | `tdesign_flutter_multi_desktop/test/t_select_interaction_test.dart` |
| Table typed API | **Pass** | `test/t_table_api_test.dart` |
| 三包 analyze | **Pass** | core / desktop / adaptive：`No issues found` |

## 架构与实施基线

| 标准 | 结论 | 证据 |
| --- | --- | --- |
| ADR-001～008 冻结 | **Pass** | [spec.md](./spec.md) |
| 包分层 core/desktop/adaptive | **Pass** | `packages/tdesign_flutter_*` |
| Foundation v0.1 | **Pass** | Overlay flip/shift + focus restore 测试；`FOUNDATION_API_v0.1.md` |
| MVP-P0 组件集 | **Pass** | Basic/Form/Popup/Nav/Table 见下表 |
| CRUD 验收页 | **Pass** | `examples/desktop_gallery`（Menu/Tabs/Breadcrumb + 列表筛选分页 Dialog） |
| Adaptive 契约 | **Pass** | `AdaptiveResolver` + `TDesignApp`/`AdaptiveScope` + 单测 |
| Desktop CI | **Pass** | `.github/workflows/desktop-packages.yml` |
| Mobile 隔离 | **Pass** | 未改 `tdesign-component` 组件实现 |

### MVP-P0 组件落地清单

Button, Link, Divider, Space, Tag, Badge, Input, Textarea, InputNumber, Checkbox, Radio, Switch, Form, Tooltip, Popover, Dialog, Dropdown, Select, Tabs, Menu, Pagination, Breadcrumb, Table.

## 命令记录（本机已执行，全绿）

```text
flutter=C:\develop\devtool\flutter-3.32.0\bin\flutter.bat

cd tools/token_codegen && dart test
cd packages/tdesign_flutter_multi_core && flutter analyze --fatal-infos && flutter test
cd packages/tdesign_flutter_multi_desktop && flutter analyze --fatal-infos && flutter test
cd packages/tdesign_flutter_multi_adaptive && flutter analyze --fatal-infos && flutter test
cd examples/desktop_gallery && flutter analyze --fatal-infos
```

## 后续（非本基线阻塞）

- Phase 3 复杂组件（DatePicker/Cascader/Tree…）按业务裁剪
- Vue Next 参考页已锁在 `examples/desktop_gallery/visual/vue_reference.lock.json`。像素级 Visual Diff 与多平台 CI matrix 扩展仍未做
- Token drift：已锁 tdesign-vue-next `0ea1919c6afc78c6b29808510a18820b437f5e0f` 的 web theme，见 `tools/token_codegen/common/web-theme.lock.json`
- Overlay 嵌套 stacking escape hatch 打磨
