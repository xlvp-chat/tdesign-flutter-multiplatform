# Changelog

## 0.1.0

首个稳定版本。通过仓库 tag `desktop-v0.1.0` 交付，不发布到 pub.dev。

- `TDesignApp` 按窗口宽度与指针/键盘信号解析 `mobile` 或 `desktop`，并通过 `AdaptiveScope` 下发
- 不按 `Platform.isXxx` 选择形态
- 不替换子树中的 Mobile / Desktop 组件，调用方自行读取 `AdaptiveScope`
