/// TDesign Flutter Desktop / Web components.
///
/// Spec source: TDesign Vue Next / tdesign-common.
/// Implementation: Flutter-native widgets (ADR-002 / ADR-003).
///
/// Does not re-export [tdesign_flutter_multi_core]. Import Core separately for
/// tokens, overlay, interaction, and size types (Phase 4 / Spec 095).
library tdesign_flutter_multi_desktop;

export 'src/basic/t_badge.dart';
export 'src/basic/t_button.dart';
export 'src/basic/t_divider.dart';
export 'src/basic/t_link.dart';
export 'src/basic/t_space.dart';
export 'src/basic/t_tag.dart';
export 'src/data/t_table.dart';
export 'src/data/t_tree.dart';
export 'src/feedback/t_dialog.dart';
export 'src/feedback/t_dropdown.dart';
export 'src/feedback/t_popover.dart';
export 'src/feedback/t_tooltip.dart';
export 'src/form/t_cascader.dart';
export 'src/form/t_checkbox.dart';
export 'src/form/t_date_picker.dart';
export 'src/form/t_date_range_picker.dart';
export 'src/form/t_form.dart';
export 'src/form/t_input.dart';
export 'src/form/t_input_number.dart';
export 'src/form/t_radio.dart';
export 'src/form/t_select.dart';
export 'src/form/t_switch.dart';
export 'src/form/t_textarea.dart';
export 'src/form/t_time_picker.dart';
export 'src/form/t_time_range_picker.dart';
export 'src/form/t_tree_select.dart';
export 'src/form/t_upload.dart';
export 'src/navigation/t_breadcrumb.dart';
export 'src/navigation/t_menu.dart';
export 'src/navigation/t_pagination.dart';
export 'src/navigation/t_tabs.dart';
