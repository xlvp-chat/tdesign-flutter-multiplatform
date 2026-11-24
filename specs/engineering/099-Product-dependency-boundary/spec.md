# 分产品依赖边界

挂在 [085](../085-Desktop-architecture-baseline/spec.md)（ADR-001 / ADR-005）。取代 [098](../098-Adaptive-button-facade-pilot/spec.md) 的组件交换试点：双端靠两个产品入口各自依赖一套组件包，不靠编译期条件 import，也不靠 Adaptive 交换 Widget。

## 背景与目标

手机 example 与桌面 gallery 的 `pubspec` 已经分开。本契约冻结这条边界，并禁止 Adaptive 再同时链接 Mobile 与 Desktop 组件包。

## 范围与非目标

- 涉及：两个现有产品入口的 TDesign 依赖、`tdesign_flutter_multi_adaptive` 只保留 mode 信号、CI 检查 `dependencies` 键。
- 不涉及：新建第三套 App；把 Mobile example 的其它非 TDesign 依赖清掉；改 Mobile / Desktop 组件实现；用 `Platform.isXxx` 或 `dart.library` 条件 import 在一次编译里切换组件包。
- 边界：业务要双端就做两个 target，各自一份 `pubspec`。

## 最终方案与行为契约

| 产品入口 | 必须依赖 | 禁止依赖 |
| --- | --- | --- |
| `tdesign-component/example` | `tdesign_flutter` | `tdesign_flutter_multi_core`、`tdesign_flutter_multi_desktop`、`tdesign_flutter_multi_adaptive` |
| `examples/desktop_gallery` | `tdesign_flutter_multi_core`、`tdesign_flutter_multi_desktop` | 包名恰好为 `tdesign_flutter`、以及 `tdesign_flutter_multi_adaptive` |
| `packages/tdesign_flutter_multi_adaptive` | `flutter` | `tdesign_flutter`、`tdesign_flutter_multi_core`、`tdesign_flutter_multi_desktop` |

- 键名按 YAML `dependencies` 下的包名精确匹配。`tdesign_flutter_multi_*` 不算 `tdesign_flutter`。
- 手机 example 可以继续依赖 `css2token`、图标包和示例用第三方库；本契约只约束上表的 TDesign 组件包。
- Adaptive 提供 `TDesignApp` / `AdaptiveResolver` / `AdaptiveScope`（窗口尺寸与指针）。它不构建 Mobile 或 Desktop 组件。
- 桌面产品不依赖 Adaptive。需要 mode 信号的宿主自行依赖 adaptive 包，且该宿主不能再同时依赖两套组件包来做组件交换。

## 关键决策与取舍

| 决策点 | 采用 | 否决 | 代价 |
| --- | --- | --- | --- |
| 双端交付 | 两个产品入口、两份依赖 | 一个 App 里条件 import 切换组件包 | 共享 UI 要写两套页面 |
| Adaptive | 只保留 mode 信号，不依赖组件包 | 保留 `AdaptiveButton`（098） | 没有统一 Button 入口 |
| 门禁 | 检查三份 `pubspec` 的 `dependencies` 键 | 只靠文档 | 不扫描传递依赖 |

## 兼容性与迁移

- 删除未发布试点 `AdaptiveButton`。仓库内无其它调用点。
- Mobile / Desktop 公开组件 API 不变。
- 085 中「业务可通过 Adaptive 渐进引入」改为：Adaptive 只提供窗口/指针 mode，不交换组件；双端靠分产品依赖。

## 验收标准

| 标准 | 可观察的预期 | 验证方式与边界 |
| --- | --- | --- |
| 依赖键 | 三份 `pubspec` 符合上表 | `dart tools/check_product_deps.dart`；desktop CI 同一步 |
| Adaptive | analyze / test 通过，且不再导出 `AdaptiveButton` | `packages/tdesign_flutter_multi_adaptive` |
| 组件隔离 | 不改 Mobile / Desktop 组件实现 | diff |
