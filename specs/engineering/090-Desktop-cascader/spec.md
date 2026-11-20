# Desktop Cascader

来源：本地 `tdesign-vue-next` 的 `Cascader` 基础单选。实现在 `packages/tdesign_flutter_desktop`。ADR-002 / ADR-006 仍然适用。

## 范围

- [TCascaderOption]：`value` / `label`（`String`）、`children`、`disabled`。
- 受控叶子值 [value]（`String?`）+ [onChanged]，对齐 Vue `valueType: single`。
- 点击触发器打开列表面板（[TOverlayPortal]）。点非叶子展开下一列；点叶子选中、回调并关闭。
- 打开时按当前 [value] 的路径预展开各列。
- [showAllLevels] 默认 `true`：触发器展示完整路径，以 ` / ` 连接；为 `false` 时只显示叶子文案。
- [clearable] 清空为 null。
- [disabled] 选项不可点选 / 不可展开。
- [multiple] 默认 false。为 true 时使用 [values] / [onValuesChanged]，忽略 [value] / [onChanged]。点可选节点切换是否在列表中，面板保持打开。触发器把各项路径用 `, ` 连接。
- [checkStrictly] 默认 false。为 true 时父节点也可以被选中，同时仍展开下一列。
- [filterable] 默认 false。面板顶部出现搜索框。查询非空时改为扁平列表，路径文案包含查询（忽略大小写）的可选节点可点选。

## 非目标

`valueType: full`、懒加载、hover 展开、自定义列头/列尾、折叠标签、`valueMode`。
