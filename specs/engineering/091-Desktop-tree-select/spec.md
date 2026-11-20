# Desktop TreeSelect

来源：本地 `tdesign-vue-next` 的 `TreeSelect` 基础单选。实现在 `packages/tdesign_flutter_multi_desktop`。ADR-002 / ADR-006 仍然适用。面板树复用 [TTree](../089-Desktop-tree/spec.md)。

## 范围

- 数据为 [TTreeNode] 列表。
- 受控叶子或任意节点值 [value]（`String?`）+ [onChanged]。点面板中非 disabled 节点即选中并关闭。
- 触发器展示选中节点的 `label`；无值时显示 [placeholder]。
- [clearable] 清空为 null。
- 面板内树的展开受控于组件内部状态；打开时按当前 [value] 展开其祖先。
- 面板使用 [TOverlayPortal]。
- [multiple] 默认 false。为 true 时使用 [values] / [onValuesChanged]，面板树改为可勾选，点选不关闭。触发器把各项 `label` 用 `, ` 连接。勾选遵循 [TTree] 的 `onlyLeaf`。
- [filterable] 默认 false。面板顶部出现搜索框，查询传给 [TTree.filter]。

## 非目标

`treeProps` 透传全量、懒加载、折叠标签、自定义 valueDisplay。
