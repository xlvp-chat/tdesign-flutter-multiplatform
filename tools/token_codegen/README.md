# token_codegen

Phase 0 Token PoC for Desktop architecture baseline
(`specs/engineering/085-Desktop-architecture-baseline`).

Converts TDesign CSS via `css2token` into Dart semantic token sources under
`packages/tdesign_flutter_core`.

`--demo` keeps the Phase 0 brand / container / primary text / radius values and
adds the error, warning, and success ramps from tdesign-common
`theme/_light.less` and `theme/_dark.less`. Semantic aliases css2token already
knows (`errorColorLight`, `errorColorDisabled`, `*ColorLightActive`, and the
base `errorColor` / `warningColor` / `successColor`) are copied into `colors`
so components can read them from `TDesignTokens.light` / `.dark`.
`--td-*-color-hover` is not given a new `*ColorHover` name; that step stays on
`errorColor5`, `warningColor4`, or `successColor4`.

```bash
dart pub get
dart test
dart run bin/generate.dart --demo
# or
dart run bin/generate.dart --light light.css --dark dark.css --out out.dart
```

`common/web-theme.lock.json` 是一份 tdesign-vue-next web theme 的修订锁。
`dart test` 要求 demo CSS 解析后与该锁一致。Phase 0 仍保留的差异写在
`test/common_drift_test.dart` 的 `_pocOverrides`。要换 common 修订：

```bash
dart run bin/lock_common.dart --root <tdesign-vue-next>
dart test
```
