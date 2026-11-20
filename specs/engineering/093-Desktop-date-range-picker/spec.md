# Desktop DateRangePicker

来源：本地 `tdesign-vue-next` 的 `DateRangePicker`（仅日期、无时间）。实现在 `packages/tdesign_flutter_multi_desktop`。ADR-002 / ADR-006 仍然适用。日历格子复用 [DatePicker](../087-Desktop-date-picker/spec.md) 的 `calendarDays` / `weekdayLabels`。

## 范围

- 受控 [TDateRange]（`start` / `end`，均可为 null）+ [onChanged]。展示为 `YYYY-MM-DD 至 YYYY-MM-DD`；仅有一端时只展示已选端。
- 双月面板。第一次点选为起点（草稿），第二次点选为终点：若终点早于起点则交换；完整区间回调后关闭。
- 区间内日期高亮（含端点）。
- [clearable] 清空为两端 null。
- [disableDate] 禁用的日期不可选。
- 左右月各自可切换年/月；打开时左月对齐 `start`（或今天），右月为左月 + 1。
- [allowInput] 默认 false。格式 `YYYY-MM-DD 至 YYYY-MM-DD`；[enableTime] 时为 `YYYY-MM-DD HH:mm 至 YYYY-MM-DD HH:mm`。失焦或回车提交；非法或禁用日回退。空串在 [clearable] 时清空。
- [presets] 为 `TDateRangePreset`。点预设写入区间并关闭面板。
- [enableTime] 默认 false。为 true 时日期保留时分；面板在双月下方提供开始/结束的时、分。第二次点选完成区间时，起点默认 00:00、终点默认 23:59，除非该端已经有时间。

## 非目标

单月面板模式、week/month/year 区间、秒。
