# TDesign Flutter Desktop 架构基线 — 未完成事项

## 当前工作

- [x] Spec + ADR-001～008
- [x] packages core/desktop/adaptive
- [x] Phase 0 PoC + **Go**
- [x] Foundation v0.1（flip/shift、focus restore、API 说明）
- [x] MVP-P0 组件集 + desktop_gallery CRUD/shell
- [x] AdaptiveResolver / TDesignApp
- [x] `.github/workflows/desktop-packages.yml`

## 后续扩展（不阻塞基线）

- [x] Phase 3 复杂组件按业务开启（DatePicker / TimePicker / Tree / Cascader / TreeSelect / Upload 已落地；Date/Time 手输与预设、Select 远程/创建、Table 列宽/编辑/行拖拽、Button href 等进阶已补；虚拟滚动 / Upload HTTP 拖拽 / 树懒加载仍为非目标）
- [x] Phase 4 性能 / API 收敛（[095](../095-Desktop-phase4-hardening/spec.md)；色迁含遮罩/阴影/Tooltip；Button 黑白 lerp 与帧耗时基准仍保留）
- [x] Vue Next 参考页锁定（`examples/desktop_gallery/visual/vue_reference.lock.json`；像素级 Visual Diff 仍不做，见 086）
- [x] Token CI drift vs locked common revision（`tools/token_codegen/common/web-theme.lock.json` + `common_drift_test`；CI 已跑 `dart test`）
- [x] CNB reusable stage 同步接入 desktop 包（`.desktop-332` / `.desktop-latest`；develop push 与 pull_request 引用）
- [x] 指针类型运行时探测完善（触屏/键鼠切换；键盘拔出无平台信号，会话内保持可用）
