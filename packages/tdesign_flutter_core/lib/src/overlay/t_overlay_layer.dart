/// Semantic overlay layers mapped from TDesign Desktop layering.
///
/// Prefer these named layers over arbitrary integer z-index values.
enum TOverlayLayer {
  base,
  dropdown,
  popup,
  drawer,
  dialog,
  toast,
  message,
  notification,
}
