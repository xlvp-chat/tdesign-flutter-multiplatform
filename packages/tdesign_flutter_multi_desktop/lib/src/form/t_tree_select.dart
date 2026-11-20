import 'package:flutter/widgets.dart';
import 'package:tdesign_flutter_multi_core/tdesign_flutter_multi_core.dart';

import '../data/t_tree.dart';
import '../token/t_token_color.dart';
import '_popup_label_field.dart';
import '_popup_shell.dart';

/// Desktop tree select.
///
/// Spec source: local tdesign-vue-next `TreeSelect`. The popup reuses [TTree].
/// [multiple] checks leaves and keeps the popup open. [filterable] filters
/// node labels.
class TTreeSelect extends StatefulWidget {
  const TTreeSelect({
    super.key,
    required this.items,
    this.value,
    this.onChanged,
    this.multiple = false,
    this.values,
    this.onValuesChanged,
    this.filterable = false,
    this.placeholder = '请选择',
    this.clearable = false,
    this.enabled = true,
  });

  final List<TTreeNode> items;
  final String? value;
  final ValueChanged<String?>? onChanged;
  final bool multiple;
  final List<String>? values;
  final ValueChanged<List<String>>? onValuesChanged;
  final bool filterable;
  final String placeholder;
  final bool clearable;
  final bool enabled;

  @override
  State<TTreeSelect> createState() => _TTreeSelectState();
}

class _TTreeSelectState extends State<TTreeSelect> {
  var _open = false;
  var _expanded = <String>{};
  var _query = '';
  late final TextEditingController _filter;
  final _filterFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _expanded = _ancestorsOf(widget.value);
    _filter = TextEditingController();
  }

  @override
  void dispose() {
    _filter.dispose();
    _filterFocus.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant TTreeSelect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value || oldWidget.items != widget.items) {
      _expanded = {..._expanded, ..._ancestorsOf(widget.value)};
    }
  }

  Set<String> _ancestorsOf(String? value) {
    if (value == null) return {};
    final parents = <String>{};
    bool walk(List<TTreeNode> nodes, List<String> trail) {
      for (final node in nodes) {
        if (node.value == value) {
          parents.addAll(trail);
          return true;
        }
        if (walk(node.children, [...trail, node.value])) return true;
      }
      return false;
    }

    walk(widget.items, const []);
    return parents;
  }

  TTreeNode? _nodeOf(String? value) {
    if (value == null) return null;
    TTreeNode? walk(List<TTreeNode> nodes) {
      for (final node in nodes) {
        if (node.value == value) return node;
        final found = walk(node.children);
        if (found != null) return found;
      }
      return null;
    }

    return walk(widget.items);
  }

  void _setOpen(bool value) {
    if (!widget.enabled && value) return;
    setState(() {
      _open = value;
      if (value) {
        _expanded = {..._expanded, ..._ancestorsOf(widget.value)};
      }
    });
  }

  void _pick(String value) {
    widget.onChanged?.call(value);
    _setOpen(false);
  }

  void _toggleChecked(Set<String> keys) {
    widget.onValuesChanged?.call(keys.toList());
  }

  void _clear() {
    if (widget.multiple) {
      widget.onValuesChanged?.call(const []);
    } else {
      widget.onChanged?.call(null);
    }
    _setOpen(false);
  }

  String get _label {
    if (!widget.multiple) {
      return _nodeOf(widget.value)?.label ?? widget.placeholder;
    }
    final values = widget.values ?? const <String>[];
    if (values.isEmpty) return widget.placeholder;
    return values.map((value) => _nodeOf(value)?.label ?? value).join(', ');
  }

  void _activate(Set<String> keys) {
    if (keys.isEmpty) return;
    final value = keys.first;
    final node = _nodeOf(value);
    if (node == null || node.disabled) return;
    _pick(value);
  }

  Widget _popup(TDesignTokenSet tokens) {
    return TPopupShell(
      tokens: tokens,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 280, minWidth: 240),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.filterable) _filterField(tokens),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: TTree(
                  items: widget.items,
                  expandedKeys: _expanded,
                  onExpandedKeysChanged: (value) {
                    setState(() => _expanded = value);
                  },
                  filter: _query.trim().isEmpty ? null : _query,
                  activable: !widget.multiple,
                  checkable: widget.multiple,
                  activedKeys: {
                    if (!widget.multiple && widget.value != null) widget.value!,
                  },
                  checkedKeys: {if (widget.multiple) ...?widget.values},
                  onActivedChanged: widget.multiple ? null : _activate,
                  onCheckedChanged: widget.multiple ? _toggleChecked : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterField(TDesignTokenSet tokens) {
    final brand = tTokenColorOf(tokens, 'brandColor7');
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: SizedBox(
        height: 32,
        child: EditableText(
          key: const ValueKey<String>('TTreeSelect.filter'),
          controller: _filter,
          focusNode: _filterFocus,
          style: TextStyle(
            fontSize: 14,
            color: tTokenColorOf(tokens, 'textColorPrimary'),
          ),
          cursorColor: brand,
          backgroundCursorColor: tTokenColorOf(tokens, 'componentBorder'),
          onChanged: (value) => setState(() => _query = value),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = TDesignTokenScope.of(context);
    final hasValue = widget.multiple
        ? (widget.values?.isNotEmpty ?? false)
        : widget.value != null;
    final muted = !hasValue;
    return TOverlayPortal(
      visible: _open,
      onVisibleChanged: _setOpen,
      options: const TOverlayPortalOptions(
        preferredPlacement: TPlacement.bottomLeft,
      ),
      anchor: TPopupLabelField(
        label: _label,
        muted: muted,
        enabled: widget.enabled,
        clearable: widget.clearable && hasValue,
        onOpen: widget.enabled ? () => _setOpen(!_open) : null,
        onClear: _clear,
        tokens: tokens,
      ),
      overlayBuilder: (context) => _popup(tokens),
    );
  }
}
