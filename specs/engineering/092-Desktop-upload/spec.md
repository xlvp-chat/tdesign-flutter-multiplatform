# Desktop Upload

来源：本地 `tdesign-vue-next` 的 `Upload`（`theme=file` 基础列表）。实现在 `packages/tdesign_flutter_multi_desktop`。ADR-002 / ADR-006 仍然适用。

## 范围

- [TUploadFile]：`name`、可选 `size` / `url` / `error`、[status]（`waiting` / `progress` / `success` / `fail`）、可选 `percent`（0–100）。
- 受控 [files] + [onChanged]。
- [pickFiles] 注入选择器（平台文件对话框由调用方提供）；点触发按钮调用它，将返回项追加进列表后回调。
- [autoUpload] 默认 `true`：追加后对 `waiting` 项依次调用可选的 [request]；无 [request] 时保持 `waiting`。
- [multiple] 默认 `false`：单选时新文件替换列表；多选时追加。
- [max] 为 0 表示不限制；多选追加时截断到剩余名额。
- 列表展示文件名、状态文案；每项可移除（从列表删除并回调）。
- [enabled] 为 `false` 时不可选、不可移除。
- [theme] 默认 `file`，即现有文件名列表。[image] 用 **110px** 卡片：优先渲染 [TUploadFile.preview] / [url] 缩略图，否则占位；末尾 add 格继续选择（达 [max] 或单选已有文件时隐藏）。[fileFlow] 用表格式行：文件名、大小、状态；`size` 为空显示 `—`。
- image 主题细节与 hover / 状态叠层见 [097](../097-Desktop-icon-affordance-and-upload-card/spec.md)。

## 非目标

真实 HTTP / `action`、拖拽、`image-flow`、进度模拟定时器、abridgeName、批量整包替换、内置 `file_picker` 依赖。默认不强制解码本地字节；有 `preview` / `url` 时渲染缩略图。
