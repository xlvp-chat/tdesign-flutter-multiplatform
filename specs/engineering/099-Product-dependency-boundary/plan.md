# 099 — 实施方案

## 组织

1. 撤回 098：删除 `AdaptiveButton` 与测试，adaptive `pubspec` 只留 Flutter SDK。
2. 本 Spec 冻结三份 `pubspec` 的允许 / 禁止依赖键。
3. `tools/check_product_deps.dart` 只读检查这些键；GitHub desktop workflow 与 CNB desktop stages 调用同一命令。

## 验证

- `dart tools/check_product_deps.dart`
- `cd packages/tdesign_flutter_multi_adaptive && fvm flutter analyze && fvm flutter test`
