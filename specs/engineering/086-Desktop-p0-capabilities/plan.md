# Desktop P0 能力补全 — 实施方案

契约见 [spec.md](./spec.md)。本文件只记录实现顺序和验证，不另写一套 API。

## 实现组织

```
tools/token_codegen/          # CSS → css2token → tdesign_tokens.g.dart
packages/tdesign_flutter_multi_core/lib/src/token/tdesign_tokens.g.dart
packages/tdesign_flutter_multi_desktop/lib/src/
  basic/t_button.dart
  form/t_input.dart
  form/t_select.dart
  form/t_form.dart
  navigation/t_pagination.dart
  navigation/t_tabs.dart
  navigation/t_menu.dart
  data/t_table.dart
examples/desktop_gallery/     # 每个能力补 Vue 同名示例区块
```

状态流：状态色 Token → Button 视觉模型 → Input → Select 与 Form → Pagination / Tabs / Menu 与 Table。Select 的筛选弹层先于 Table 筛选。

## 影响范围

| 范围 | 实际文件或模块 | 要同步的内容 |
| --- | --- | --- |
| Token | `tools/token_codegen`，`tdesign_tokens.g.dart` | 状态色阶与已有 brand / bg / text / radius。生成文件不手改 |
| Button | `t_button.dart`，Gallery、Pagination、InputNumber、Dialog 的调用点 | theme × variant、ghost、shape；删除 primary / secondary |
| 表单 | `t_input.dart`、`t_select.dart`、`t_form.dart`，Gallery Form 页 | 清空、密码、状态、字数、多选、规则校验 |
| 导航 | `t_pagination.dart`、`t_tabs.dart`、`t_menu.dart` | 页码、跳转、每页条数；placement 与 size；图标、暗色、顶栏 |
| 表格 | `t_table.dart` | 筛选、左右固定列、树形展开 |
| 不改 | `tdesign-component` | Mobile `TButtonVariant` 与迁移消费测试保持原样 |

## 依赖与实施顺序

1. 冻结本 Spec。
2. 扩展 token codegen，生成 light / dark 状态色。组件只读 `TDesignTokens.*.colors`。
3. Button 拆 theme × variant，改完仓库内调用点。
4. Input，然后 Select 与 Form。Form 通过 `TFormFieldScope` 取 Input / Select 的值。
5. Pagination、Tabs、Menu 可与 Form 并行。Menu 暗色在画底色前，先把 `grayColor13` 补进同一 codegen。
6. Table 筛选、固定列、树。筛选面板复用 Overlay，放在 Select 弹层之后。
7. 每个能力补一条 widget 测试和 Gallery 区块。

第 1、2 步是本目录的当前交付。第 3 步起不在同一次改动里实现。

## 验证安排

Token 与 Core（第 2 步）：

```bash
cd tools/token_codegen && dart test
cd packages/tdesign_flutter_multi_core && flutter analyze --fatal-infos
```

使用 Flutter 3.32.0（Dart 3.8）。本阶段不跑 `examples/desktop_gallery`，也不跑 desktop 包的全量测试。

后续组件步骤：

```bash
cd packages/tdesign_flutter_multi_desktop && flutter analyze --fatal-infos && flutter test
cd examples/desktop_gallery && flutter analyze --fatal-infos && flutter test
```

每个能力一条 widget 测试。不做 Vue 截图像素对比。Core 的 Token 文件若被手改，`token_codegen` 里「生成结果与仓库文件一致」的测试会失败。
