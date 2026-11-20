# Foundation API v0.1 (Phase 1 freeze candidate)

Frozen surface for Desktop/Mobile shared foundation after Phase 0 Go.

## Packages

- `tdesign_flutter_core` — Token / Interaction / Overlay / enums
- `tdesign_flutter_desktop` — Desktop/Web components built on Core
- `tdesign_flutter_adaptive` — capability-based morph selection

## Stable-enough for consumers (0.x)

| API | Notes |
| --- | --- |
| `TComponentState` | Shared interactive states |
| `TComponentSize` | small / medium / large |
| `TInteractiveRegion` | hover / focus / press / ActivateIntent |
| `TOverlayLayer` | named layers (no free z-index) |
| `TOverlayPortal` + `TOverlayPortalOptions` + `TPlacement` | anchored popup; Esc/outside dismiss; focus restore; flip+shift |
| `TDesignTokens` / `TDesignTokenSet` | generated semantic tokens (demo path) |

## Deferred (not frozen)

- Full Adaptive decision thresholds / forced mode API
- Overlay nested stacking / Dialog-in-Select priority escape hatch polish
- Visual Regression pipeline vs Vue Next
- Token CI drift check against locked tdesign-common revision
