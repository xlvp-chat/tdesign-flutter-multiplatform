# Desktop DatePicker

来源：tdesign-vue-next `DatePicker` 的单日 `mode=date`。实现在 `packages/tdesign_flutter_desktop`。ADR-002 / ADR-006 仍然适用。

## 范围

- 受控 `DateTime?`。展示为 `YYYY-MM-DD`，时间部分忽略。
- 点击输入区域打开月历。点选一天后关闭并回调。
- 年、月切换只改面板，不改已选值。
- `clearable` 清空为 null。
- `disableDate` 返回 true 的日期不可选。
- `firstDayOfWeek` 使用 `DateTime.monday` … `DateTime.sunday`，默认周日，与 Vue `firstDayOfWeek: 7` 一致。
- 「今天」选中本地今天并关闭。
- `allowInput`（默认 `false`）：触发器可手输 `YYYY-MM-DD`。失焦或回车时解析；合法且未被 `disableDate` 挡住则回调并规范化展示；空串在可清除时清空；非法或禁用日则回退为当前受控值展示。手输时点触发器仍可打开月历。
- `presets`：`List<TDatePreset>`，每项 `label` + `date`（`DateTime Function()`）。面板底部在「今天」旁列出；点选等价于选中该日并关闭。不实现 `presetsPlacement`。
- `mode` 默认 `date`。`month` 展示 `YYYY-MM`，面板是当前年的 12 个月，选中值为该月 1 日。`year` 展示 `YYYY`，面板是 12 年一页，选中值为该年 1 月 1 日。`disableDate` 对月模式看该月 1 日，对年模式看该年 1 月 1 日。手输格式与展示一致。

## 非目标

区间选择、时间、季/周模式、多选、自定义单元格。
