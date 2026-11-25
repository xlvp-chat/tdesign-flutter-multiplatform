import 'package:flutter/widgets.dart';
import 'package:tdesign_flutter_icons/tdesign_flutter_icons.dart';
import 'package:tdesign_flutter_multi_core/tdesign_flutter_multi_core.dart';

import '../token/t_token_color.dart';
import '_popup_label_field.dart';
import '_popup_shell.dart';

/// One option in [TCascader.options].
class TCascaderOption {
  const TCascaderOption({
    required this.value,
    required this.label,
    this.children = const [],
    this.disabled = false,
  });

  final String value;
  final String label;
  final List<TCascaderOption> children;
  final bool disabled;

  bool get isLeaf => children.isEmpty;
}

/// Desktop cascader.
///
/// Spec source: local tdesign-vue-next `Cascader` (`valueType: single`).
/// [value] is the selected option value. [showAllLevels] controls the trigger
/// text. [multiple] uses [values] instead. [checkStrictly] allows selecting a
/// parent. [filterable] searches option paths.
class TCascader extends StatefulWidget {
  const TCascader({
    super.key,
    required this.options,
    this.value,
    this.onChanged,
    this.multiple = false,
    this.values,
    this.onValuesChanged,
    this.checkStrictly = false,
    this.filterable = false,
    this.placeholder = '请选择',
    this.clearable = false,
    this.enabled = true,
    this.showAllLevels = true,
  });

  final List<TCascaderOption> options;
  final String? value;
  final ValueChanged<String?>? onChanged;
  final bool multiple;
  final List<String>? values;
  final ValueChanged<List<String>>? onValuesChanged;
  final bool checkStrictly;
  final bool filterable;
  final String placeholder;
  final bool clearable;
  final bool enabled;
  final bool showAllLevels;

  @override
  State<TCascader> createState() => _TCascaderState();
}

class _TCascaderState extends State<TCascader> {
  var _open = false;
  var _path = <TCascaderOption>[];
  var _query = '';
  late final TextEditingController _filter;
  final _filterFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _path = _pathFor(widget.multiple ? null : widget.value);
    _filter = TextEditingController();
  }

  @override
  void dispose() {
    _filter.dispose();
    _filterFocus.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant TCascader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value ||
        oldWidget.options != widget.options) {
      _path = _pathFor(widget.value);
    }
  }

  List<TCascaderOption> _pathFor(String? leaf) {
    if (leaf == null) return const [];
    List<TCascaderOption>? walk(
      List<TCascaderOption> options,
      List<TCascaderOption> trail,
    ) {
      for (final option in options) {
        final next = [...trail, option];
        if (option.value == leaf) return next;
        final found = walk(option.children, next);
        if (found != null) return found;
      }
      return null;
    }

    return walk(widget.options, const []) ?? const [];
  }

  void _setOpen(bool value) {
    if (!widget.enabled && value) return;
    setState(() {
      _open = value;
      if (value) {
        _path = _pathFor(widget.value);
      }
    });
  }

  bool _selectable(TCascaderOption option) {
    return option.isLeaf || widget.checkStrictly;
  }

  void _choose(TCascaderOption option) {
    if (widget.multiple) {
      final next = <String>[...?widget.values];
      if (next.contains(option.value)) {
        next.remove(option.value);
      } else {
        next.add(option.value);
      }
      widget.onValuesChanged?.call(next);
      return;
    }
    widget.onChanged?.call(option.value);
    _setOpen(false);
  }

  void _pick(TCascaderOption option, int column) {
    if (option.disabled) return;
    setState(() {
      _path = [..._path.take(column), option];
    });
    if (_selectable(option)) _choose(option);
  }

  void _clear() {
    if (widget.multiple) {
      widget.onValuesChanged?.call(const []);
    } else {
      widget.onChanged?.call(null);
    }
    setState(() => _path = const []);
    _setOpen(false);
  }

  String _pathLabel(String value) {
    final path = _pathFor(value);
    if (path.isEmpty) return value;
    if (!widget.showAllLevels) return path.last.label;
    return path.map((option) => option.label).join(' / ');
  }

  String get _label {
    if (widget.multiple) {
      final values = widget.values ?? const <String>[];
      if (values.isEmpty) return widget.placeholder;
      return values.map(_pathLabel).join(', ');
    }
    final path = _pathFor(widget.value);
    if (path.isEmpty) return widget.placeholder;
    if (!widget.showAllLevels) return path.last.label;
    return path.map((option) => option.label).join(' / ');
  }

  List<_CascaderMatch> _matches() {
    final query = _query.trim().toLowerCase();
    final found = <_CascaderMatch>[];
    void walk(List<TCascaderOption> options, List<TCascaderOption> trail) {
      for (final option in options) {
        final next = [...trail, option];
        final text = next.map((item) => item.label).join(' / ');
        if (_selectable(option) &&
            !option.disabled &&
            text.toLowerCase().contains(query)) {
          found.add(_CascaderMatch(option, next.length - 1, text));
        }
        if (option.children.isNotEmpty) walk(option.children, next);
      }
    }

    walk(widget.options, const []);
    return found;
  }

  List<List<TCascaderOption>> get _columns {
    final columns = <List<TCascaderOption>>[widget.options];
    for (final option in _path) {
      if (option.isLeaf) break;
      columns.add(option.children);
    }
    return columns;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = TDesignTokenScope.of(context);
    final selected = widget.multiple
        ? (widget.values ?? const <String>[])
        : <String>[if (widget.value != null) widget.value!];
    final muted = selected.isEmpty;
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
        clearable: widget.clearable && selected.isNotEmpty,
        onOpen: widget.enabled ? () => _setOpen(!_open) : null,
        onClear: _clear,
        tokens: tokens,
      ),
      overlayBuilder: (context) {
        final matches = _query.trim().isEmpty
            ? const <_CascaderMatch>[]
            : _matches();
        return _Panel(
          columns: _columns,
          path: _path,
          tokens: tokens,
          selectedValues: selected,
          filterable: widget.filterable,
          filterController: _filter,
          filterFocus: _filterFocus,
          matches: matches,
          onFilter: (value) => setState(() => _query = value),
          onPick: _pick,
          onMatch: (match) => _choose(match.option),
        );
      },
    );
  }
}

class _CascaderMatch {
  const _CascaderMatch(this.option, this.column, this.label);

  final TCascaderOption option;
  final int column;
  final String label;
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.columns,
    required this.path,
    required this.tokens,
    required this.selectedValues,
    required this.filterable,
    required this.filterController,
    required this.filterFocus,
    required this.matches,
    required this.onFilter,
    required this.onPick,
    required this.onMatch,
  });

  final List<List<TCascaderOption>> columns;
  final List<TCascaderOption> path;
  final TDesignTokenSet tokens;
  final List<String> selectedValues;
  final bool filterable;
  final TextEditingController filterController;
  final FocusNode filterFocus;
  final List<_CascaderMatch> matches;
  final ValueChanged<String> onFilter;
  final void Function(TCascaderOption option, int column) onPick;
  final ValueChanged<_CascaderMatch> onMatch;

  @override
  Widget build(BuildContext context) {
    final brand = tTokenColorOf(tokens, 'brandColor7');
    final hover = tTokenColorOf(tokens, 'bgColorContainerHover');
    final searching = filterController.text.trim().isNotEmpty;
    return TPopupShell(
      tokens: tokens,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (filterable) _filterField(brand),
          if (searching)
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240, maxWidth: 280),
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final match in matches)
                    _OptionRow(
                      option: match.option,
                      label: match.label,
                      selected: selectedValues.contains(match.option.value),
                      brand: brand,
                      hover: hover,
                      tokens: tokens,
                      onTap: () => onMatch(match),
                    ),
                ],
              ),
            )
          else
            _columnsRow(brand, hover),
        ],
      ),
    );
  }

  Widget _filterField(Color brand) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: SizedBox(
        width: 160,
        height: 32,
        child: EditableText(
          key: const ValueKey<String>('TCascader.filter'),
          controller: filterController,
          focusNode: filterFocus,
          style: TextStyle(
            fontSize: 14,
            color: tTokenColorOf(tokens, 'textColorPrimary'),
          ),
          cursorColor: brand,
          backgroundCursorColor: tTokenColorOf(tokens, 'componentBorder'),
          onChanged: onFilter,
        ),
      ),
    );
  }

  Widget _columnsRow(Color brand, Color hover) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < columns.length; i++) ...[
          if (i > 0)
            ColoredBox(
              color: tTokenColorOf(tokens, 'borderLevel1Color'),
              child: const SizedBox(width: 1, height: 240),
            ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 240),
            child: SizedBox(
              width: 160,
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 4),
                shrinkWrap: true,
                children: [
                  for (final option in columns[i])
                    _OptionRow(
                      option: option,
                      selected:
                          selectedValues.contains(option.value) ||
                          (i < path.length && path[i].value == option.value),
                      brand: brand,
                      hover: hover,
                      tokens: tokens,
                      onTap: option.disabled ? null : () => onPick(option, i),
                    ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.option,
    required this.selected,
    required this.brand,
    required this.hover,
    required this.tokens,
    required this.onTap,
    this.label,
  });

  final TCascaderOption option;
  final String? label;
  final bool selected;
  final Color brand;
  final Color hover;
  final TDesignTokenSet tokens;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final placeholder = tTokenColorOf(tokens, 'textColorPlaceholder');
    final primary = tTokenColorOf(tokens, 'textColorPrimary');
    final secondary = tTokenColorOf(tokens, 'textColorSecondary');
    final selectedBg = tTokenColorOf(tokens, 'brandColorLight');
    return TInteractiveRegion(
      enabled: onTap != null,
      onActivate: onTap,
      builder: (context, state) {
        Color? background;
        if (selected) {
          background = selectedBg;
        } else if (state == TComponentState.hovered) {
          background = hover;
        }
        final Color labelColor;
        if (option.disabled) {
          labelColor = placeholder;
        } else if (selected) {
          labelColor = brand;
        } else {
          labelColor = primary;
        }
        return ColoredBox(
          color: background ?? const Color(0x00000000),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label ?? option.label,
                    style: TextStyle(fontSize: 14, color: labelColor),
                  ),
                ),
                if (!option.isLeaf)
                  Icon(TIcons.chevron_right, size: 12, color: secondary),
              ],
            ),
          ),
        );
      },
    );
  }
}
