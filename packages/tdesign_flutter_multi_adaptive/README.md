# tdesign_flutter_multi_adaptive

Adaptive host for TDesign Flutter.

**0.1.0** (tag `desktop-v0.1.0`). Path dependency only (`publish_to: none`).

`TDesignApp` resolves `mobile` or `desktop` from window size and input
capability (`AdaptiveContext`), not from `Platform.isXxx`. The result is
available on `AdaptiveScope`. This version does not swap Mobile and Desktop
widgets for you.
