# Desktop icons — 实现组织

## 影响范围

- Spec：`specs/engineering/096-Desktop-icons-tdesign-flutter-icons/`
- 依赖：`packages/tdesign_flutter_multi_desktop/pubspec.yaml` + barrel 导出
- 组件：Input / Select / Tag / Upload / Checkbox / Cascader / Tree / Table / Pagination / picker 字段 / 日历导航
- Gallery：`basic_pages` / `navigation_pages` / `upload_page`
- 测试：清空 / 展开 / 月导航 / Upload image 等 `find.byIcon`

## 落地顺序

1. Spec + 索引登记。
2. 依赖与 `TIcons` 导出。
3. 替换组件 Unicode affordance；调整 `DateCalendarNavButton`。
4. Gallery Demo + Upload image 区。
5. 测试断言迁移；analyze / test。
6. macOS 目视与证据；按结论微调 IconTheme 尺寸继承。

## 验证

```bash
cd packages/tdesign_flutter_multi_desktop && fvm flutter analyze --fatal-infos && fvm flutter test
cd examples/desktop_gallery && fvm flutter analyze --fatal-infos && fvm flutter test
```

Flutter：`3.32.8`（仓库 `.fvmrc`）与 `>=3.32.0` 兼容。
