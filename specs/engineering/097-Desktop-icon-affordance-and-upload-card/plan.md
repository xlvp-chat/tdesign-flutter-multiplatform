# 097 — 实现组织

## 落地顺序

1. Spec 097 + 索引；092/096 交叉引用。
2. `t_icon.dart` + 尺寸常量；barrel 导出。
3. 高优：Input clear/password、picker 字段 calendar、Pagination chevron。
4. Upload image 卡片模型 + `preview` + Gallery。
5. 中优：caret 16、InputNumber `remove`、Tag/Checkbox 尺寸。
6. 测试与 analyze。

## 验证

```bash
cd packages/tdesign_flutter_multi_desktop && fvm flutter analyze --fatal-infos && fvm flutter test
cd examples/desktop_gallery && fvm flutter analyze --fatal-infos && fvm flutter test
```
