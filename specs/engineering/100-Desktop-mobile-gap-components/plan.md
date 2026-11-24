# 100 — 实施方案

组件放在 `packages/tdesign_flutter_multi_desktop/lib/src` 的 basic / data / feedback / navigation，并从包入口导出。Gallery 增加对应页。`vue_reference.lock.json` 为每个新 `source` 写入该 Vue 组件 `_example` 下的全部 `.vue` 文件名。

验证：desktop analyze + test，gallery test。
