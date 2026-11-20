# Foundation API v0.1

Frozen with package version **0.1.0** (git tag `desktop-v0.1.0`). Not published to pub.dev.

## Packages

- `tdesign_flutter_multi_core` 0.1.0 — Token / Interaction / Overlay
- `tdesign_flutter_multi_desktop` 0.1.0 — Desktop/Web components built on Core
- `tdesign_flutter_multi_adaptive` 0.1.0 — mode signals from window size and input capability

## Frozen for 0.1.0

| API | Notes |
| --- | --- |
| `TComponentState` | Shared interactive states |
| `TComponentSize` | small / medium / large |
| `TInteractiveRegion` | hover / focus / press / ActivateIntent |
| `TOverlayLayer` | named layers (no free z-index) |
| `TOverlayPortal` + `TOverlayPortalOptions` + `TPlacement` | anchored popup; Esc/outside dismiss; focus restore; flip+shift |
| `TDesignTokens` / `TDesignTokenScope` | semantic tokens; light default, dark via scope |
| `TDesignApp` / `AdaptiveResolver` / `TDesignMode` | resolves `mobile` or `desktop`; does not swap widgets |
| Desktop P0 widgets | public surface in `tdesign_flutter_multi_desktop.dart` |

Token colors are checked against `tools/token_codegen/common/web-theme.lock.json`.

## Not in 0.1.0

- Publishing these three packages to pub.dev (`publish_to: none`, path dependencies)
- Adaptive widget swapping between Mobile and Desktop implementations
- Tree lazy-load / drag / virtual scroll
- Cascader and TreeSelect lazy-load; TreeSelect full `treeProps`
- Upload real HTTP, OS drag-and-drop, `image-flow`
- Pixel visual diff against Vue Next
- Web accessibility audit
- Button fill hover/pressed as design tokens (still black/white lerp)
- Frame-time benchmarks and true viewport virtualization
