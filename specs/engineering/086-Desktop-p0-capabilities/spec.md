# Desktop P0 能力补全

挂在 [085 Desktop 架构基线](../085-Desktop-architecture-baseline/spec.md) 上。规格来源仍是 Vue Next 与 tdesign-common（`packages/common/style/web`）。实现留在 `packages/tdesign_flutter_multi_desktop` 与 `packages/tdesign_flutter_multi_core` 的 Token。

[ADR-002](../085-Desktop-architecture-baseline/spec.md) 与 [ADR-006](../085-Desktop-architecture-baseline/spec.md) 继续有效：语义对齐 Vue / tdesign-common，Dart API 保持 Dart 习惯，不照搬 Vue 签名，不复用 Vue 运行时。Desktop 包保持 `0.x`。不修改 Mobile 组件（`tdesign-component` / `package:tdesign_flutter`）。

## 背景与目标

Phase 0 已落地 Button、Input、Select、Form、Pagination、Tabs、Menu、Table 的骨架。本 Spec 冻结这些组件要补的 P0 能力，以及 Button 主题色和 Input / Form 状态色所读的 Token。

本阶段只生成状态色并写明契约。组件 UI、Gallery 与 widget 测试由后续实现按本文件落地。

## 范围与非目标

涉及：

- light / dark 状态色阶进入 `TDesignTokens`，由现有 `tools/token_codegen` + `css2token` 生成。
- Desktop Button、Input、Select、Form、Pagination、Tabs、Menu、Table 的公开 API 与交互契约。

本阶段范围外（后续实现也保持在外，除非修订本 Spec）：

- Input：Vue `maxcharacter`（中文算 2）。字数只用 Dart `String.length`。
- Select：虚拟滚动。
- Tabs：没有 `small`。
- Table：虚拟滚动、树懒加载。
- 新组件，以及把 Mobile 交互搬进 Desktop。
- 改写 `package:tdesign_flutter` 的 `TButtonVariant`（fill / outline / text / ghost）。那是另一个类型。`test/migration_consumer` 引用的是 Mobile API，不随 Desktop 枚举迁移。

## 状态色 Token

生成文件：`packages/tdesign_flutter_multi_core/lib/src/token/tdesign_tokens.g.dart`。

重新生成（在 `tools/token_codegen`）：

```bash
dart run bin/generate.dart --demo
```

该文件由工具写出。后续改色只改 `tools/token_codegen/lib/desktop_token_css.dart` 后再跑上面的命令，不手改生成文件。

组件按下面的字符串 key 取 `#RRGGBB` 或 `#AARRGGBB`。语义别名同时在 `colors` 里有解析后的色值，在 `refs` 里指向色阶叶子。例如 `colors['errorColor']` 与 `colors['errorColor6']` 相同，`refs['errorColor']` 为 `errorColor6`。

取色入口是 `TDesignTokenScope`。没有 scope 时 `TDesignTokenScope.of` 返回 `TDesignTokens.light`，已有调用点颜色不变。子树可以提供 `TDesignTokens.dark`。这不是应用级亮暗切换。Button、Input、Menu 的状态色、品牌色、文字色和容器色读这个 scope。Menu `theme: dark` 在菜单子树内提供 `TDesignTokens.dark`。同一 key 在 `.light` 与 `.dark` 上都存在。

### 保留的 PoC key

这些值保持 Phase 0 已发布的结果，本阶段不改写：

| key | light | dark |
| --- | --- | --- |
| `brandColor7` / `brandColor` | `#0052D9` | `#4582E6` |
| `bgColorContainer` | `#FFFFFF` | `#242424` |
| `textColorPrimary` | `#000000` | `#FFFFFF` |
| `radiusDefault` | `3.0` | `3.0` |

深色 `brandColor7` 仍是 PoC 的 `#4582E6`。tdesign-common 深色 `--td-brand-color-7` 是 `#2667D4`，可操作品牌色 `--td-brand-color` 指向 `--td-brand-color-8`（`#4582E6`）。本阶段不把 PoC 的 `brandColor7` 改成 `#2667D4`。

### 功能色基色

来自 `_light.less` / `_dark.less` 的 `--td-error-color-6`、`--td-warning-color-5`、`--td-success-color-5`。别名 `--td-error-color` 等由 css2token 写成 `errorColor` / `warningColor` / `successColor`。

| 读 `colors` 的 key | light | dark |
| --- | --- | --- |
| `errorColor6`、`errorColor` | `#D54941` | `#C64751` |
| `warningColor5`、`warningColor` | `#E37318` | `#CF6E2D` |
| `successColor5`、`successColor` | `#2BA471` | `#059465` |

Input / Form 的 success、warning、error 边框只用这三组基色。

### 浅底、disabled、CSS hover 落点

色阶 1–10 全部生成。浅底、disabled、focus、active 使用 css2token 已有名字。tdesign-common 的 `--td-*-color-hover` 会写进 CSS 源，但 css2token 不映射 `errorColorHover`、`warningColorHover`、`successColorHover`。`--td-*-color-light-hover` 映射为 `*ColorLightActive`，没有 `*ColorLightHover`。

实现时只使用下表的 key。

| 角色 | `colors` key | `refs` 叶子 | light | dark |
| --- | --- | --- | --- | --- |
| error 浅底 | `errorColorLight` 或 `errorColor1` | `errorColor1` | `#FFF0ED` | `#472324` |
| error 浅底 hover / focus | `errorColorLightActive`、`errorColorFocus` 或 `errorColor2` | `errorColor2` | `#FFD8D2` | `#5E2A2D` |
| error disabled 实色 | `errorColorDisabled` 或 `errorColor3` | `errorColor3` | `#FFB9B0` | `#703439` |
| error 的 CSS hover 落点 | `errorColor5` | 色阶本身 | `#F6685D` | `#A03F46` |
| error active | `errorColorActive` 或 `errorColor7` | `errorColor7` | `#AD352F` | `#DE6670` |
| warning 浅底 | `warningColorLight` 或 `warningColor1` | `warningColor1` | `#FFF1E9` | `#4F2A1D` |
| warning 浅底 hover / focus | `warningColorLightActive`、`warningColorFocus` 或 `warningColor2` | `warningColor2` | `#FFD9C2` | `#582F21` |
| warning disabled 实色 | `warningColorDisabled` 或 `warningColor3` | `warningColor3` | `#FFB98C` | `#733C23` |
| warning 的 CSS hover 落点 | `warningColor4` | 色阶本身 | `#FA9550` | `#A75D2B` |
| warning active | `warningColorActive` 或 `warningColor6` | `warningColor6` | `#BE5A00` | `#DC7633` |
| success 浅底 | `successColorLight` 或 `successColor1` | `successColor1` | `#E3F9E9` | `#193A2A` |
| success 浅底 hover / focus | `successColorLightActive`、`successColorFocus` 或 `successColor2` | `successColor2` | `#C6F3D7` | `#1A4230` |
| success disabled 实色 | `successColorDisabled` 或 `successColor3` | `successColor3` | `#92DAB2` | `#17533D` |
| success 的 CSS hover 落点 | `successColor4` | 色阶本身 | `#56C08D` | `#0D7A55` |
| success active | `successColorActive` 或 `successColor6` | `successColor6` | `#008858` | `#43AF8A` |

placeholder 使用已有名字 `textColorPlaceholder`（`--td-text-color-placeholder`）：

| key | light | dark | `refs` 叶子 |
| --- | --- | --- | --- |
| `textColorPlaceholder` | `#66000000` | `#59FFFFFF` | light `fontGray3`，dark `fontWhite3` |

`fontGray3` / `fontWhite3` 是叶子，组件读 `textColorPlaceholder`。

### 色阶全表

light：

| 阶 | warning | error | success |
| --- | --- | --- | --- |
| 1 | `#FFF1E9` | `#FFF0ED` | `#E3F9E9` |
| 2 | `#FFD9C2` | `#FFD8D2` | `#C6F3D7` |
| 3 | `#FFB98C` | `#FFB9B0` | `#92DAB2` |
| 4 | `#FA9550` | `#FF9285` | `#56C08D` |
| 5 | `#E37318` | `#F6685D` | `#2BA471` |
| 6 | `#BE5A00` | `#D54941` | `#008858` |
| 7 | `#954500` | `#AD352F` | `#006C45` |
| 8 | `#713300` | `#881F1C` | `#005334` |
| 9 | `#532300` | `#68070A` | `#003B23` |
| 10 | `#3B1700` | `#490002` | `#002515` |

dark：

| 阶 | warning | error | success |
| --- | --- | --- | --- |
| 1 | `#4F2A1D` | `#472324` | `#193A2A` |
| 2 | `#582F21` | `#5E2A2D` | `#1A4230` |
| 3 | `#733C23` | `#703439` | `#17533D` |
| 4 | `#A75D2B` | `#83383E` | `#0D7A55` |
| 5 | `#CF6E2D` | `#A03F46` | `#059465` |
| 6 | `#DC7633` | `#C64751` | `#43AF8A` |
| 7 | `#E8935C` | `#DE6670` | `#46BF96` |
| 8 | `#ECBF91` | `#EC888E` | `#80D2B6` |
| 9 | `#EED7BF` | `#EDB1B6` | `#B4E1D3` |
| 10 | `#F3E9DC` | `#EECED0` | `#DEEDE8` |

key 形式为 `warningColor1` … `warningColor10`，error、success 同样。

### 填充按钮的 hover / disabled

primary / danger / warning / success 的填充色交互沿用 `t_button.dart` 里现有品牌算法，作用在主题基色上。运算结果不写入 Token，也不新增 `*Hover` key。

基色：

| theme | `colors` key |
| --- | --- |
| `primary` | `brandColor7` |
| `danger` | `errorColor6` |
| `warning` | `warningColor5` |
| `success` | `successColor5` |

对基色：

- hovered：`Color.lerp(base, const Color(0xFFFFFFFF), 0.08)`
- pressed：`Color.lerp(base, const Color(0xFF000000), 0.12)`
- disabled 与 loading：`base.withValues(alpha: 0.4)`
- normal、focused、selected：基色

浅底场景（例如需要淡底而不是 8% 混白）读 `*ColorLight` / `*ColorLightActive`，不用混白结果代替 `errorColor1`。

`defaultTheme` 的填充用 `bgColorContainer`，文字用 `textColorPrimary`。hover 填充用 `bgColorContainerHover`，不用混白。primary / danger / warning / success 的 hover、pressed、disabled 仍用上面的混白、混黑和透明度。

| key | CSS | light | dark | `refs` |
| --- | --- | --- | --- | --- |
| `bgColorContainerHover` | `--td-bg-color-container-hover` | `#F3F3F3`（gray-color-1） | `#2C2C2C`（gray-color-12） | 自身。CSS 写解析后的色值，不另生成灰色阶 |
| `textColorAnti` | `--td-text-color-anti` | `#FFFFFF` | `#FFFFFF` | 自身 |

css2token 语义表有 `textColorAnti`，没有 `bgColorContainerHover`。生成时 CSS 仍写这两个变量；`tools/token_codegen` 把未映射的 `--td-bg-color-container-hover` 记成 `bgColorContainerHover`。不新增 `grayColor13`：dark `bgColorContainer` 已经是 `#242424`。

## Button

文件：`packages/tdesign_flutter_multi_desktop/lib/src/basic/t_button.dart`。

现在的 `TButtonVariant` 把主题和形式放在一个枚举里。拆成两轴，并补形状与幽灵：

```dart
enum TButtonTheme { defaultTheme, primary, danger, warning, success }

enum TButtonVariant { base, outline, dashed, text }

enum TButtonShape { rectangle, square, round, circle }
```

`defaultTheme` 这个名字避开 Dart 关键字 `default`。

构造默认值：`theme: TButtonTheme.defaultTheme`，`variant: TButtonVariant.base`，`ghost: false`，`shape: TButtonShape.rectangle`。与 Vue 的 default + base 对齐。当前无参 `TButton` 看起来是品牌填充，迁移时要显式写成 `theme: TButtonTheme.primary`。

| 参数 | 契约 |
| --- | --- |
| `ghost` | 背景透明，内容用主题色。`outline` / `dashed` 同时画主题色描边。 |
| `block` | 宽度撑满父级；`square` / `circle` 忽略。 |
| `icon` / `suffix` | 可选前置 / 后置图标，读按钮前景色。 |
| `href` | 可选链接元数据。Flutter 无 `<a>`；不自动跳转。非空时 `Semantics.link` 为 true，并把 URL 写入 `SemanticsProperties.linkUrl`（若运行时支持）/ `tooltip`。真正导航仍由调用方在 `onPressed` 完成。 |
| `outline` / `dashed` | 1px 描边。`dashed` 为虚线。`base` + `primary` 保持品牌填充。 |
| `shape` | `rectangle` 用 `radii['radiusDefault']`。`square` / `circle` 的宽等于该尺寸高度：small 24、medium 32、large 40（`--td-comp-size-xs` / `m` / `xl`）。`round` 与 `circle` 的圆角为高度的一半。 |

主题色：

| theme | 填充或描边 / 文字 |
| --- | --- |
| `defaultTheme` | 填充 `bgColorContainer`，文字与描边 `textColorPrimary` |
| `primary` | `brandColor7` |
| `danger` | `errorColor6` |
| `warning` | `warningColor5` |
| `success` | `successColor5` |

旧枚举在本仓库调用点一次改完。`TButtonVariant.primary` / `secondary` 删除。

| 现状 | 迁移 |
| --- | --- |
| 未写 variant，或 `TButtonVariant.primary` | `theme: TButtonTheme.primary`，`variant: TButtonVariant.base` |
| `TButtonVariant.secondary` | `theme: TButtonTheme.defaultTheme`，`variant: TButtonVariant.base` |
| `TButtonVariant.outline` | `variant: TButtonVariant.outline`，theme 保持 `defaultTheme` |
| `TButtonVariant.text` | `variant: TButtonVariant.text`，theme 保持 `defaultTheme` |

调用点：`examples/desktop_gallery`，`t_pagination.dart`，`t_input_number.dart`，`t_dialog.dart`。Dialog 的确认按钮是无参 `TButton`，迁移为 `theme: primary`。

Gallery 的 Button 页补主题、虚框、幽灵、形状，对应 Vue 的 `theme` / `ghost` / `shape` / `base` 示例。

## Input

文件：`packages/tdesign_flutter_multi_desktop/lib/src/form/t_input.dart`。左右内边距已按 Vue 补过，本能力不改内边距。

```dart
enum TInputStatus { normal, success, warning, error }
```

| 参数 | 契约 |
| --- | --- |
| `clearable` | 有内容且 `enabled` 时显示清空。点击调用 `onChanged('')`。 |
| `obscureText` | 为 true 时遮罩内容，后缀切换可见性（对应 Vue `type=password`）。切换只改本地可见性，不改字段值。 |
| `status` | 默认 `normal`。只改边框色，不改高度。success / warning / error 分别用 `successColor5`、`warningColor5`、`errorColor6`。 |
| `maxLength` + `showLimit` | `maxLength` 按 Dart `String.length` 限制输入，超出的变更不写入。`showLimit` 为 true 且 `maxLength != null` 时在右侧显示 `当前/上限`。不做 `maxcharacter`。 |
| `placeholder` | 已有参数。值为 null 或空字符串时画出来，颜色为 `textColorPlaceholder`。有内容时不画。 |

## Select

文件：`packages/tdesign_flutter_multi_desktop/lib/src/form/t_select.dart`。

单选 `value` / `onChanged` 保持不变。`multiple` 为 false 时忽略 `values` / `onValuesChanged`。`multiple` 为 true 时以 `values` / `onValuesChanged` 为准，忽略 `value` / `onChanged`。

| 参数 | 契约 |
| --- | --- |
| `multiple` + `values` + `onValuesChanged` | 触发器里用已有 `TTag` 展示已选项。点标签关闭从列表移除该项并回调。 |
| `filterable` | 面板顶部输入。默认不区分大小写，对 `labelBuilder` 的结果做子串匹配。查询为空时展示全部选项。 |
| `clearable` | 有值时显示清空。单选回调 `onChanged(null)`，多选回调 `onValuesChanged` 空列表。 |
| `optionDisabled` | 返回 true 的选项不可点选，灰色展示。默认全部可选。 |
| `optionGroup` | 返回非空字符串时，在该选项前插入分组标题（相邻同名合并为一个标题）。标题不可点。 |
| `creatable` + `onCreate` | 需配合 `filterable`。查询非空且无标签完全匹配（忽略大小写）时，面板出现「创建 "query"」行；点选调用 `onCreate(query)`，由调用方追加选项并回写受控值。 |
| `onSearch` | 需配合 `filterable`。查询变化时回调；有 `onSearch` 时组件不做本地子串过滤，选项列表完全由调用方提供（远程搜索）。 |

## Form

文件：`packages/tdesign_flutter_multi_desktop/lib/src/form/t_form.dart`。

现有 `errorText` 与标签上的 `required` 星号保留。星号只影响展示，不自动变成一条校验规则。`TFormFieldValidator` 继续作为自定义校验的类型：`String? Function(Object? value)`，返回 null 表示通过。

```dart
enum TFormTrigger { change, blur, submit }

class TFormRule {
  const TFormRule({
    this.required = false,
    this.min,
    this.max,
    this.pattern,
    this.validator,
    this.message,
    this.trigger = const {TFormTrigger.change},
  });

  const TFormRule.email({this.message, this.trigger = const {TFormTrigger.change}});
  const TFormRule.url({this.message, this.trigger = const {TFormTrigger.change}});
  const TFormRule.telnumber({this.message, this.trigger = const {TFormTrigger.change}});
}

class TFormController {
  Map<String, Object?> get values;
  bool validate();
  void submit();
}
```

`TForm` 接收 `controller`。`TFormItem` 增加 `name` 与 `rules`。有 `name` 的项向子树提供 `TFormFieldScope`。Input / Select 在 change、blur 时把当前值交给 scope。scope 按触发器跑该字段的规则。没有名字的项不参与校验。

规则：

- 提交（`controller.submit` / `validate`）跑全部规则，忽略 trigger 过滤。`change` 只跑包含 `change` 的规则，`blur` 同样。
- 值为空（null、空字符串、空 Iterable）且该条不是 `required` 时，该条通过。`0` 与 `false` 不算空。
- 同一字段按 `rules` 顺序，采用第一条失败。失败文案写回该项；有文案时优先于外部 `errorText`。
- 失败时 scope 把 `TInputStatus.error` 提供给包在里面的 Input。Input 自己的 `status` 不是 `normal` 时，显式 status 优先。
- `required` 失败用 `message`，缺省 `不能为空`。
- `min` / `max`：`num` 按数值比较；`String` 按 `String.length`（一个中文算 1）。缺省文案为 `不能小于最小值` / `不能大于最大值`。
- `pattern` 是 `RegExp`，对字符串全文匹配，并在每次测试前把 `lastIndex` 置 0。缺省文案 `格式不正确`。
- `validator` 返回非空字符串时，用该字符串作为文案，不再使用 `message`。
- `email` / `url` / `telnumber` 只做这三个正则，不引入 validator.js：
  - email：`^[^@\s]+@[^@\s]+\.[^@\s]+$`
  - url：`^(https?|ftp)://\S+$`，大小写不敏感
  - telnumber：`^1[3-9]\d{9}$`（与 Vue `telnumber` 相同）
  - 缺省文案依次为 `请输入正确的邮箱`、`请输入正确的链接`、`请输入正确的手机号码`。
- `submit()` 在 `validate()` 为 true 时调用 `TForm.onSubmit`。`onSubmit` 仍是 `VoidCallback?`。校验失败时不调用。

Gallery 的 Form 页改为规则示例，不再手写 `errorText`。

## Pagination、Tabs、Menu

彼此独立。

Pagination（`t_pagination.dart`）：保留 1-based 的 `current` / `onChanged` 与上一页、下一页。

- 页码：总页数 ≤ 7 时全部展示。大于 7 时始终展示第 1 页和最后一页，以及当前页和左右各 1 页。被跳过的区间用一个不可点击的省略号。靠近首尾时不重复页码，也不多画省略号。
- `showJumper`：输入页码后把夹紧到 `1…总页数` 的值交给 `onChanged`。
- `pageSizeOptions` + `onPageSizeChanged`：展示每页条数。组件不自行改 `current`，由调用方更新受控参数。
- `theme`：`defaultTheme`（页码按钮）或 `simple`（仅上一页 / 下一页 + `当前/总页`）。对齐 Vue `theme`。

Tabs（`t_tabs.dart`）：

```dart
enum TTabPlacement { top, bottom, left, right }
enum TTabsSize { medium, large }
enum TTabsTheme { normal, card }
```

默认 `top`、`medium`、`normal`。不用 `TComponentSize`，避免带上 small。`normal` 指示条跟选中项，横向 placement 用横条，纵向 placement 用竖条。`card` 无底轨与指示条；每项带描边，选中项白底 + 品牌字色，未选中灰底。

Menu（`t_menu.dart`）：

```dart
enum TMenuTheme { light, dark }
enum TMenuAxis { vertical, horizontal }
```

- `TMenuItem.icon`：可选 `Widget`。
- `theme` 默认 `light`。`dark` 是菜单自己的暗色底，不是把应用切到暗色。light 从当前 scope 读 `bgColorContainer`（缺省 light `#FFFFFF`）和 `textColorPrimary`。`dark` 在菜单子树提供 `TDesignTokens.dark`：底是 dark `bgColorContainer`（`#242424`，即 `--td-gray-color-13`），文字是 dark `textColorAnti`（`#FFFFFF`）。不另生成 `grayColor13`。
- `axis` 默认 `vertical`（保持现在的缩进子项）。`horizontal` 做顶栏，子项用已有 Overlay 弹出，不用左侧缩进。

## Table

文件：`packages/tdesign_flutter_multi_desktop/lib/src/data/t_table.dart`。放在 Select 的筛选弹层可用之后。

```dart
enum TTableFixed { left, right }
enum TTableFilterType { single, multiple, input }
```

- 列上的 `TTableFilter`：`single` / `multiple` 带选项，`input` 为文本。筛选值受控，建议 `Map<String, Object?>`，key 为列 id。single 存选项值，multiple 存列表，input 存字符串。面板复用 Overlay。确认后调用 `onFilterChanged`。关闭面板或取消不改当前值。
- `TTableColumn.fixed`：`left` / `right` / null。null 随内容滚动。表格可横向滚动，固定列叠在滚动内容两侧。
- `maxHeight`：表体超出后纵向滚动，表头留在表格顶部（对齐 Vue `maxHeight` 下的表头固定，不是窗口级 Affix）。与左右固定列同时开启时，仅约束整体高度并整体滚动，不做分栏同步吸顶。
- `resizable`（默认 `false`）+ 受控 `columnWidths`（`Map<String, double>`，key 为列 id）+ `onColumnWidthsChanged`：表头右缘拖拽改列宽。有效宽度 = `columnWidths[id] ?? column.width ?? 120`，夹在 80–600。拖拽过程持续回调完整覆盖 map。列上 `TTableColumn.resizable == false` 禁止该列；未设时跟随表级 `resizable`。不做相邻列互挤、多级表头叶子联动。
- `TTableColumn.editable`（默认 `false`）+ `onCellEdited(row, columnId, text)`：双击单元格进入行内文本编辑；回车提交并回调，Esc / 失焦取消。不做自定义编辑组件、整行编辑态、校验规则。
- `dragSort`（默认 `false`）+ `onDragSort(oldIndex, newIndex)`：扁平表行前出现拖拽手柄；拖到目标行松手后回调索引（对齐 Vue `dragSort=row` 的意图，索引相对当前可见扁平行）。树形表、固定列场景不做行拖拽。
- 树：`childrenOf` 返回子行；未提供时保持扁平表。`expandedKeys` 受控，元素是 `rowKey`。行前有展开图标，子行按深度缩进。只支持内存中的树。回调为 null 时不自行展开。

## 关键决策与取舍

| 决策 | 原因 |
| --- | --- |
| 状态色走 css2token 已有 key，不新增 `errorColorHover` 等 | tdesign-common 的功能色 hover 变量没有对应的 Flutter 名字；落点已经是 `errorColor5`、`warningColor4`、`successColor4`。`light-hover` 在 css2token 里叫 `*ColorLightActive`。容器 hover 是另一个变量，见下一行。 |
| `defaultTheme` hover 读 `bgColorContainerHover` | 混白对 light 的白底几乎没有变化。色值是 `--td-bg-color-container-hover` 的解析结果。css2token 不映射这个名字，由 token codegen 补上。 |
| 暗色菜单文字读 `textColorAnti` | css2token 已有这个名字。底色继续用 dark `bgColorContainer`，不平行再造 `grayColor13`。 |
| Button / Input / Menu 经 `TDesignTokenScope` 取色 | 缺省 light，现有调用点不变。菜单暗色只把 dark token set 提供给自己的子树。 |
| 填充按钮 hover / disabled 用现有混白与透明度算法 | 与当前品牌按钮一致。primary 只有 `brandColor7`，没有品牌色阶；状态色若改读色阶 hover，会和 primary 的反馈不一致。浅底另读 `*ColorLight`。 |
| Button 默认 theme 改为 `defaultTheme` | 对齐 Vue，也让现有 `outline` / `text` 调用点在只改枚举名后仍是中性样式。今天的无参品牌按钮在迁移时显式标 `primary`。 |
| 字数与 min/max 用 `String.length` | 计划明确不做 `maxcharacter`。 |
| 校验只做 email / url / telnumber 三个正则 | 不引入 validator.js。telnumber 与 Vue 相同。 |
| Desktop `0.x` 内删除 `TButtonVariant.primary` / `secondary` | 调用点都在本仓库，一次改完。Mobile 的同名枚举不动。 |

## 兼容性与迁移

- 对 Desktop 调用方，删除 `TButtonVariant.primary` / `secondary` 是破坏性变更。包版本仍是 `0.x`，按上表改调用点，不单独做 Mobile 式废弃周期。
- 新增参数都有默认值：`clearable`、`obscureText`、`multiple`、`filterable`、`showJumper`、`ghost` 默认关闭；`status` 默认 `normal`；Tabs / Menu 默认保持现在的顶栏方向与纵向菜单。
- `TForm.onSubmit` 从「未接入」变为「校验通过后调用」。没有 `controller` 且没有 `rules` 时，不改变现有「不会自动提交」的行为；提交入口是 `controller.submit()`。
- Core 增加生成 Token 的 key，并增加 `TDesignTokenScope`。不改 Mobile 组件源码。`TDesignTokens` 仍是同一类，旧 key 的色值不变。不包 scope 时 Desktop 颜色与以前的 light 相同。
- `defaultTheme` 填充按钮的 hover 底改为 `bgColorContainerHover`（light `#F3F3F3`，dark `#2C2C2C`）。其余 theme 的 hover / pressed / disabled 算法不变。构造参数不变。
- Flutter `3.32.0` 与当前 stable 都能用的 API：`Color.lerp`、`Color.withValues`。按钮算法继续用 `withValues`，与现有 `t_button.dart` 相同。

## 验收标准

标准描述预期行为，不表示已经执行。

| 标准 | 可观察的预期 | 验证方式与边界 |
| --- | --- | --- |
| 状态色来自 codegen | light / dark 的 `errorColor6`、`warningColor5`、`successColor5` 以及上表浅底、disabled、色阶 key 能从 `TDesignTokens.*.colors` 读到；生成文件与 `dart run bin/generate.dart --demo` 一致 | `tools/token_codegen` 的 `dart test`；`tdesign_flutter_multi_core` 的 `flutter analyze --fatal-infos` |
| 旧 key 仍在 | `brandColor7`、`bgColorContainer`、`textColorPrimary`、`radiusDefault` 的 PoC 色值不变 | 同上 |
| 不发明功能色 hover 名 | 生成结果中没有 `errorColorHover`、`warningColorHover`、`successColorHover`、`*ColorLightHover`，也没有 `grayColor13` | token 测试 |
| 容器 hover 与反色文字 | `bgColorContainerHover` light `#F3F3F3`、dark `#2C2C2C`；`textColorAnti` 两边 `#FFFFFF`。`defaultTheme` 填充 hover 用容器 hover；暗色菜单文字用 dark `textColorAnti` | token 测试；desktop 的 button / menu widget 测试 |
| 取色 scope | 无 scope 时 Button / Input / Menu 仍是 light。暗色菜单子树读 dark，子组件跟着这条 scope | desktop widget 测试 |
| 组件契约 | 上文 API 与非目标在后续实现中保持；每个能力一条 widget 测试；Gallery 对应页有 Vue 同名示例区块 | `tdesign_flutter_multi_desktop` 与 `examples/desktop_gallery` 的 `flutter analyze --fatal-infos` 和 `flutter test`。不做 Vue 截图像素对比 |
| Mobile 隔离 | `tdesign-component` 组件实现无行为差异 | diff |
