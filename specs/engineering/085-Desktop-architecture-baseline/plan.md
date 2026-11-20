# TDesign Flutter Desktop 架构基线 — 实施方案

## 实现组织

```
packages/
  css2token/                    # 既有 Token 解析，PoC 优先复用/增强
  tdesign_flutter_multi_core/         # Token / Theme / Interaction / Overlay / Semantics
  tdesign_flutter_multi_desktop/      # Desktop/Web 组件（Windows/macOS/Web）
  tdesign_flutter_multi_adaptive/     # 按能力选择 Mobile/Desktop 形态
tdesign-component/              # 既有 Mobile（包名 tdesign_flutter），暂不搬迁
examples/                       # 后续：desktop_gallery / web_gallery（PoC 后补）
```

状态流：Spec/Token → Core Foundation → Desktop 组件 → Adaptive → 业务。

## 影响范围

| 范围 | 实际文件或模块 | 要同步的内容 |
| --- | --- | --- |
| 实现 | `packages/tdesign_flutter_*`、必要时增强 `packages/css2token` | Foundation + PoC 组件 |
| 消费者与示例 | 后续 `examples/desktop_gallery` | Demo / 键盘与 Focus 说明 |
| 测试与文档来源 | 各包 `test/`、本 Spec | Interaction / Widget；Vue Next 参考 diff 后期 |

## 依赖与实施顺序

1. 冻结本 Spec（ADR）并建立三个包骨架。
2. Token PoC（css2token → Dart 语义 Token）。
3. Interaction + Overlay Foundation API。
4. Button / Input → Select → Table skeleton。
5. 记录 PoC Go/No-Go 到 `acceptance.md`；Go 则冻结 Foundation v0.1。

## 验证安排

- 包：`dart pub get` + `dart analyze`（各新包）。
- PoC：Select 键盘开合与 focus restore；Token 生成无 silent drift 检查入口；Table typed column 编译期可用。
- Mobile：Core 改动后跑既有 Mobile smoke（Phase 1 起强制）。
