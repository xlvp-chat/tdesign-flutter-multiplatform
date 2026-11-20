import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:tdesign_flutter_multi_core/tdesign_flutter_multi_core.dart';

import '../basic/t_tag.dart';
import '../token/t_token_color.dart';
import '_popup_shell.dart';
import 't_form.dart';
import 't_input.dart';

/// Desktop select.
///
/// Single selection uses [value] and [onChanged]. [multiple] switches the
/// control to [values] and [onValuesChanged] and ignores the single-value pair.
/// [filterable] filters the popup by a case-insensitive substring of
/// [labelBuilder]. [clearable] clears a selection to null, or to an empty list
/// when [multiple] is true.
/// [optionDisabled] blocks picking; [optionGroup] inserts section headers.
/// [creatable] with [filterable] shows a create row for a novel query.
class TSelect<T> extends StatefulWidget {
  const TSelect({
    super.key,
    required this.options,
    required this.labelBuilder,
    this.value,
    this.onChanged,
    this.multiple = false,
    this.values,
    this.onValuesChanged,
    this.filterable = false,
    this.clearable = false,
    this.creatable = false,
    this.onCreate,
    this.onSearch,
    this.optionDisabled,
    this.optionGroup,
    this.placeholder,
    this.enabled = true,
  });

  final List<T> options;
  final String Function(T value) labelBuilder;

  /// Selected value when [multiple] is false. Ignored when [multiple] is true.
  final T? value;

  /// Called with the picked value, or null when cleared.
  ///
  /// Ignored when [multiple] is true.
  final ValueChanged<T?>? onChanged;

  /// Shows [values] as tags and keeps the popup open while picking.
  ///
  /// Defaults to false.
  final bool multiple;

  /// Selected values when [multiple] is true. Null is treated as empty.
  ///
  /// Ignored when [multiple] is false.
  final List<T>? values;

  /// Called with the next list after a tag is added, removed, or cleared.
  ///
  /// Ignored when [multiple] is false. Clearing passes an empty list.
  final ValueChanged<List<T>>? onValuesChanged;

  /// Shows a text field at the top of the popup.
  ///
  /// An empty query shows every option. Otherwise the option stays when
  /// [labelBuilder] contains the query, ignoring case. Defaults to false.
  final bool filterable;

  /// Shows a clear control when a value is selected and [enabled] is true.
  ///
  /// Single selection calls [onChanged] with null. Multiple selection calls
  /// [onValuesChanged] with an empty list. Defaults to false.
  final bool clearable;

  /// With [filterable], shows a create row when the query has no exact label
  /// match. Defaults to false.
  final bool creatable;

  /// Called with the trimmed filter query when the create row is activated.
  ///
  /// The caller should append an option and update [value] / [values].
  final ValueChanged<String>? onCreate;

  /// Called when the filter query changes. With a non-null [onSearch], local
  /// substring filtering is skipped and [options] are shown as provided.
  final ValueChanged<String>? onSearch;

  /// When true for an option, that row is grey and cannot be chosen.
  final bool Function(T option)? optionDisabled;

  /// Non-empty group labels insert a header above the option. Adjacent options
  /// with the same label share one header.
  final String? Function(T option)? optionGroup;

  final String? placeholder;
  final bool enabled;

  @override
  State<TSelect<T>> createState() => _TSelectState<T>();
}

class _TSelectState<T> extends State<TSelect<T>> {
  var _open = false;
  var _query = '';
  var _suppressActivate = false;
  VoidCallback? _armed;
  var _seenField = false;
  var _resetGeneration = -1;
  var _hasPending = false;
  Object? _pending;
  late final FocusNode _listFocus;
  late final TextEditingController _filterController;

  @override
  void initState() {
    super.initState();
    _listFocus = FocusNode();
    _filterController = TextEditingController();
  }

  @override
  void dispose() {
    _listFocus.dispose();
    _filterController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncField(fromDependency: true);
  }

  @override
  void didUpdateWidget(covariant TSelect<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncField(fromDependency: false);
  }

  bool get _showClear {
    if (!widget.clearable || !widget.enabled) return false;
    if (widget.multiple) return widget.values?.isNotEmpty ?? false;
    return widget.value != null;
  }

  bool _isSelected(T option) {
    if (widget.multiple) return widget.values?.contains(option) ?? false;
    return widget.value == option;
  }

  List<T> get _visibleOptions {
    if (widget.onSearch != null || !widget.filterable || _query.isEmpty) {
      return widget.options;
    }
    final query = _query.toLowerCase();
    return [
      for (final option in widget.options)
        if (widget.labelBuilder(option).toLowerCase().contains(query)) option,
    ];
  }

  void _onFilterChanged(String value) {
    setState(() => _query = value);
    widget.onSearch?.call(value);
  }

  Object? _formValue() {
    if (!widget.multiple) return widget.value;
    final current = widget.values;
    if (current == null) return <T>[];
    return List<T>.of(current);
  }

  List<T> _listFrom(Object? value) {
    if (value is List<T>) return List<T>.of(value);
    if (value is List) {
      return [
        for (final item in value)
          if (item is T) item,
      ];
    }
    return <T>[];
  }

  void _report(Object? value, TFormTrigger? trigger) {
    if (!mounted) return;
    TFormFieldScope.maybeOf(context)?.report(value, trigger);
  }

  void _syncField({required bool fromDependency}) {
    final scope = TFormFieldScope.maybeOf(context);
    if (scope == null) return;
    if (fromDependency && scope.resetGeneration != _resetGeneration) {
      final seen = _seenField;
      _seenField = true;
      _resetGeneration = scope.resetGeneration;
      if (seen) {
        final restored = widget.multiple ? _listFrom(scope.value) : scope.value;
        _report(restored, null);
        _pushRestored(restored);
        return;
      }
    }
    _seenField = true;
    _report(_formValue(), null);
  }

  void _pushRestored(Object? value) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.multiple) {
        final next = _listFrom(value);
        if (_sameList(widget.values, next)) return;
        widget.onValuesChanged?.call(next);
        return;
      }
      if (value != null && value is! T) return;
      final next = value is T ? value : null;
      if (widget.value == next) return;
      widget.onChanged?.call(next);
    });
  }

  void _setOpen(bool open) {
    if (!widget.enabled || _open == open) return;
    final closing = _open && !open;
    if (!open && (_query.isNotEmpty || _filterController.text.isNotEmpty)) {
      _query = '';
      _filterController.value = TextEditingValue.empty;
    }
    setState(() => _open = open);
    if (!closing) return;
    final value = _hasPending ? _pending : _formValue();
    _hasPending = false;
    _report(value, TFormTrigger.blur);
  }

  void _arm(VoidCallback action) {
    _suppressActivate = true;
    _armed = action;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _suppressActivate = false;
      _armed = null;
    });
  }

  void _activate() {
    final armed = _armed;
    final suppress = _suppressActivate;
    _armed = null;
    _suppressActivate = false;
    if (suppress) {
      armed?.call();
      return;
    }
    _setOpen(!_open);
  }

  bool _isDisabled(T option) => widget.optionDisabled?.call(option) ?? false;

  void _choose(T option) {
    if (_isDisabled(option)) return;
    if (widget.multiple) {
      final next = _toggled(option);
      widget.onValuesChanged?.call(next);
      _report(next, TFormTrigger.change);
      return;
    }
    _pending = option;
    _hasPending = true;
    widget.onChanged?.call(option);
    _report(option, TFormTrigger.change);
    _setOpen(false);
  }

  bool get _canCreate {
    if (!widget.creatable || !widget.filterable || widget.onCreate == null) {
      return false;
    }
    final query = _query.trim();
    if (query.isEmpty) return false;
    final lower = query.toLowerCase();
    return !widget.options.any(
      (option) => widget.labelBuilder(option).toLowerCase() == lower,
    );
  }

  void _create() {
    final query = _query.trim();
    if (!_canCreate || query.isEmpty) return;
    widget.onCreate!(query);
    _setOpen(false);
  }

  List<_SelectFlatRow<T>> _flatRows() {
    final rows = <_SelectFlatRow<T>>[];
    if (_canCreate) {
      rows.add(_SelectFlatRow<T>.create(_query.trim()));
    }
    String? lastGroup;
    for (final option in _visibleOptions) {
      final group = widget.optionGroup?.call(option);
      if (group != null && group.isNotEmpty && group != lastGroup) {
        lastGroup = group;
        rows.add(_SelectFlatRow<T>.group(group));
      }
      rows.add(_SelectFlatRow<T>.option(option));
    }
    return rows;
  }

  Widget _buildFlatRow(BuildContext context, _SelectFlatRow<T> row) {
    switch (row.kind) {
      case _SelectFlatKind.create:
        final query = row.query!;
        return TInteractiveRegion(
          key: const ValueKey<String>('TSelect.create'),
          onActivate: _create,
          builder: (context, state) {
            return ColoredBox(
              color: state == TComponentState.hovered
                  ? tTokenColor(context, 'bgColorContainerHover')
                  : const Color(0x00000000),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Text('创建 "$query"'),
              ),
            );
          },
        );
      case _SelectFlatKind.group:
        final group = row.group!;
        return Padding(
          key: ValueKey<String>('TSelect.group.$group'),
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: Text(
            group,
            style: TextStyle(
              fontSize: 12,
              color: tTokenColor(context, 'textColorSecondary'),
            ),
          ),
        );
      case _SelectFlatKind.option:
        return _option(row.option as T);
    }
  }

  List<T> _toggled(T option) {
    final current = widget.values;
    final next = current == null ? <T>[] : List<T>.of(current);
    if (next.contains(option)) {
      next.remove(option);
    } else {
      next.add(option);
    }
    return next;
  }

  void _remove(T option) {
    final current = widget.values;
    final next = current == null ? <T>[] : List<T>.of(current);
    next.remove(option);
    widget.onValuesChanged?.call(next);
    _report(next, TFormTrigger.change);
  }

  void _clear() {
    if (widget.multiple) {
      final next = <T>[];
      widget.onValuesChanged?.call(next);
      _report(next, TFormTrigger.change);
      return;
    }
    widget.onChanged?.call(null);
    _report(null, TFormTrigger.change);
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      _setOpen(false);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.space) {
      if (!_open) {
        _setOpen(true);
        return KeyEventResult.handled;
      }
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowDown && !_open) {
      _setOpen(true);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final fieldError = TFormFieldScope.maybeOf(context)?.hasError ?? false;
    return TFormFieldScope.inactive(
      child: Focus(
        autofocus: true,
        onKeyEvent: _onKey,
        child: TOverlayPortal(
          visible: _open,
          onVisibleChanged: _setOpen,
          options: const TOverlayPortalOptions(
            preferredPlacement: TPlacement.bottomLeft,
            dismissOnEscape: true,
            dismissOnOutsidePointer: true,
            layer: TOverlayLayer.dropdown,
          ),
          anchor: TInteractiveRegion(
            enabled: widget.enabled,
            onActivate: _activate,
            builder: (context, state) => _trigger(context, fieldError),
          ),
          overlayBuilder: _popup,
        ),
      ),
    );
  }

  Widget _trigger(BuildContext context, bool fieldError) {
    if (widget.multiple) return _multipleTrigger(context, fieldError);
    return _singleTrigger(fieldError);
  }

  Widget _singleTrigger(bool fieldError) {
    final label = widget.value != null
        ? widget.labelBuilder(widget.value as T)
        : (widget.placeholder ?? '');
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        AbsorbPointer(
          child: TInput(
            value: label,
            enabled: false,
            status: fieldError ? TInputStatus.error : TInputStatus.normal,
            suffix: Text(_open ? '▲' : '▼'),
          ),
        ),
        if (_showClear)
          Padding(
            padding: const EdgeInsets.only(right: 32),
            child: _clearButton(),
          ),
      ],
    );
  }

  Widget _multipleTrigger(BuildContext context, bool fieldError) {
    final tokens = TDesignTokenScope.of(context);
    final values = widget.values ?? <T>[];
    return DecoratedBox(
      decoration: _selectFieldChrome(
        tokens,
        enabled: widget.enabled,
        error: fieldError,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 32),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: values.isEmpty
                    ? Text(
                        widget.placeholder ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: tTokenColorOf(tokens, 'textColorPlaceholder'),
                          fontSize: 14,
                        ),
                      )
                    : Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: [for (final option in values) _tag(option)],
                      ),
              ),
              if (_showClear) ...[const SizedBox(width: 8), _clearButton()],
              const SizedBox(width: 8),
              Text(_open ? '▲' : '▼'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tag(T option) {
    final label = widget.labelBuilder(option);
    return TTag(
      key: ValueKey<String>('TSelect.tag.$label'),
      size: TComponentSize.small,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          Listener(
            key: ValueKey<String>('TSelect.tag-close.$label'),
            onPointerDown: (_) => _arm(() => _remove(option)),
            child: const Padding(
              padding: EdgeInsets.only(left: 4),
              child: Text('×'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _clearButton() {
    return Listener(
      key: const ValueKey<String>('TSelect.clear'),
      onPointerDown: (_) => _arm(_clear),
      child: Semantics(
        button: true,
        label: '清空',
        child: TInteractiveRegion(
          onActivate: _clear,
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                '×',
                style: TextStyle(
                  fontSize: 16,
                  height: 1,
                  color: tTokenColor(context, 'textColorPlaceholder'),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _popup(BuildContext context) {
    final tokens = TDesignTokenScope.of(context);
    final rows = _flatRows();
    return Focus(
      focusNode: _listFocus,
      autofocus: !widget.filterable,
      child: TPopupShell(
        tokens: tokens,
        child: SizedBox(
          width: 240,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.filterable)
                _FilterField(
                  controller: _filterController,
                  onChanged: _onFilterChanged,
                  onClose: () => _setOpen(false),
                ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 240),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  shrinkWrap: true,
                  itemCount: rows.length,
                  itemBuilder: (context, index) =>
                      _buildFlatRow(context, rows[index]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _option(T option) {
    final disabled = _isDisabled(option);
    return TInteractiveRegion(
      enabled: !disabled,
      onActivate: disabled ? null : () => _choose(option),
      builder: (context, state) {
        final selected = _isSelected(option);
        return ColoredBox(
          color: disabled
              ? const Color(0x00000000)
              : state == TComponentState.hovered
              ? tTokenColor(context, 'bgColorContainerHover')
              : selected
              ? tTokenColor(context, 'brandColorLight')
              : const Color(0x00000000),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              widget.labelBuilder(option),
              style: TextStyle(
                color: disabled
                    ? tTokenColor(context, 'textColorDisabled')
                    : null,
              ),
            ),
          ),
        );
      },
    );
  }
}

bool _sameList<T>(List<T>? current, List<T> next) {
  if (current == null) return next.isEmpty;
  if (current.length != next.length) return false;
  for (var i = 0; i < current.length; i++) {
    if (current[i] != next[i]) return false;
  }
  return true;
}

class _FilterField extends StatefulWidget {
  const _FilterField({
    required this.controller,
    required this.onChanged,
    required this.onClose,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClose;

  @override
  State<_FilterField> createState() => _FilterFieldState();
}

class _FilterFieldState extends State<_FilterField> {
  late final FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _focus = FocusNode(onKeyEvent: _onKey);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focus.requestFocus();
    });
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.escape) {
      widget.onClose();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final showHint = widget.controller.text.isEmpty;
    final tokens = TDesignTokenScope.of(context);
    final primary = tTokenColorOf(tokens, 'textColorPrimary');
    final brand = tTokenColorOf(tokens, 'brandColor7');
    final secondary = tTokenColorOf(tokens, 'textColorSecondary');
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: DecoratedBox(
        decoration: _selectFieldChrome(tokens, enabled: true, error: false),
        child: SizedBox(
          height: 32,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                if (showHint)
                  IgnorePointer(
                    child: Text(
                      '搜索',
                      style: TextStyle(
                        color: tTokenColorOf(tokens, 'textColorPlaceholder'),
                        fontSize: 14,
                      ),
                    ),
                  ),
                EditableText(
                  key: const ValueKey<String>('TSelect.filter'),
                  controller: widget.controller,
                  focusNode: _focus,
                  style: TextStyle(color: primary, fontSize: 14),
                  cursorColor: brand,
                  backgroundCursorColor: secondary,
                  onChanged: widget.onChanged,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Shared trigger chrome for Select (border / fill / radius), matching TInput.
BoxDecoration _selectFieldChrome(
  TDesignTokenSet tokens, {
  required bool enabled,
  required bool error,
}) {
  return BoxDecoration(
    color: enabled
        ? tTokenColorOf(tokens, 'bgColorContainer')
        : tTokenColorOf(tokens, 'bgColorComponentDisabled'),
    borderRadius: BorderRadius.circular(tTokenRadius(tokens)),
    border: Border.all(
      color: error
          ? tTokenColorOf(tokens, 'errorColor6')
          : tTokenColorOf(tokens, 'componentBorder'),
    ),
  );
}

enum _SelectFlatKind { create, group, option }

class _SelectFlatRow<T> {
  const _SelectFlatRow._({
    required this.kind,
    this.option,
    this.group,
    this.query,
  });

  factory _SelectFlatRow.create(String query) {
    return _SelectFlatRow._(kind: _SelectFlatKind.create, query: query);
  }

  factory _SelectFlatRow.group(String group) {
    return _SelectFlatRow._(kind: _SelectFlatKind.group, group: group);
  }

  factory _SelectFlatRow.option(T option) {
    return _SelectFlatRow._(kind: _SelectFlatKind.option, option: option);
  }

  final _SelectFlatKind kind;
  final T? option;
  final String? group;
  final String? query;
}
