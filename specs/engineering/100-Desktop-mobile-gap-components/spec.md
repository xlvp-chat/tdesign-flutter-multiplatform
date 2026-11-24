# Desktop 补齐手机已有、桌面缺失的 Vue 组件

挂在 [085](../085-Desktop-architecture-baseline/spec.md)。对照本地 `tdesign-vue-next@0ea1919`。只补「手机 `tdesign_flutter` 有实现，且 Vue Next 有同名组件，桌面包还没有」的集合。

## 背景与目标

桌面包此前覆盖 Button、Form、Table 等 P0。手机已有、桌面没有、Vue 有对照的组件需要桌面实现，视觉与基础交互对齐 Vue，而不是移植手机 Widget。

## 范围与非目标

- 涉及：Avatar、BackTop、Calendar、Collapse、Drawer、Empty、Image、ImageViewer、Loading、Message、Progress、Rate、Skeleton、Slider、Steps、Swiper 的桌面公开组件、Gallery 页和基础测试。
- 不涉及：ActionSheet、TabBar、Toast、Navbar 等 Vue Next 没有同名目录的手机组件；各组件的 Vue 长尾（Calendar 控制器全集、Swiper 卡片/淡入、Slider 范围与刻度、Image 懒加载、Message 插件全部位置）。
- 边界：不改手机组件。不把两端收成一个 Widget。

## 最终方案与行为契约

每个组件只冻结基础路径。颜色读 `TDesignTokenScope`，缺省 light。

| 组件 | 基础契约 |
| --- | --- |
| `TAvatar` / `TAvatarGroup` | 尺寸 small 24 / medium 32 / large 40；形状 circle、round；文字、图标或 `ImageProvider`；组超出 `max` 显示 `+N` |
| `TBackTop` | 绑定 `ScrollController`，超过 `visibilityHeight`（默认 200）显示；点击滚回顶部 |
| `TCalendar` | 月视图，周一为一周起点；选中日期回调 |
| `TCollapse` | 面板标题与内容；`accordion` 时只展开一个 |
| `TDrawer` | `visible` 受控；默认右侧宽 300；蒙层与 Esc 关闭 |
| `TEmpty` | `title` / `description`；类型 empty、success、fail、network-error、maintenance |
| `TImage` | `image` 或 `src`；失败显示错误图标 |
| `TImageViewer` | 受控 `visible` 与 `index`；上一张、下一张、关闭 |
| `TLoading` | `loading` 时覆盖子树并显示指示 |
| `TMessage.show` | 主题 info / success / warning / error；默认 3 秒关闭 |
| `TProgress` | `percentage`；theme line / plump / circle |
| `TRate` | 默认 5 星，点击设置整数分值 |
| `TSkeleton` | `loading` 时显示占位条，否则显示 `child` |
| `TSlider` | 单值，默认 0–100，拖动回调 |
| `TSteps` | `current` 下标；之前为完成，当前为进行中 |
| `TSwiper` | 子页与圆点；点击圆点切换。默认不自动播放 |

## 关键决策与取舍

| 决策点 | 采用 | 否决 | 代价 |
| --- | --- | --- | --- |
| 范围 | 手机 ∩ Vue \ 桌面 | 把全部手机组件都做一遍 | 无 Vue 对照的手机组件仍缺桌面版 |
| 深度 | 各组件基础路径 | 一次对齐 Vue 全部示例 | Gallery 只覆盖基础示例，锁文件仍列出 Vue 示例文件名 |
| 实现 | 桌面新 Widget + Token | 条件分支复用手机组件 | 与 ADR-001 一致，两套实现 |

## 兼容性与迁移

Desktop `0.x` 只新增 API，不改既有组件签名。

## 验收标准

| 标准 | 预期 | 验证 |
| --- | --- | --- |
| 公开导出 | 上表类型可从 desktop 包导入 | 编译 |
| 基础行为 | 每个组件至少一条 widget 测试 | `tdesign_flutter_multi_desktop` test |
| Gallery | 新页 `source` 与 `vue_reference.lock.json` 键一致 | `desktop_gallery` test |
| analyze | desktop 与 gallery 无诊断 | `flutter analyze --fatal-infos` |
