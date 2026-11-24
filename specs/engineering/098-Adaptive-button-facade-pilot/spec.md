# Adaptive Button Facade 试点（已撤回）

本试点已撤回。当前要求见 [099 分产品依赖边界](../099-Product-dependency-boundary/spec.md)。

## 撤回原因

`AdaptiveButton` 让 `tdesign_flutter_multi_adaptive` 同时依赖 Mobile 与 Desktop 组件包。这和「两个产品入口各自只链一套组件」冲突，也不能在编译期去掉另一套包。

仓库不再提供 `AdaptiveButton`。Adaptive 只保留 `TDesignApp` / `AdaptiveResolver` / `AdaptiveScope`。
