# Desktop Phase 4 Hardening — 性能与 API 收敛

挂在 [085 Desktop 架构基线](../085-Desktop-architecture-baseline/spec.md) 的 Phase 4 Hardening 上。规格来源仍是 Vue Next / tdesign-common；实现留在 `packages/tdesign_flutter_desktop`（及必要的 `tdesign_flutter_core`）。ADR-002 / ADR-006 / Desktop `0.x` 继续有效。不修改 Mobile 组件。

## 背景与目标

Phase 0–3 已铺开 Desktop 组件与进阶模式。进入内部正式发布 / 1.0 候选前，需要把 **公开 API 习惯** 与 **列表类性能** 收敛到可维护、可验证的契约，避免 0.x 继续发散。

本 Spec 只覆盖 **性能** 与 **API 收敛**。Web A11y、Vue Next Visual Diff、Token CI drift、CNB stage 同步见 085 `tasks.md` 其它条目，不在本 Spec 验收范围内。

## 范围与非目标

涉及：

- Desktop 公开 API 命名、受控回调形态、Token 取色入口、公开 typedef 的收敛规则与落地清单。
- 列表 / 面板滚动路径的懒构建（Table 表体、Select 选项面板；可扩展到可见树扁平行）。
- 对应 widget 测试与 Gallery 不回归；`flutter analyze --fatal-infos`。

不涉及：

- 真虚拟窗口（只渲染视口像素级 windowing）之外的完整虚拟化算法；Select / Table「无限大数据」产品能力仍可另开 Spec。
- Upload 真实 HTTP、系统文件拖拽插件、图片宫格。
- Web A11y 专项、Visual Diff、文档站点改写。
- Mobile / Adaptive 行为变更。

## 最终方案与行为契约

### API 收敛规则

| 规则 | 要求 |
| --- | --- |
| 单值受控 | 单一值组件用 `value` + `onChanged`（Input、Select 单选、Date/Time、Pagination 当前页）。 |
| 多切片受控 | 多块独立状态用 `onXxxChanged`（Table 的 selection / sort / filter / widths / expanded）。 |
| 公开回调类型 | 多参数公开回调提供顶层 `typedef`（如单元格编辑、行拖拽），避免裸 `void Function(...)` 散落。 |
| Token 入口 | 绘制色 / 半径读 `TDesignTokenScope.of(context)`；禁止在 build 路径硬编码 `TDesignTokens.light`（测试夹具除外）。遗留硬编码色阶逐步迁到 Token key。 |
| 库导出 | `tdesign_flutter_desktop.dart` **不再** re-export Core。调用方分别 `import package:tdesign_flutter_desktop/...` 与 `package:tdesign_flutter_core/...`。Core 类型（Token、Overlay、Interaction、Size）只从 Core 导入。 |
| Breaking | Desktop 仍为 `0.x`：收敛若改名 / 改默认，在本 Spec 兼容性节与 PR 标明；不引入 Mobile 式长废弃期，除非跨包共享符号。 |

#### 首批落地清单（本阶段必须完成）

1. `TTable`：`onCellEdited` / `onDragSort` 改为公开 typedef（`TTableCellEdited` / `TTableDragSort`），签名不变。
2. `TTable` 装饰半径与品牌色改为 `TDesignTokenScope`（去掉 build 内 `TDesignTokens.light`）。
3. 文档：各公开 API 的 `///` 与上表一致；本 Spec 链接写入 085 Phase 4 行。

#### 第二批落地清单

1. Token 补齐桌面常用语义色（经 `tools/token_codegen`）：`brandColor1` / `brandColorLight`、`componentBorder` / `borderLevel1Color`、`textColorSecondary` / `textColorDisabled`、`bgColorComponentDisabled` 及所需 gray / font 叶子；light / dark 对齐 tdesign-common。
2. 组件硬编码 `#RRGGBB` 迁到 `TDesignTokenScope` 对应 key（优先 Select、Date/Time、Tree、Cascader、TreeSelect、Input 边框与禁用底；算法混色如 Button lerp 黑白可保留字面量）。
3. **Breaking（0.x）**：去掉 desktop barrel 对 core 的全量 `export`；本仓库 Gallery / 测试改为双 import，并给 Gallery 增加 `tdesign_flutter_core` path 依赖。

后续批次：其余反馈 / 导航组件残余硬编码色。公开多参数回调已用 `ValueChanged` / 既有 typedef；私有 `void Function` 不提升为公开 typedef。

#### 第三批落地清单

1. Dialog / Dropdown / Popover / Menu / Tabs / Pagination / Breadcrumb 的容器、边框、文案、悬停、选中底改为 `TDesignTokenScope`。Tabs 不再读 `TDesignTokens.light`。
2. 保留：遮罩 `0x66000000`、阴影、Tooltip 黑底白字（无独立 token）、Button 混色字面量。
3. Menu 选中底 light 用 `brandColorLight`，dark 用 `grayColor11`；悬停用 `bgColorContainerHover`；边线用 `borderLevel1Color`。

#### 第四批落地清单

1. Tag / Link / Badge / Table / Divider / Radio / Checkbox / Switch / Textarea / Form 标签与错误色 / Upload 失败色改为 `TDesignTokenScope`。Radio、Checkbox、Switch、Textarea、Tag 不再读 `TDesignTokens.light`。
2. `TDivider.color` 改为可空；`null` 用 `borderLevel1Color`。显式传入的颜色不变。
3. 仍保留：Button 黑白 lerp、Tooltip 黑底白字、遮罩与阴影字面量、透明底。

### 性能契约

| 路径 | 要求 |
| --- | --- |
| Table + `maxHeight` | 表体使用 `ListView.builder`（或等价懒构建）。固定行高时提供 `itemExtent`（当前钉住行高 `_pinnedExtent` / 表体行高一致处）。**禁止**先 `children: [...]` 再建 `ListView`。无 `maxHeight` 的短表可继续 `Column`。 |
| Select 面板 | 选项列表在 `ConstrainedBox(maxHeight: …)` 内使用 `ListView.builder`；分组头 / 创建行作为扁平行参与 builder，不得为每个选项预构建完整 widget 树再塞进 `ListView(children:)`。 |
| 测试不变量 | 既有滚动 / 点选测试仍通过；新增或保留「大行数 + maxHeight 仍可滚到末行」类测试证明 builder 路径可交互（不测帧耗时数值）。 |

真虚拟窗口（按像素回收离屏子树的窗口算法）与树懒加载仍非目标。

## 关键决策与取舍

| 决策 | 原因 |
| --- | --- |
| Phase 4 性能/API 单独立 Spec，不扩写 086 | 086 已冻结 P0 能力；Hardening 有独立 Gate。 |
| builder 懒构建优先于完整虚拟窗口 | 0.x 收益 / 风险比最高；完整虚拟化可后开。 |
| typedef 不改运行时签名 | 纯 API 形态收敛，调用点源码可不变。 |
| desktop 停止 re-export core | 1.0 候选边界清晰：组件包与 Foundation 包分依赖；0.x 内一次改完本仓库调用点。 |

## 兼容性与迁移

- typedef 替换：源码兼容；强类型别名可能影响显式类型注解，按编译器提示改为新 typedef 名即可。
- Token 入口变化：有自定义 `TDesignTokenScope` 的调用方在 Table 上会开始跟随 scope（此前误锁 light）；这是修正，记为 0.x 行为收敛。
- ListView.builder：无公开 API 变化。
- 去掉 desktop→core re-export：凡使用 `TDesignTokenScope` / `TOverlayPortal` / `TComponentSize` / `TInteractiveRegion` 等的调用方增加 `import 'package:tdesign_flutter_core/tdesign_flutter_core.dart';`，并在 pubspec 声明 core 依赖（透传依赖不足以保证稳定 API）。
- 硬编码色迁 Token：选中浅底等改为 `brandColorLight`（common `#f2f3ff`），与旧字面量 `#E7F3FF` 可能有可见差，属对齐 common。

## 验收标准

| 标准 | 可观察的预期 | 验证方式与边界 |
| --- | --- | --- |
| Spec 入库 | 本目录 + engineering README / 085 交叉引用存在 | 文档审查 |
| typedef | `TTableCellEdited` / `TTableDragSort` 导出且 Table 使用 | analyze + 编译 |
| Token scope | Table 半径 / 品牌色经 `TDesignTokenScope.of` | 代码审查；可选 widget 测试 |
| Table builder | `maxHeight` 表体为 builder；大行数可滚到末行 | `t_table_*` 测试 |
| Select builder | 选项面板为 builder；既有 Select 交互测试通过 | `t_select_*` 测试 |
| 质量门 | desktop 与 gallery `analyze --fatal-infos`；desktop `flutter test` | 本地 / CI |
| 第二批 Token | light/dark 可读 `brandColorLight`、`componentBorder`、`textColorSecondary`、`bgColorComponentDisabled` | token_codegen 测试 + 生成文件审查 |
| 第二批取色 | Select/Date/Time/Tree/Input 等目标文件 build 路径无 `TDesignTokens.light`，硬编码仅保留透明/混色字面量 | 代码审查 + analyze |
| re-export 拆分 | desktop barrel 无 core export；gallery/测试双 import 可编译 | analyze |
