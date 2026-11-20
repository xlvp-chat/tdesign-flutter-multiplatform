# Desktop icons — 任务

## 当前工作

- [x] Spec 096 + `specs/engineering/README.md` 索引
- [x] desktop 依赖 `tdesign_flutter_icons ^0.0.7` 并 barrel 导出 `TIcons`
- [x] 组件 Unicode affordance → `Icon(TIcons.…)`；`DateCalendarNavButton.child`
- [x] Gallery Demo 改用 `TIcons`；Upload image 主题 Demo
- [x] desktop / gallery `analyze --fatal-infos` + `test`
- [x] macOS 目视（Button / Select / InputNumber / Tree / Upload close / Menu）
- [x] 目视后优化：Select/Input IconTheme 14；Upload image 以 add 格为触发

## 未决与缺失证据

- [ ] Web 目视
- [ ] macOS 对新 Upload image add 格补截图（逻辑与测试已覆盖）
