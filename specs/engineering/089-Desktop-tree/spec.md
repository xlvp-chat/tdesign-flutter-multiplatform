# Desktop Tree

来源：tdesign-vue-next `Tree` 的基础展开 / 高亮 / 勾选。实现在 `packages/tdesign_flutter_multi_desktop`。ADR-002 / ADR-006 仍然适用。

## 范围

- [TTreeNode]：`value`（`String`）、`label`（`String`）、`children`、`disabled`。
- 受控 [expandedKeys] + [onExpandedKeysChanged]。有子节点时点展开图标切换；叶子不显示图标。
- [activable] 时受控 [activedKeys] + [onActivedChanged]。默认单高亮：点标签把该节点设为唯一高亮；再点同一节点取消。
- [checkable] 时受控 [checkedKeys] + [onCheckedChanged]，行前显示复选框。语义对齐 Vue Next 的 `value` / `onChange`。
- [checkStrictly] 默认 `false`：勾选 / 取消勾选时联动子孙；祖先按子孙推导全选 / 半选（indeterminate）。
- [valueMode] 默认 [TTreeValueMode.onlyLeaf]（与 Vue Next 默认一致）：上报仅叶子。`all` 时上报含因全选被勾上的父节点。
- [checkStrictly] 为 `true` 时父子互不影响，无半选推导；上报为当前勾选集合。
- [disabled] 节点不可高亮、不可勾选；展开仍可用。
- 缩进按深度；行有 hover；高亮行读品牌浅底。

## 非目标

懒加载、拖拽、虚拟滚动、连接线、operations 槽、`expandMutex` / `expandAll` / `expandLevel` 属性（调用方可自行填 [expandedKeys]）、`activeMultiple`、`keys` 字段别名、过渡动画、`valueMode: parentFirst`。

## 过滤

[filter] 非空时，标签（忽略大小写）命中的节点及其祖先可见，并且这些祖先按展开显示子节点。不命中的分支不渲染。空字符串与 null 相同，仍由 [expandedKeys] 控制展开。
