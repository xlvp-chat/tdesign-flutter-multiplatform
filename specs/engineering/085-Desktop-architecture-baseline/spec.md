# TDesign Flutter Desktop 架构基线

来源：[TDesign_Flutter_Desktop_技术方案_V1.docx](../../../../TDesign_Flutter_Desktop_技术方案_V1.docx)（V1.0，2026-11-15，方案评审稿）。本文将该技术方案冻结为仓库内可执行的架构与实施基线。

## 背景与目标

当前 `tdesign_flutter`（`tdesign-component`）定位为 Mobile Components。Flutter SDK 支持 Windows / macOS / Web 只证明运行平台可达，不证明已具备与 TDesign Vue Next 等价的桌面组件范式。

目标：

- 建立独立的 Desktop Component Layer（Windows / macOS / Flutter Web 共用实现）。
- 以 Vue Next / tdesign-common 为 Spec Source；Flutter 原生 Widget / Focus / Overlay / Semantics 实现。
- 先 Foundation（Token / Interaction / Overlay），再组件；用 Phase 0 PoC Go/No-Go 决定是否进入正式建设。

## 范围与非目标

- 涉及：包分层（Core / Mobile / Desktop / Adaptive）、ADR 冻结、Phase 0 PoC、后续 Foundation → MVP 实施顺序。
- 不涉及：WebView / DOM 包装 Vue；V1 全量 Vue Next 长尾组件；Mobile 与 Desktop 逐像素同一 Widget 树；以 `Platform.isXxx` 作为 Adaptive 主依据。
- 边界：现有 `tdesign_flutter` 继续服务 Mobile；Desktop 新包不直接改写 Mobile 组件内部行为；Core 变更须跑 Mobile smoke/golden。

## 最终方案与行为契约

### 包分层

| 层 | 职责 | 禁止 |
| --- | --- | --- |
| Spec/Token | 设计值、API 语义、状态与交互规范 | Flutter 运行时代码 |
| `tdesign_flutter_multi_core` | Token、Theme、Icon、状态枚举、Interaction、Overlay、Semantics utilities | Mobile/Desktop 业务组件 |
| `tdesign_flutter` | 现有 Mobile 组件 | 大量桌面条件分支冒充 Desktop |
| `tdesign_flutter_multi_desktop` | Desktop/Web 视觉与组件 | DOM/CSS 依赖、大量 OS 判断 |
| `tdesign_flutter_multi_adaptive` | 按窗口/输入能力选择形态 | 仅按 Platform OS 判断 |

V1 先在现有 monorepo 的 `packages/` 下落地；API 稳定前不拆独立仓库。

### Phase 0 PoC（Go/No-Go）

必须在 2～3 周窗口内验证：

1. Token：从 tdesign-common / 现有 css2token 能力生成 Dart Token。
2. Interaction：`TInteractiveRegion` + Focus ring + keyboard activation。
3. Overlay：anchored popup（flip/shift/outside click/Esc/focus restore）。
4. Button / Input：visual state + Theme + density。
5. Select：Input + Overlay + keyboard + controlled value。
6. Table skeleton：typed column API、row hover、selection、sort。

**Go：** Select 的 Overlay/Focus/Keyboard、Token 自动生成、Table typed API 均可稳定跑通 → 进入 Phase 1 Foundation。  
**No-Go：** 失败则只修 Foundation，不堆组件。

### 后续阶段（基线排期，非合同）

| 阶段 | 主要输出 | Gate |
| --- | --- | --- |
| Phase 1 Foundation | Core/Theme/Token/Focus/Overlay/Semantics/CI | Foundation API 冻结 v0.1 |
| Phase 2 MVP | 以真实 CRUD 页面倒推的 P0 组件集 | 业务页可完成 CRUD |
| Phase 3 Complex | Tree/DatePicker 等按业务裁剪 | 主要管理场景 |
| Phase 4 Hardening | Web A11y、性能、文档、API 收敛（性能 / API 见 [095](../095-Desktop-phase4-hardening/spec.md)） | 内部正式发布 / 1.0 候选 |

P0 能力的 API、非目标与状态色 Token 见 [086-Desktop-p0-capabilities](../086-Desktop-p0-capabilities/spec.md)。ADR-002、ADR-006 与 Desktop `0.x` 继续适用，不改 Mobile 组件。

## 关键决策与取舍（ADR 冻结）

| ADR | 决策 | 状态 |
| --- | --- | --- |
| ADR-001 | 建立独立 Desktop Component Layer，不以 Mobile Widget 条件分支为主路线 | Accept |
| ADR-002 | Vue Next / TDesign Common 为 Spec Source；不复用 Vue 运行时 | Accept |
| ADR-003 | Desktop/Web 共用组件实现，Web 差异放 Adapter/Semantics 层 | Accept |
| ADR-004 | Overlay/Interaction 先于复杂组件建设 | Accept |
| ADR-005 | Adaptive 按窗口尺寸与输入能力，不按 OS 直接分支 | Accept |
| ADR-006 | Flutter API 保持 Dart idiom，语义对齐而非签名机械一致 | Accept |
| ADR-007 | Table 新设计，不以现有 Mobile Table 为唯一演进基底 | Accept |
| ADR-008 | Visual Regression 以 Vue Next 参考页作为跨栈对齐机制 | Accept |

否决方案：在现有 Mobile 组件上大量 `Platform.isXxx` 分支；WebView 嵌入 Vue；Material 3 默认视觉充当 TDesign Desktop。

## 兼容性与迁移

- Desktop 子包以 `0.x` 起步，允许较快演进；核心 API / Theme / Overlay / 命名稳定并完成业务验证后进入 1.0。
- 现有 Mobile 消费者路径不变；业务可通过 Adaptive 渐进引入。
- Core 抽取不得破坏 Mobile 公开 API；若必须移动符号，须有 migration note。

## 验收标准

| 标准 | 可观察的预期 | 验证方式与边界 |
| --- | --- | --- |
| ADR 冻结 | ADR-001～008 写入本 Spec 且状态为 Accept | 文档审查 |
| 包骨架存在 | `packages/tdesign_flutter_multi_core`、`tdesign_flutter_multi_desktop`、`tdesign_flutter_multi_adaptive` 可 `dart pub get` / analyze | 本地命令 |
| PoC Go | Select Overlay/Focus/Keyboard、Token 生成、Table typed API 稳定 | Widget/Interaction 测试 + 手工键盘验收 |
| Mobile 隔离 | Desktop 实现不修改 Mobile 组件内部行为路径 | Diff / Mobile smoke |
| Token drift | `tools/token_codegen/common/web-theme.lock.json` 锁定一份 tdesign-vue-next `packages/common` 的 web theme 修订。Desktop demo CSS 里除登记过的 PoC 覆盖外，解析后的颜色与该修订一致 | `tools/token_codegen` 的 `dart test`。升级 common 时用 `dart run bin/lock_common.dart --root <tdesign-vue-next>` 重写锁文件并核对覆盖项 |
| 指针探测 | `TDesignApp` 在收到鼠标 / 触控板、触摸、手写笔事件后更新 `primaryPointer`。首个按键把键盘标为可用；Flutter 不报告键盘拔出，该标记在本次会话内保持 | `packages/tdesign_flutter_multi_adaptive` widget 测试 |
| Desktop CNB | `.cnb/.reusable-stages.yml` 的 `.desktop-332` / `.desktop-latest` 跑 token codegen、core / desktop / adaptive 的 analyze+test、gallery analyze 与 test。develop push 与 pull_request 引用这两条。CNB 配置没有路径过滤，和 GitHub 的 path filter 不同 | 配置审查。本机不代替 CNB 执行 |
| Vue 参考页 | `examples/desktop_gallery/visual/vue_reference.lock.json` 锁定 gallery `source` 对应的 Vue Next `_example` 文件名。像素级截图对比仍不做（[086](../086-Desktop-p0-capabilities/spec.md)） | `examples/desktop_gallery` 的 `flutter test` |
