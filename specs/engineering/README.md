# 工程 Spec

[返回总规范](../README.md) · [组件 Spec](../components/README.md)

本目录收录跨组件工程契约，格式为 `<编号>-<类别>-<事项描述>`。按独立职责与独立验收边界决定是否拆分，不按历史任务或 PR 数量创建 Spec。

| Spec | 职责 |
| --- | --- |
| [044-Testing-golden-regression](./044-Testing-golden-regression/spec.md) | Golden 覆盖、精确比较、归属和基线维护 |
| [044-ThemeController-import-and-preview](./044-ThemeController-import-and-preview/spec.md) | 控制器实时预览、生成器 CSS 转换与应用导入 |
| [046-Demo-experience](./046-Demo-experience/spec.md) | 公开示例边界、调试区块和 Demo 体验 |
| [048-Theme-configuration-contracts](./048-Theme-configuration-contracts/spec.md) | Token、TThemeData、组件 Theme、实例 API 及 Material 隔离的统一契约 |
| [080-CI-build-and-validation](./080-CI-build-and-validation/spec.md) | CI 测试分组、生成产物检查与 Demo 构建复用 |
| [057-Release-readiness](./057-Release-readiness/spec.md) | 暂留的发布候选验收门槛；关闭后归入 PUBLISH.md |
| [085-Desktop-architecture-baseline](./085-Desktop-architecture-baseline/spec.md) | Flutter Desktop/Web 独立组件层架构基线、ADR 冻结与 Phase 0 PoC Gate |
| [086-Desktop-p0-capabilities](./086-Desktop-p0-capabilities/spec.md) | Desktop P0 能力补全：状态色 Token，以及 Button、Input、Select、Form、Pagination、Tabs、Menu、Table 的 API 契约 |
| [087-Desktop-date-picker](./087-Desktop-date-picker/spec.md) | Desktop 单日 DatePicker：月历、清空、禁用日期 |
| [088-Desktop-time-picker](./088-Desktop-time-picker/spec.md) | Desktop 单值 TimePicker：时分秒列、清空 |
| [089-Desktop-tree](./089-Desktop-tree/spec.md) | Desktop Tree：展开、高亮、勾选与父子联动 |
| [090-Desktop-cascader](./090-Desktop-cascader/spec.md) | Desktop Cascader：单选列表面板、路径展示、清空 |
| [091-Desktop-tree-select](./091-Desktop-tree-select/spec.md) | Desktop TreeSelect：单选触发器 + 面板树 |
| [092-Desktop-upload](./092-Desktop-upload/spec.md) | Desktop Upload：file 主题列表、选择注入、可选 request |
| [093-Desktop-date-range-picker](./093-Desktop-date-range-picker/spec.md) | Desktop DateRangePicker：双月区间、清空、禁用日期 |
| [094-Desktop-time-range-picker](./094-Desktop-time-range-picker/spec.md) | Desktop TimeRangePicker：起止双面板、清空 |
| [095-Desktop-phase4-hardening](./095-Desktop-phase4-hardening/spec.md) | Desktop Phase 4：性能（列表懒构建）与公开 API 收敛 |

Theme 只维护一份配置契约，Material 隔离是其中一章；Token 运行要求归 [Theme 验收](./048-Theme-configuration-contracts/acceptance.md)，报告、截图、审计表归该目录的 `evidence/`，不单设验证 Spec。ThemeController 独立维护输入转换和主题同步链路。

Testing 只维护 Golden；通用文档与测试规范维护在 CONTRIBUTING.md 和站点指南。Release 暂存未关闭的候选门槛，不沿用旧 PR 或历史 CI 作为当前发布状态。
