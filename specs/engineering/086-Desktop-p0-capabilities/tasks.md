# Desktop P0 能力补全 — 未完成事项

契约见 [spec.md](./spec.md)。

## 当前工作

- [x] Spec：API、状态色 key、非目标
- [x] codegen 写入 light/dark 的 error / warning / success 色阶，以及 css2token 已有的浅底、disabled、focus、active 别名。未新增 `errorColorHover` / `warningColorHover` / `successColorHover`

## 已完成

- [x] Button：`TButtonTheme` × `TButtonVariant` × `TButtonShape` × `ghost`；primary / danger / warning / success 的填充 hover / disabled 用 Spec 里的混白与透明度算法；迁移 Gallery、Pagination、InputNumber、Dialog
- [x] Input：`clearable`、`obscureText`、`TInputStatus`、`maxLength` + `showLimit`（`String.length`）、画出 `placeholder`（`textColorPlaceholder`）
- [x] Select：保留单选 `value` / `onChanged`；`multiple` + `values` + `onValuesChanged`、`filterable`、`clearable`
- [x] Form：`TFormController`、`TFormItem.name` + `rules`、`TFormRule`、`TFormFieldScope`；Gallery 改为规则示例
- [x] Pagination 页码与省略号、`showJumper`、`pageSizeOptions`
- [x] Tabs `placement` 与 `size`（medium / large）
- [x] Menu `icon`、`theme`、`axis: horizontal`。暗色底用 dark `bgColorContainer`（`#242424`），不另加 `grayColor13`
- [x] Table 筛选、左右固定列、`childrenOf` + `expandedKeys`
- [x] 每个能力一条 widget 测试，Gallery 补对应区块
- [x] `TDesignTokenScope`（`packages/tdesign_flutter_multi_core/lib/src/token/tdesign_token_scope.dart`）。缺省 `TDesignTokens.light`。子树可提供 `TDesignTokens.dark`。Button、Input、Menu 的状态色 / 品牌色 / 文字色 / 容器色从该 scope 读取。Menu `theme: dark` 在菜单子树内提供 dark token set
- [x] `bgColorContainerHover`（`--td-bg-color-container-hover`）：light `#F3F3F3`，dark `#2C2C2C`。css2token 语义表没有这个名字，由 `tools/token_codegen` 写入。`defaultTheme` 填充按钮 hover 读它。primary / danger / warning / success 仍是混白 0.08 / 混黑 0.12 / alpha 0.4
- [x] `textColorAnti`（`--td-text-color-anti`）：light / dark 都是 `#FFFFFF`。Menu 暗色文字读 dark token set 的这个 key

## 未决

无。
