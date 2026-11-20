# Desktop Phase 4 Hardening — 实现组织

## 影响范围

- Spec：`specs/engineering/095-Desktop-phase4-hardening/`
- 代码：`packages/tdesign_flutter_desktop`（优先 `t_table.dart`、`t_select.dart`）
- 测试：既有 table / select widget 测试；必要时补大行数滚动
- Gallery：无强制新页；行为不回归即可
- 索引：`specs/engineering/README.md`、`085` Phase 4 交叉引用

## 落地顺序

1. 写入 Spec / plan / tasks 与索引。
2. Table：typedef + TokenScope + `ListView.builder`。
3. Select：选项扁平行 + `ListView.builder`。
4. analyze + test（desktop、gallery）。

## 验证

```bash
# packages/tdesign_flutter_desktop
flutter analyze --fatal-infos
flutter test

# examples/desktop_gallery
flutter analyze --fatal-infos
```

Flutter SDK：`3.32.0` 与当前 stable 均需可用 API（`ListView.builder` / `itemExtent`）。
