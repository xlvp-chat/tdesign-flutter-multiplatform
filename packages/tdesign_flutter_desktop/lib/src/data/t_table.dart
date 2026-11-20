import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:tdesign_flutter_core/tdesign_flutter_core.dart';

import '../basic/t_button.dart';
import '../form/_popup_shell.dart';
import '../form/t_checkbox.dart';
import '../form/t_input.dart';
import '../form/t_radio.dart';
import '../token/t_token_color.dart';

const _defaultColumnWidth = 120.0;
const _minColumnWidth = 80.0;
const _maxColumnWidth = 600.0;
const _resizeHandleExtent = 8.0;
const _dragHandleExtent = 28.0;
const _pinnedExtent = 40.0;
const _headerExtent = 40.0;
const _treeIndent = 16.0;
const _treeSlot = 20.0;

/// Called when an editable cell commits text.
typedef TTableCellEdited<T> =
    void Function(T row, String columnId, String text);

/// Called after a flat-table row drag with visible indices.
typedef TTableDragSort = void Function(int oldIndex, int newIndex);

/// Which edge a column stays on while the table scrolls horizontally.
///
/// `null` on [TTableColumn.fixed] means the column scrolls with the body.
enum TTableFixed {
  /// Stays on the left edge of the viewport.
  left,

  /// Stays on the right edge of the viewport.
  right,
}

/// Kind of value a column filter edits.
enum TTableFilterType {
  /// One choice. [TTable.filterValue] stores [TTableFilterOption.value].
  single,

  /// Any number of choices. The stored value is a `List<Object>`.
  multiple,

  /// Free text. The stored value is a `String`.
  input,
}

/// One choice in a [TTableFilterType.single] or [TTableFilterType.multiple] filter.
class TTableFilterOption {
  const TTableFilterOption({required this.value, required this.label});

  /// Value written into [TTable.filterValue] when this choice is confirmed.
  final Object value;

  /// Text shown in the filter panel.
  final String label;
}

/// Filter editor attached to a [TTableColumn].
///
/// [single] and [multiple] list [options]. [input] ignores [options].
/// There is no custom filter widget. The panel confirms through
/// [TTable.onFilterChanged]; dismissing it or pressing 取消 leaves the
/// controlled value unchanged. 重置 writes the empty value for that column.
class TTableFilter {
  const TTableFilter({required this.type, this.options = const []});

  /// Single choice, multiple choices, or text.
  final TTableFilterType type;

  /// Choices for [TTableFilterType.single] and [TTableFilterType.multiple].
  final List<TTableFilterOption> options;
}

/// Typed column for [TTable].
class TTableColumn<T> {
  const TTableColumn({
    required this.id,
    required this.title,
    required this.value,
    this.width,
    this.sortable = false,
    this.resizable,
    this.editable = false,
    this.fixed,
    this.filter,
  });

  /// Key used by sort and by [TTable.filterValue].
  final String id;

  /// Header content.
  final Widget title;

  /// Cell text for [row]. Also the text filters and sorts compare.
  final String Function(T row) value;

  /// Column width in logical pixels. Defaults to 120.
  final double? width;

  /// Shows the sort control and cycles that column when the header is activated.
  ///
  /// Defaults to false.
  final bool sortable;

  /// Whether this column can be resized when [TTable.resizable] is true.
  ///
  /// `null` follows the table. `false` disables the handle for this column.
  final bool? resizable;

  /// Double-click enters an inline text editor when [TTable.onCellEdited] is set.
  ///
  /// Defaults to false.
  final bool editable;

  /// Pins the column while the body scrolls horizontally.
  ///
  /// `null` scrolls with the other unpinned columns. This does not affix the
  /// header when the page scrolls vertically.
  final TTableFixed? fixed;

  /// Filter editor for this column. `null` shows no filter control.
  final TTableFilter? filter;
}

/// Controlled sort for one column.
class TTableSort {
  const TTableSort({required this.columnId, required this.ascending});

  /// [TTableColumn.id] of the sorted column.
  final String columnId;

  /// `true` is ascending, `false` is descending.
  final bool ascending;
}

/// Desktop table.
///
/// Typed columns, row hover, controlled selection, and a single sort stay in
/// place. A column [TTableFilter] opens an overlay panel; 确定 and 重置 call
/// [onFilterChanged], while 取消, Escape, and an outside pointer do not.
/// [TTableColumn.fixed] pins columns on the left or right of a horizontal
/// scroller. [maxHeight] keeps the header visible while the body scrolls
/// vertically (not a window-level Affix). With pinned columns, [maxHeight]
/// only clamps the whole table. [resizable] plus [columnWidths] let the user
/// drag header edges; widths stay controlled. [TTableColumn.editable] plus
/// [onCellEdited] enable double-click inline text editing. [dragSort] plus
/// [onDragSort] add a row handle for flat tables. [childrenOf] plus
/// [expandedKeys] render an in-memory tree. Child rows indent by depth. A null
/// [onExpandedKeysChanged] does not expand a row on its own.
///
/// Active filters on different columns all have to match. On each tree level,
/// rows are filtered and then sorted. A row that does not match hides its
/// descendants. Empty values do not filter: `null`, an empty list, or an
/// empty string. A single or multiple choice matches when [TTableColumn.value]
/// equals the option label or `value.toString()`. Text filters use a
/// case-sensitive substring.
class TTable<T> extends StatelessWidget {
  const TTable({
    super.key,
    required this.data,
    required this.columns,
    required this.rowKey,
    this.selectedKeys = const {},
    this.onSelectionChanged,
    this.sort,
    this.onSortChanged,
    this.filterValue = const <String, Object?>{},
    this.onFilterChanged,
    this.childrenOf,
    this.expandedKeys = const <Object>{},
    this.onExpandedKeysChanged,
    this.maxHeight,
    this.resizable = false,
    this.columnWidths = const <String, double>{},
    this.onColumnWidthsChanged,
    this.onCellEdited,
    this.dragSort = false,
    this.onDragSort,
  });

  /// Root rows. Tree children come from [childrenOf], not from this list.
  final List<T> data;

  /// Columns in declared order. Fixed columns are pulled to the matching edge
  /// when the table can pin them.
  final List<TTableColumn<T>> columns;

  /// Stable id for selection and [expandedKeys].
  final Object Function(T row) rowKey;

  /// Selected [rowKey] values.
  final Set<Object> selectedKeys;

  /// Called with the next selected set. `null` ignores row activation.
  final ValueChanged<Set<Object>>? onSelectionChanged;

  /// Active sort. `null` keeps [data] order (after filtering).
  final TTableSort? sort;

  /// Called with the next sort, or `null` to clear it.
  ///
  /// The header cycles ascending, descending, then cleared.
  final ValueChanged<TTableSort?>? onSortChanged;

  /// Controlled filter values keyed by [TTableColumn.id].
  ///
  /// [TTableFilterType.single] stores the option value or `null`.
  /// [TTableFilterType.multiple] stores a `List<Object>`.
  /// [TTableFilterType.input] stores a `String`.
  final Map<String, Object?> filterValue;

  /// Called with the next full map after 确定 or 重置.
  ///
  /// Not called when the panel is dismissed or 取消 is pressed.
  final ValueChanged<Map<String, Object?>>? onFilterChanged;

  /// In-memory children of [row]. `null` keeps a flat table.
  ///
  /// An empty list is a leaf. Children are not loaded lazily.
  final List<T> Function(T row)? childrenOf;

  /// [rowKey] values that show their children. Controlled.
  final Set<Object> expandedKeys;

  /// Called with the next expanded set. `null` does not expand on its own.
  final ValueChanged<Set<Object>>? onExpandedKeysChanged;

  /// Max table height. The header stays; the body scrolls when content is
  /// taller. Ignored when null. With pinned columns the whole table scrolls.
  final double? maxHeight;

  /// Enables header-edge column resize when [onColumnWidthsChanged] is set.
  final bool resizable;

  /// Controlled width overrides keyed by [TTableColumn.id].
  ///
  /// Missing keys fall back to [TTableColumn.width], then 120.
  final Map<String, double> columnWidths;

  /// Called with the next full override map while a column is dragged.
  final ValueChanged<Map<String, double>>? onColumnWidthsChanged;

  /// Called when an editable cell commits a new text value.
  final TTableCellEdited<T>? onCellEdited;

  /// Shows a drag handle before each flat row when [onDragSort] is set.
  final bool dragSort;

  /// Called with visible-row indices after a successful drop.
  final TTableDragSort? onDragSort;

  bool get _dragEnabled => dragSort && onDragSort != null && childrenOf == null;

  List<_FlatRow<T>> _flatten() {
    final rows = <_FlatRow<T>>[];
    _collect(data, 0, rows);
    return rows;
  }

  void _collect(List<T> source, int depth, List<_FlatRow<T>> out) {
    for (final row in _prepare(source)) {
      final key = rowKey(row);
      final nested = childrenOf?.call(row);
      final hasChildren = nested != null && nested.isNotEmpty;
      out.add(
        _FlatRow<T>(
          row: row,
          depth: depth,
          hasChildren: hasChildren,
          key: key,
          index: out.length,
        ),
      );
      if (nested != null && nested.isNotEmpty && expandedKeys.contains(key)) {
        _collect(nested, depth + 1, out);
      }
    }
  }

  List<T> _prepare(List<T> source) {
    final matched = <T>[
      for (final row in source)
        if (_matches(row)) row,
    ];
    final column = _sortColumn();
    final active = sort;
    if (column == null || active == null) return matched;
    final sorted = [...matched];
    final ascending = active.ascending;
    sorted.sort((a, b) {
      final cmp = column.value(a).compareTo(column.value(b));
      return ascending ? cmp : -cmp;
    });
    return sorted;
  }

  TTableColumn<T>? _sortColumn() {
    final id = sort?.columnId;
    if (id == null) return null;
    for (final column in columns) {
      if (column.id == id) return column;
    }
    return null;
  }

  bool _matches(T row) {
    for (final column in columns) {
      if (!_columnMatches(column, row)) return false;
    }
    return true;
  }

  bool _columnMatches(TTableColumn<T> column, T row) {
    final filter = column.filter;
    if (filter == null) return true;
    final raw = filterValue[column.id];
    if (!_filterActive(filter.type, raw)) return true;
    final cell = column.value(row);
    switch (filter.type) {
      case TTableFilterType.single:
        return _choiceMatches(filter, raw, cell);
      case TTableFilterType.multiple:
        if (raw is! List) return true;
        for (final item in raw) {
          if (_choiceMatches(filter, item, cell)) return true;
        }
        return false;
      case TTableFilterType.input:
        return cell.contains(raw.toString());
    }
  }

  bool _choiceMatches(TTableFilter filter, Object? raw, String cell) {
    if (raw == null) return false;
    for (final option in filter.options) {
      if (option.value == raw) {
        return cell == option.label || cell == option.value.toString();
      }
    }
    return cell == raw.toString();
  }

  void _toggleSort(TTableColumn<T> column) {
    final callback = onSortChanged;
    if (!column.sortable || callback == null) return;
    final active = sort;
    if (active?.columnId != column.id) {
      callback(TTableSort(columnId: column.id, ascending: true));
      return;
    }
    if (active!.ascending) {
      callback(TTableSort(columnId: column.id, ascending: false));
    } else {
      callback(null);
    }
  }

  void _toggleRow(Object key) {
    final callback = onSelectionChanged;
    if (callback == null) return;
    callback(_toggleSetMember(selectedKeys, key));
  }

  void _toggleExpanded(Object key) {
    final callback = onExpandedKeysChanged;
    if (callback == null) return;
    callback(_toggleSetMember(expandedKeys, key));
  }

  void _commitFilter(String columnId, Object? value) {
    final callback = onFilterChanged;
    if (callback == null) return;
    final next = Map<String, Object?>.from(filterValue);
    next[columnId] = value;
    callback(next);
  }

  double _resolvedWidth(TTableColumn<T> column) {
    return columnWidths[column.id] ?? column.width ?? _defaultColumnWidth;
  }

  double _widthOf(List<TTableColumn<T>> cols) {
    var width = _dragEnabled ? _dragHandleExtent : 0.0;
    for (final column in cols) {
      width += _resolvedWidth(column);
    }
    return width;
  }

  bool _columnResizable(TTableColumn<T> column) {
    if (!resizable || onColumnWidthsChanged == null) return false;
    return column.resizable ?? true;
  }

  void _setColumnWidth(TTableColumn<T> column, double width) {
    final callback = onColumnWidthsChanged;
    if (callback == null || !_columnResizable(column)) return;
    final next = Map<String, double>.from(columnWidths);
    next[column.id] = width.clamp(_minColumnWidth, _maxColumnWidth);
    callback(next);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = TDesignTokenScope.of(context);
    final nodes = _flatten();
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: _tableLine(context)),
        borderRadius: BorderRadius.circular(tTokenRadius(tokens)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return _buildLayout(constraints.maxWidth, nodes);
        },
      ),
    );
  }

  Widget _buildLayout(double maxWidth, List<_FlatRow<T>> nodes) {
    final left = <TTableColumn<T>>[];
    final middle = <TTableColumn<T>>[];
    final right = <TTableColumn<T>>[];
    for (final column in columns) {
      switch (column.fixed) {
        case TTableFixed.left:
          left.add(column);
        case TTableFixed.right:
          right.add(column);
        case null:
          middle.add(column);
      }
    }
    final fixedWidth = _widthOf(left) + _widthOf(right);
    final canPin =
        maxWidth.isFinite &&
        (left.isNotEmpty || right.isNotEmpty) &&
        fixedWidth < maxWidth;
    if (canPin) {
      final anchor = left.isNotEmpty
          ? left.first.id
          : middle.isNotEmpty
          ? middle.first.id
          : right.first.id;
      final pinned = _PinnedLayout<T>(
        nodes: nodes,
        left: left,
        middle: middle,
        right: right,
        treeColumnId: childrenOf == null ? null : anchor,
        table: this,
      );
      final limit = maxHeight;
      if (limit == null) return pinned;
      return SizedBox(
        height: limit,
        child: SingleChildScrollView(
          key: const ValueKey<String>('TTable.vscroll'),
          physics: const ClampingScrollPhysics(),
          child: pinned,
        ),
      );
    }
    final plain = _ColumnStack<T>(
      columns: columns,
      nodes: nodes,
      treeColumnId: childrenOf == null || columns.isEmpty
          ? null
          : columns.first.id,
      fixedExtent: false,
      table: this,
      maxBodyHeight: maxHeight == null ? null : maxHeight! - _headerExtent,
    );
    final contentWidth = _widthOf(columns);
    final Widget horizontal = maxWidth.isFinite && contentWidth > maxWidth
        ? SingleChildScrollView(
            key: const ValueKey<String>('TTable.scroll'),
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
            child: plain,
          )
        : plain;
    return horizontal;
  }
}

class _FlatRow<T> {
  const _FlatRow({
    required this.row,
    required this.depth,
    required this.hasChildren,
    required this.key,
    required this.index,
  });

  final T row;
  final int depth;
  final bool hasChildren;
  final Object key;
  final int index;
}

class _PinnedLayout<T> extends StatelessWidget {
  const _PinnedLayout({
    required this.nodes,
    required this.left,
    required this.middle,
    required this.right,
    required this.treeColumnId,
    required this.table,
  });

  final List<_FlatRow<T>> nodes;
  final List<TTableColumn<T>> left;
  final List<TTableColumn<T>> middle;
  final List<TTableColumn<T>> right;
  final String? treeColumnId;
  final TTable<T> table;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (left.isNotEmpty)
              _PinnedEdge(
                leading: true,
                child: _ColumnStack<T>(
                  columns: left,
                  nodes: nodes,
                  treeColumnId: treeColumnId,
                  fixedExtent: true,
                  table: table,
                ),
              ),
            Expanded(
              child: SingleChildScrollView(
                key: const ValueKey<String>('TTable.scroll'),
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                child: _ColumnStack<T>(
                  columns: middle,
                  nodes: nodes,
                  treeColumnId: treeColumnId,
                  fixedExtent: true,
                  table: table,
                ),
              ),
            ),
            if (right.isNotEmpty)
              _PinnedEdge(
                leading: false,
                child: _ColumnStack<T>(
                  columns: right,
                  nodes: nodes,
                  treeColumnId: treeColumnId,
                  fixedExtent: true,
                  table: table,
                ),
              ),
          ],
        ),
        if (nodes.isEmpty) const _EmptyState(),
      ],
    );
  }
}

class _PinnedEdge extends StatelessWidget {
  const _PinnedEdge({required this.leading, required this.child});

  final bool leading;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          right: leading
              ? BorderSide(color: _tableLine(context))
              : BorderSide.none,
          left: leading
              ? BorderSide.none
              : BorderSide(color: _tableLine(context)),
        ),
      ),
      child: child,
    );
  }
}

class _ColumnStack<T> extends StatelessWidget {
  const _ColumnStack({
    required this.columns,
    required this.nodes,
    required this.treeColumnId,
    required this.fixedExtent,
    required this.table,
    this.maxBodyHeight,
  });

  final List<TTableColumn<T>> columns;
  final List<_FlatRow<T>> nodes;
  final String? treeColumnId;
  final bool fixedExtent;
  final TTable<T> table;
  final double? maxBodyHeight;

  @override
  Widget build(BuildContext context) {
    final header = _HeaderRow<T>(
      columns: columns,
      fixedExtent: fixedExtent,
      sort: table.sort,
      onSort: table._toggleSort,
      filterValue: table.filterValue,
      onCommitFilter: table._commitFilter,
      table: table,
    );
    Widget rowAt(int index) {
      final node = nodes[index];
      return _DragSortRow<T>(
        node: node,
        enabled: table._dragEnabled,
        onDragSort: table.onDragSort,
        child: _BodyRow<T>(
          node: node,
          columns: columns,
          treeColumnId: treeColumnId,
          fixedExtent: fixedExtent,
          selected: table.selectedKeys.contains(node.key),
          expanded: table.expandedKeys.contains(node.key),
          onToggle: () => table._toggleRow(node.key),
          onToggleExpanded: () => table._toggleExpanded(node.key),
          table: table,
        ),
      );
    }

    final limit = maxBodyHeight;
    if (limit == null || limit <= 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          header,
          if (!fixedExtent && nodes.isEmpty)
            const _EmptyState()
          else
            for (var i = 0; i < nodes.length; i++) rowAt(i),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        header,
        SizedBox(
          height: limit,
          child: ListView.builder(
            key: const ValueKey<String>('TTable.body'),
            padding: EdgeInsets.zero,
            itemExtent: fixedExtent ? _pinnedExtent : null,
            itemCount: nodes.length,
            itemBuilder: (context, index) => rowAt(index),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Padding(padding: EdgeInsets.all(24), child: Text('暂无数据'));
  }
}

class _HeaderRow<T> extends StatelessWidget {
  const _HeaderRow({
    required this.columns,
    required this.fixedExtent,
    required this.sort,
    required this.onSort,
    required this.filterValue,
    required this.onCommitFilter,
    required this.table,
  });

  final List<TTableColumn<T>> columns;
  final bool fixedExtent;
  final TTableSort? sort;
  final void Function(TTableColumn<T> column) onSort;
  final Map<String, Object?> filterValue;
  final void Function(String columnId, Object? value) onCommitFilter;
  final TTable<T> table;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _tableHover(context),
      child: Row(
        children: [
          if (table._dragEnabled)
            SizedBox(
              width: _dragHandleExtent,
              height: fixedExtent ? _pinnedExtent : null,
            ),
          for (final column in columns)
            _HeaderCell<T>(
              column: column,
              fixedExtent: fixedExtent,
              sort: sort,
              onSort: onSort,
              filterValue: filterValue[column.id],
              onCommit: (value) => onCommitFilter(column.id, value),
              table: table,
            ),
        ],
      ),
    );
  }
}

class _DragSortRow<T> extends StatelessWidget {
  const _DragSortRow({
    required this.node,
    required this.enabled,
    required this.onDragSort,
    required this.child,
  });

  final _FlatRow<T> node;
  final bool enabled;
  final TTableDragSort? onDragSort;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;
    return DragTarget<int>(
      onWillAcceptWithDetails: (details) => details.data != node.index,
      onAcceptWithDetails: (details) {
        onDragSort?.call(details.data, node.index);
      },
      builder: (context, candidate, rejected) {
        final highlight = candidate.isNotEmpty;
        return ColoredBox(
          color: highlight ? _tableSelected(context) : const Color(0x00000000),
          child: Row(
            children: [
              LongPressDraggable<int>(
                data: node.index,
                feedback: DecoratedBox(
                  decoration: BoxDecoration(
                    color: _tableHover(context),
                    border: Border.fromBorderSide(
                      BorderSide(color: _tableLine(context)),
                    ),
                  ),
                  child: const SizedBox(
                    width: _dragHandleExtent,
                    height: _pinnedExtent,
                    child: Center(
                      child: Text('⋮⋮', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ),
                childWhenDragging: const SizedBox(
                  width: _dragHandleExtent,
                  height: _pinnedExtent,
                ),
                child: SizedBox(
                  key: ValueKey<String>('TTable.drag.${node.key}'),
                  width: _dragHandleExtent,
                  height: _pinnedExtent,
                  child: const Center(
                    child: Text('⋮⋮', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ),
              Expanded(child: child),
            ],
          ),
        );
      },
    );
  }
}

class _HeaderCell<T> extends StatelessWidget {
  const _HeaderCell({
    required this.column,
    required this.fixedExtent,
    required this.sort,
    required this.onSort,
    required this.filterValue,
    required this.onCommit,
    required this.table,
  });

  final TTableColumn<T> column;
  final bool fixedExtent;
  final TTableSort? sort;
  final void Function(TTableColumn<T> column) onSort;
  final Object? filterValue;
  final ValueChanged<Object?> onCommit;
  final TTable<T> table;

  @override
  Widget build(BuildContext context) {
    final marker = sort?.columnId == column.id
        ? (sort!.ascending ? ' ↑' : ' ↓')
        : '';
    final canResize = table._columnResizable(column);
    final shell = _CellShell(
      width: table._resolvedWidth(column),
      fixedExtent: fixedExtent,
      child: Row(
        children: [
          Expanded(
            child: TInteractiveRegion(
              enabled: column.sortable,
              onActivate: () => onSort(column),
              builder: (context, state) {
                return Row(
                  children: [
                    Expanded(child: column.title),
                    if (column.sortable) Text(marker),
                  ],
                );
              },
            ),
          ),
          if (column.filter != null) ...[
            const SizedBox(width: 4),
            _FilterButton(
              key: ValueKey<String>('TTable.filter.${column.id}'),
              columnId: column.id,
              filter: column.filter!,
              value: filterValue,
              onConfirm: onCommit,
            ),
          ],
        ],
      ),
    );
    if (!canResize) return shell;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        shell,
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          width: _resizeHandleExtent,
          child: _ResizeHandle(
            columnId: column.id,
            width: table._resolvedWidth(column),
            onChanged: (width) => table._setColumnWidth(column, width),
          ),
        ),
      ],
    );
  }
}

class _ResizeHandle extends StatefulWidget {
  const _ResizeHandle({
    required this.columnId,
    required this.width,
    required this.onChanged,
  });

  final String columnId;
  final double width;
  final ValueChanged<double> onChanged;

  @override
  State<_ResizeHandle> createState() => _ResizeHandleState();
}

class _ResizeHandleState extends State<_ResizeHandle> {
  double? _originWidth;
  var _dragged = 0.0;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      child: GestureDetector(
        key: ValueKey<String>('TTable.resize.${widget.columnId}'),
        behavior: HitTestBehavior.opaque,
        onHorizontalDragStart: (_) {
          _originWidth = widget.width;
          _dragged = 0;
        },
        onHorizontalDragUpdate: (details) {
          final origin = _originWidth;
          if (origin == null) return;
          _dragged += details.delta.dx;
          widget.onChanged(origin + _dragged);
        },
        onHorizontalDragEnd: (_) {
          _originWidth = null;
          _dragged = 0;
        },
        onHorizontalDragCancel: () {
          _originWidth = null;
          _dragged = 0;
        },
      ),
    );
  }
}

class _BodyRow<T> extends StatefulWidget {
  const _BodyRow({
    required this.node,
    required this.columns,
    required this.treeColumnId,
    required this.fixedExtent,
    required this.selected,
    required this.expanded,
    required this.onToggle,
    required this.onToggleExpanded,
    required this.table,
  });

  final _FlatRow<T> node;
  final List<TTableColumn<T>> columns;
  final String? treeColumnId;
  final bool fixedExtent;
  final bool selected;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onToggleExpanded;
  final TTable<T> table;

  @override
  State<_BodyRow<T>> createState() => _BodyRowState<T>();
}

class _BodyRowState<T> extends State<_BodyRow<T>> {
  String? _editingColumnId;
  TextEditingController? _editController;
  FocusNode? _editFocus;

  @override
  void dispose() {
    _editController?.dispose();
    _editFocus?.dispose();
    super.dispose();
  }

  bool _canEdit(TTableColumn<T> column) {
    return column.editable && widget.table.onCellEdited != null;
  }

  void _startEdit(TTableColumn<T> column) {
    if (!_canEdit(column)) return;
    _editController?.dispose();
    _editFocus?.dispose();
    final text = column.value(widget.node.row);
    _editController = TextEditingController(text: text);
    _editFocus = FocusNode()..addListener(_handleEditFocus);
    setState(() => _editingColumnId = column.id);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _editFocus?.requestFocus();
    });
  }

  void _handleEditFocus() {
    if (!mounted) return;
    if (_editFocus?.hasFocus == false) _cancelEdit();
  }

  void _cancelEdit() {
    if (_editingColumnId == null) return;
    _editFocus?.removeListener(_handleEditFocus);
    _editController?.dispose();
    _editFocus?.dispose();
    _editController = null;
    _editFocus = null;
    setState(() => _editingColumnId = null);
  }

  void _commitEdit(TTableColumn<T> column) {
    final text = _editController?.text ?? '';
    final callback = widget.table.onCellEdited;
    _cancelEdit();
    callback?.call(widget.node.row, column.id, text);
  }

  @override
  Widget build(BuildContext context) {
    return TInteractiveRegion(
      onActivate: widget.onToggle,
      builder: (context, state) {
        final background = widget.selected
            ? _tableSelected(context)
            : state == TComponentState.hovered
            ? _tableHover(context)
            : _tableRow(context);
        return ColoredBox(
          color: background,
          child: Row(
            children: [
              for (final column in widget.columns)
                _CellShell(
                  width: widget.table._resolvedWidth(column),
                  fixedExtent: widget.fixedExtent,
                  child: _value(column),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _value(TTableColumn<T> column) {
    if (_editingColumnId == column.id) {
      return Focus(
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.escape) {
            _cancelEdit();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: EditableText(
          key: ValueKey<String>('TTable.edit.${widget.node.key}.${column.id}'),
          controller: _editController!,
          focusNode: _editFocus!,
          style: TextStyle(
            fontSize: 14,
            color: tTokenColor(context, 'textColorPrimary'),
          ),
          cursorColor: tTokenColor(context, 'brandColor7'),
          backgroundCursorColor: _tableLine(context),
          maxLines: 1,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _commitEdit(column),
        ),
      );
    }
    final text = Text(
      column.value(widget.node.row),
      maxLines: widget.fixedExtent ? 1 : null,
      overflow: widget.fixedExtent ? TextOverflow.ellipsis : TextOverflow.clip,
    );
    final content = column.id != widget.treeColumnId
        ? text
        : Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: widget.node.depth * _treeIndent),
                child: SizedBox(
                  width: _treeSlot,
                  height: _treeSlot,
                  child: widget.node.hasChildren
                      ? _ExpandButton(
                          rowKey: widget.node.key,
                          expanded: widget.expanded,
                          onPressed: widget.onToggleExpanded,
                        )
                      : const SizedBox.shrink(),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(child: text),
            ],
          );
    if (!_canEdit(column)) return content;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onDoubleTap: () => _startEdit(column),
      child: content,
    );
  }
}

class _CellShell extends StatelessWidget {
  const _CellShell({
    required this.width,
    required this.fixedExtent,
    required this.child,
  });

  final double width;
  final bool fixedExtent;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!fixedExtent) {
      return SizedBox(
        width: width,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: child,
        ),
      );
    }
    return SizedBox(
      width: width,
      height: _pinnedExtent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Align(alignment: Alignment.centerLeft, child: child),
      ),
    );
  }
}

class _ExpandButton extends StatelessWidget {
  const _ExpandButton({
    required this.rowKey,
    required this.expanded,
    required this.onPressed,
  });

  final Object rowKey;
  final bool expanded;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: expanded ? '收起' : '展开',
      child: GestureDetector(
        key: ValueKey<String>('TTable.expand.$rowKey'),
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: SizedBox(
          width: _treeSlot,
          height: _treeSlot,
          child: Center(
            child: Text(
              expanded ? '▾' : '▸',
              style: const TextStyle(fontSize: 12, height: 1),
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterButton extends StatefulWidget {
  const _FilterButton({
    super.key,
    required this.columnId,
    required this.filter,
    required this.value,
    required this.onConfirm,
  });

  final String columnId;
  final TTableFilter filter;
  final Object? value;
  final ValueChanged<Object?> onConfirm;

  @override
  State<_FilterButton> createState() => _FilterButtonState();
}

class _FilterButtonState extends State<_FilterButton> {
  var _open = false;

  void _setOpen(bool value) {
    if (!mounted || _open == value) return;
    setState(() => _open = value);
  }

  void _toggle() => _setOpen(!_open);

  void _apply(Object? value) {
    widget.onConfirm(value);
    _setOpen(false);
  }

  @override
  Widget build(BuildContext context) {
    final active = _filterActive(widget.filter.type, widget.value);
    return TOverlayPortal(
      visible: _open,
      onVisibleChanged: _setOpen,
      options: const TOverlayPortalOptions(
        preferredPlacement: TPlacement.bottomLeft,
        dismissOnEscape: true,
        dismissOnOutsidePointer: true,
      ),
      anchor: TInteractiveRegion(
        onActivate: _toggle,
        builder: (context, state) {
          return Semantics(
            button: true,
            label: '筛选',
            child: SizedBox(
              width: 24,
              height: 24,
              child: Center(
                child: Text(
                  '▽',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1,
                    color: active
                        ? tTokenColor(context, 'brandColor7')
                        : _tableMuted(context),
                  ),
                ),
              ),
            ),
          );
        },
      ),
      overlayBuilder: (context) {
        return _FilterPanel(
          columnId: widget.columnId,
          filter: widget.filter,
          value: widget.value,
          onApply: _apply,
          onCancel: () => _setOpen(false),
        );
      },
    );
  }
}

class _FilterPanel extends StatefulWidget {
  const _FilterPanel({
    required this.columnId,
    required this.filter,
    required this.value,
    required this.onApply,
    required this.onCancel,
  });

  final String columnId;
  final TTableFilter filter;
  final Object? value;
  final ValueChanged<Object?> onApply;
  final VoidCallback onCancel;

  @override
  State<_FilterPanel> createState() => _FilterPanelState();
}

class _FilterPanelState extends State<_FilterPanel> {
  late Object? _draft;

  @override
  void initState() {
    super.initState();
    _draft = _initialDraft(widget.filter.type, widget.value);
  }

  void _applyDraft() => widget.onApply(_draft);

  void _reset() {
    widget.onApply(_emptyFilterValue(widget.filter.type));
  }

  @override
  Widget build(BuildContext context) {
    final tokens = TDesignTokenScope.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {},
      child: SizedBox(
        width: 248,
        child: TPopupShell(
          tokens: tokens,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _editor(),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TButton(
                      key: ValueKey<String>(
                        'TTable.filter.reset.${widget.columnId}',
                      ),
                      theme: TButtonTheme.defaultTheme,
                      variant: TButtonVariant.text,
                      size: TComponentSize.small,
                      onPressed: _reset,
                      child: const Text('重置'),
                    ),
                    const SizedBox(width: 8),
                    TButton(
                      key: ValueKey<String>(
                        'TTable.filter.cancel.${widget.columnId}',
                      ),
                      theme: TButtonTheme.defaultTheme,
                      variant: TButtonVariant.outline,
                      size: TComponentSize.small,
                      onPressed: widget.onCancel,
                      child: const Text('取消'),
                    ),
                    const SizedBox(width: 8),
                    TButton(
                      key: ValueKey<String>(
                        'TTable.filter.confirm.${widget.columnId}',
                      ),
                      theme: TButtonTheme.primary,
                      variant: TButtonVariant.base,
                      size: TComponentSize.small,
                      onPressed: _applyDraft,
                      child: const Text('确定'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _editor() {
    switch (widget.filter.type) {
      case TTableFilterType.single:
      case TTableFilterType.multiple:
        final single = widget.filter.type == TTableFilterType.single;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < widget.filter.options.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              if (single)
                _radio(widget.filter.options[i])
              else
                _checkbox(widget.filter.options[i]),
            ],
          ],
        );
      case TTableFilterType.input:
        return TInput(
          value: _draft is String ? _draft! as String : '',
          placeholder: '请输入',
          onChanged: (text) => setState(() => _draft = text),
        );
    }
  }

  Widget _radio(TTableFilterOption option) {
    return TRadio<Object>(
      key: ValueKey<String>(
        'TTable.filter.option.${widget.columnId}.${option.label}',
      ),
      value: option.value,
      groupValue: _draft,
      label: Text(option.label),
      onChanged: (value) => setState(() => _draft = value),
    );
  }

  Widget _checkbox(TTableFilterOption option) {
    final selected = _draft is List && (_draft! as List).contains(option.value);
    return TCheckbox(
      key: ValueKey<String>(
        'TTable.filter.option.${widget.columnId}.${option.label}',
      ),
      checked: selected,
      label: Text(option.label),
      onChanged: (checked) {
        final next = <Object>[
          if (_draft is List)
            for (final item in _draft! as List)
              if (item is Object && item != option.value) item,
        ];
        if (checked) next.add(option.value);
        setState(() => _draft = next);
      },
    );
  }
}

bool _filterActive(TTableFilterType type, Object? value) {
  switch (type) {
    case TTableFilterType.single:
      return value != null;
    case TTableFilterType.multiple:
      return value is List && value.isNotEmpty;
    case TTableFilterType.input:
      return value is String && value.isNotEmpty;
  }
}

Object? _initialDraft(TTableFilterType type, Object? value) {
  switch (type) {
    case TTableFilterType.single:
      return value;
    case TTableFilterType.multiple:
      if (value is List) {
        return <Object>[
          for (final item in value)
            if (item is Object) item,
        ];
      }
      return <Object>[];
    case TTableFilterType.input:
      return value is String ? value : '';
  }
}

Object? _emptyFilterValue(TTableFilterType type) {
  switch (type) {
    case TTableFilterType.single:
      return null;
    case TTableFilterType.multiple:
      return <Object>[];
    case TTableFilterType.input:
      return '';
  }
}

Set<E> _toggleSetMember<E>(Set<E> current, E member) {
  final next = {...current};
  if (!next.add(member)) {
    next.remove(member);
  }
  return next;
}

Color _tableLine(BuildContext context) =>
    tTokenColor(context, 'componentBorder');

Color _tableSelected(BuildContext context) =>
    tTokenColor(context, 'brandColorLight');

/// Header fill and row hover share `bgColorContainerHover`.
Color _tableHover(BuildContext context) =>
    tTokenColor(context, 'bgColorContainerHover');

Color _tableRow(BuildContext context) =>
    tTokenColor(context, 'bgColorContainer');

Color _tableMuted(BuildContext context) =>
    tTokenColor(context, 'textColorSecondary');
