# Desktop 图标基元与 Upload 图片卡片

挂在 [085](../085-Desktop-architecture-baseline/spec.md)。修订并扩展 [096](../096-Desktop-icons-tdesign-flutter-icons/spec.md) 与 [092](../092-Desktop-upload/spec.md)。对照本地 `tdesign-vue-next@0ea1919`。ADR-002 / ADR-006 / Desktop `0.x` 仍适用。

## 背景与目标

096 已将 Unicode 换成 `TIcons`，但与 Vue Next 仍有高优先级结构差异：密码显隐、日期触发器、分页翻页、Upload image 卡片模型。本 Spec 引入 **Desktop 自有 `TIcon`**（非移植 Mobile Material Theme 版）与尺寸约定，并把 Upload `theme=image` 收敛为可注入缩略图的卡片语义。

## 范围与非目标

涉及：

- Desktop `TIcon` + 可选 `TIconStyleScope`（只读 Desktop Token / 显式 size/color / 周围 `IconTheme`，**不**依赖 Mobile `TTheme` / Material）。
- 尺寸约定：默认 affordance 16；输入后缀/清空 14–16；Upload 卡片 110、add 32。
- 高优字形：密码 `browse`/`browse_off`；清空优先 `close_circle_filled`；Date 字段 `calendar`；Pagination 翻页 `chevron_left`/`chevron_right`。
- Upload image：注入预览（`preview` / `url`）、hover 预览/删除、状态叠层、`max`/单选隐藏 add。
- Gallery / 测试同步。

不涉及：嵌 Vue 运行时；Desktop 绑定 `file_picker` / 内置 HTTP；像素 Visual Diff；Core 下沉 icons；改 Mobile 组件。

## 最终方案与行为契约

### TIcon

| 契约 | 要求 |
| --- | --- |
| API | `TIcon(IconData, {size, color, semanticLabel})`；可选 `TIcon.fromName`。 |
| 解析顺序 size | 显式 `size` → `TIconStyleScope.size` → 周围 `IconTheme.size` → **16**。 |
| 解析顺序 color | 显式 `color` → `TIconStyleScope.color` → 周围 `IconTheme.color` → Token `textColorPrimary`。 |
| 导出 | barrel 导出 `TIcon` / `TIconStyleScope`；继续导出 `TIcons`。 |
| 与 Mobile | **独立实现**，不得 import `tdesign_flutter` 的 `TIcon`。 |

### 组件 affordance（相对 Vue）

| 位置 | 图标 |
| --- | --- |
| Input clear | `close_circle_filled` |
| Input password | `browse` / `browse_off` |
| Date/Time 字段后缀 | `calendar`（可清空时另有 clear） |
| Select/Cascader 下拉 | `caret_down_small` / `caret_up_small`（目标尺寸 16） |
| Pagination prev/next | `chevron_left` / `chevron_right`（按钮仍可带语义标签） |
| InputNumber row | `remove` / `add` |
| Checkbox | `check` / `minus`（盒 16，图标约 12） |
| Tag close | `close`（约 14） |

### Upload image

| 契约 | 要求 |
| --- | --- |
| 卡片尺寸 | **110×110** |
| 缩略图 | 优先 `TUploadFile.preview`（`ImageProvider`）；否则有 `url` 时用网络图；皆无则 `TIcons.image` 占位 |
| Add | `TIcons.add` 尺寸约 32；达 `max` 或单选已有文件时隐藏 |
| Hover | `waiting`/`success` 可预览（`browse` + 可选 `onPreview`）；`fail` 仅删除；`progress` 无 hover 操作 |
| 状态 | `progress` / `fail` 叠层；成功态可浏览/删除 |
| 文件名 | 默认显示在卡片下方 |
| 非目标保持 | 无内置 HTTP / `file_picker`；保留 `pickFiles` + 可选 `request` |

## 兼容性

Desktop `0.x`：公开组件可改默认图标与 image 布局；`TUploadFile` 新增可选 `preview`；Pagination 视觉由文案改为图标（语义标签保留中文）。

## 验证

desktop / gallery：`analyze --fatal-infos` + `test`；macOS 目视高优页与 Upload image。
