# Desktop TimeRangePicker

来源：本地 `tdesign-vue-next` 的 `TimeRangePicker`。实现在 `packages/tdesign_flutter_multi_desktop`。ADR-002 / ADR-006 仍然适用。复用 [TTime](../088-Desktop-time-picker/spec.md) / [TTimeSteps]。

## 范围

- 受控 [TTimeRange]（`start` / `end`）+ [onChanged]。展示为 `HH:mm:ss 至 HH:mm:ss`（或无秒时 `HH:mm`）；两端皆空时显示 placeholder。
- 面板左右两列时间（开始 / 结束），点列立刻回调，面板保持打开。
- [clearable] 清空为两端 null。
- [showSeconds]、[steps] 与单值 TimePicker 相同语义。
- [allowInput] 默认 false。格式为 `HH:mm:ss 至 HH:mm:ss`，无秒时为 `HH:mm 至 HH:mm`。失焦或回车提交；两端都合法、落在步长上且未被 [disableTime] 挡住才回调。空串在 [clearable] 时清空。非法输入回退为当前受控展示。
- [presets] 为 `TTimeRangePreset`。点预设写入该区间并关闭面板。
- [disableTime] 与单值选择器相同，分别作用于开始、结束当前时刻。`hideDisabledTime` 默认 true，被禁用的刻度不出现在列里。

## 非目标

自动校正 end < start。
