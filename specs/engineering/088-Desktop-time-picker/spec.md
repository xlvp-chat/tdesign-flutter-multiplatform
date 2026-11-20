# Desktop TimePicker

来源：本地 `tdesign-vue-next` 的 `TimePicker` 单值选择。实现在 `packages/tdesign_flutter_multi_desktop`。ADR-002 / ADR-006 仍然适用。

## 范围

- 受控 [TTime]：时、分、秒。
- 默认展示 `HH:mm:ss`。[showSeconds] 为 `false` 时展示 `HH:mm`，秒保持 0。
- 点击输入区域打开三列（或两列）面板。点某一项立刻回调，面板保持打开，直到点外部或 Esc。
- [clearable] 清空为 null。
- [steps]（[TTimeSteps]）：时 / 分 / 秒间隔，默认均为 1。列只列出落在步长上的值。
- [disableTime]：按当前时、分、秒返回要禁用的时 / 分 / 秒列表（对齐 Vue `disableTime`）。[hideDisabledTime] 默认 `true`：禁用项不出现在列中；为 `false` 时灰色展示且不可点。
- [allowInput]（默认 `false`）：触发器可手输。`showSeconds` 为 true 时格式 `HH:mm:ss`，否则 `HH:mm`。失焦或回车解析；合法、落在步长上且未被 [disableTime] 挡住则回调；空串在可清除时清空；否则回退为当前受控值展示。
- [presets]：`List<TTimePreset>`（`label` + `time` 工厂）。面板底部列出；点选后关闭。禁用或离步的预设忽略。

## 非目标

毫秒列。范围时间见 [094-Desktop-time-range-picker](../094-Desktop-time-range-picker/spec.md)。
