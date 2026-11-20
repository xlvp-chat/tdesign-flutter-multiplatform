import 'package:flutter/widgets.dart';
import 'package:tdesign_flutter_multi_core/tdesign_flutter_multi_core.dart';
import 'package:tdesign_flutter_multi_desktop/tdesign_flutter_multi_desktop.dart';

import '../scaffold.dart';

class BadgeDemoPage extends StatelessWidget {
  const BadgeDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const GalleryPage(
      title: 'Badge 徽标',
      source: 'components/badge',
      children: [
        DemoSection(
          title: '基础徽标',
          child: TSpace(
            size: 24,
            children: [
              TBadge(dot: true, child: DemoBlock()),
              TBadge(count: 2, child: DemoBlock()),
              TBadge(count: 8, child: DemoBlock()),
            ],
          ),
        ),
        DemoSection(
          title: '数字徽标',
          child: TSpace(
            size: 24,
            children: [
              TBadge(count: 2, child: DemoBlock()),
              TBadge(count: 0, showZero: true, child: DemoBlock()),
              TBadge(count: 100, child: DemoBlock()),
            ],
          ),
        ),
        DemoSection(
          title: '封顶数字',
          child: TSpace(
            size: 24,
            children: [
              TBadge(count: 99, max: 99, child: DemoBlock()),
              TBadge(count: 100, max: 99, child: DemoBlock()),
              TBadge(count: 8, max: 10, child: DemoBlock()),
            ],
          ),
        ),
      ],
    );
  }
}

class _Person {
  const _Person(this.id, this.name, this.status, [this.children = const []]);

  final String id;
  final String name;
  final String status;
  final List<_Person> children;
}

const _people = <_Person>[
  _Person('1', '贾明', '健康'),
  _Person('2', '张三', '警告'),
  _Person('3', '王芳', '异常'),
  _Person('4', '李四', '健康'),
];

const _columns = <TTableColumn<_Person>>[
  TTableColumn(id: 'name', title: Text('申请人'), value: _nameOf, width: 160),
  TTableColumn(
    id: 'status',
    title: Text('状态'),
    value: _statusOf,
    width: 120,
    sortable: true,
  ),
];

String _nameOf(_Person row) => row.name;

String _statusOf(_Person row) => row.status;

String _idOf(_Person row) => row.id;

String _emailOf(_Person row) => '${row.name}@example.com';

String _deptOf(_Person row) => row.status == '健康' ? '研发部' : '设计部';

String _phoneOf(_Person row) => '1380000${row.id.padLeft(4, '0')}';

String _groupOf(_Person row) => row.id == '1' || row.id == '2' ? '一组' : '二组';

List<_Person> _childrenOf(_Person row) => row.children;

const _filterColumns = <TTableColumn<_Person>>[
  TTableColumn(
    id: 'name',
    title: Text('申请人'),
    value: _nameOf,
    width: 180,
    filter: TTableFilter(type: TTableFilterType.input),
  ),
  TTableColumn(
    id: 'status',
    title: Text('状态'),
    value: _statusOf,
    width: 160,
    filter: TTableFilter(
      type: TTableFilterType.single,
      options: [
        TTableFilterOption(value: '健康', label: '健康'),
        TTableFilterOption(value: '警告', label: '警告'),
        TTableFilterOption(value: '异常', label: '异常'),
      ],
    ),
  ),
  TTableColumn(
    id: 'group',
    title: Text('分组'),
    value: _groupOf,
    width: 140,
    filter: TTableFilter(
      type: TTableFilterType.multiple,
      options: [
        TTableFilterOption(value: '一组', label: '一组'),
        TTableFilterOption(value: '二组', label: '二组'),
      ],
    ),
  ),
];

const _fixedColumns = <TTableColumn<_Person>>[
  TTableColumn(
    id: 'name',
    title: Text('申请人'),
    value: _nameOf,
    width: 140,
    fixed: TTableFixed.left,
  ),
  TTableColumn(id: 'email', title: Text('邮箱'), value: _emailOf, width: 220),
  TTableColumn(id: 'dept', title: Text('部门'), value: _deptOf, width: 200),
  TTableColumn(id: 'phone', title: Text('电话'), value: _phoneOf, width: 200),
  TTableColumn(
    id: 'status',
    title: Text('状态'),
    value: _statusOf,
    width: 120,
    fixed: TTableFixed.right,
  ),
];

const _org = <_Person>[
  _Person('s', '华南区', '健康', [
    _Person('s1', '贾明', '健康', [_Person('s1a', '贾明-助理', '警告')]),
    _Person('s2', '张三', '警告'),
  ]),
  _Person('n', '华北区', '异常', [_Person('n1', '王芳', '异常')]),
];

class TableDemoPage extends StatefulWidget {
  const TableDemoPage({super.key});

  @override
  State<TableDemoPage> createState() => _TableDemoPageState();
}

class _TableDemoPageState extends State<TableDemoPage> {
  TTableSort? _sort;
  Set<Object> _selected = {};
  Map<String, Object?> _filters = {};
  Set<Object> _expanded = {};
  Map<String, double> _widths = {};
  var _editablePeople = List<_Person>.from(_people);
  var _dragPeople = List<_Person>.from(_people);

  @override
  Widget build(BuildContext context) {
    final sortLabel = _sort == null
        ? '未排序'
        : '${_sort!.columnId} ${_sort!.ascending ? '升序' : '降序'}';
    return GalleryPage(
      title: 'Table 表格',
      source: 'components/table',
      children: [
        const DemoSection(
          title: '基础表格',
          child: TTable<_Person>(
            data: _people,
            columns: _columns,
            rowKey: _idOf,
          ),
        ),
        DemoSection(
          title: '排序',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('排序：$sortLabel'),
              const SizedBox(height: 8),
              TTable<_Person>(
                data: _people,
                columns: _columns,
                rowKey: _idOf,
                sort: _sort,
                onSortChanged: (sort) => setState(() => _sort = sort),
              ),
            ],
          ),
        ),
        DemoSection(
          title: '多选',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('已选：${_selected.join(', ')}'),
              const SizedBox(height: 8),
              TTable<_Person>(
                data: _people,
                columns: _columns,
                rowKey: _idOf,
                selectedKeys: _selected,
                onSelectionChanged: (keys) => setState(() => _selected = keys),
              ),
            ],
          ),
        ),
        DemoSection(
          title: '过滤',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('筛选：${_filters.isEmpty ? '无' : _filters}'),
              const SizedBox(height: 8),
              TTable<_Person>(
                data: _people,
                columns: _filterColumns,
                rowKey: _idOf,
                filterValue: _filters,
                onFilterChanged: (value) => setState(() => _filters = value),
              ),
            ],
          ),
        ),
        const DemoSection(
          title: '固定列',
          child: SizedBox(
            width: 560,
            child: TTable<_Person>(
              data: _people,
              columns: _fixedColumns,
              rowKey: _idOf,
            ),
          ),
        ),
        DemoSection(
          title: '表头吸顶',
          child: TTable<_Person>(
            data: [
              for (var i = 0; i < 12; i++)
                _Person('$i', '申请人$i', i.isEven ? '健康' : '警告'),
            ],
            columns: _columns,
            rowKey: _idOf,
            maxHeight: 220,
          ),
        ),
        DemoSection(
          title: '列宽拖拽',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _widths.isEmpty
                    ? '拖拽表头右缘调整列宽'
                    : '列宽：${_widths.entries.map((e) => '${e.key}=${e.value.toStringAsFixed(0)}').join(', ')}',
              ),
              const SizedBox(height: 8),
              TTable<_Person>(
                data: _people,
                columns: _columns,
                rowKey: _idOf,
                resizable: true,
                columnWidths: _widths,
                onColumnWidthsChanged: (widths) =>
                    setState(() => _widths = widths),
              ),
            ],
          ),
        ),
        DemoSection(
          title: '可编辑单元格',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('双击「申请人」单元格编辑'),
              const SizedBox(height: 8),
              TTable<_Person>(
                data: _editablePeople,
                rowKey: _idOf,
                onCellEdited: (row, columnId, text) {
                  setState(() {
                    _editablePeople = [
                      for (final person in _editablePeople)
                        if (person.id == row.id)
                          _Person(person.id, text, person.status)
                        else
                          person,
                    ];
                  });
                },
                columns: const [
                  TTableColumn(
                    id: 'name',
                    title: Text('申请人'),
                    value: _nameOf,
                    width: 160,
                    editable: true,
                  ),
                  TTableColumn(
                    id: 'status',
                    title: Text('状态'),
                    value: _statusOf,
                    width: 120,
                  ),
                ],
              ),
            ],
          ),
        ),
        DemoSection(
          title: '行拖拽排序',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('长按左侧手柄拖拽排序'),
              const SizedBox(height: 8),
              TTable<_Person>(
                data: _dragPeople,
                columns: _columns,
                rowKey: _idOf,
                dragSort: true,
                onDragSort: (oldIndex, newIndex) {
                  setState(() {
                    final next = [..._dragPeople];
                    final item = next.removeAt(oldIndex);
                    next.insert(newIndex, item);
                    _dragPeople = next;
                  });
                },
              ),
            ],
          ),
        ),
        DemoSection(
          title: '树形结构',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('展开：${_expanded.isEmpty ? '无' : _expanded.join(', ')}'),
              const SizedBox(height: 8),
              TTable<_Person>(
                data: _org,
                columns: _columns,
                rowKey: _idOf,
                childrenOf: _childrenOf,
                expandedKeys: _expanded,
                onExpandedKeysChanged: (keys) =>
                    setState(() => _expanded = keys),
              ),
            ],
          ),
        ),
        const DemoSection(
          title: '空数据',
          child: TTable<_Person>(data: [], columns: _columns, rowKey: _idOf),
        ),
      ],
    );
  }
}

class TagDemoPage extends StatefulWidget {
  const TagDemoPage({super.key});

  @override
  State<TagDemoPage> createState() => _TagDemoPageState();
}

class _TagDemoPageState extends State<TagDemoPage> {
  var _tags = ['标签一', '标签二', '标签三'];

  @override
  Widget build(BuildContext context) {
    return GalleryPage(
      title: 'Tag 标签',
      source: 'components/tag',
      children: [
        const DemoSection(
          title: '不同主题',
          child: TSpace(
            size: 12,
            children: [
              TTag(child: Text('默认')),
              TTag(theme: TTagTheme.primary, child: Text('品牌')),
              TTag(theme: TTagTheme.warning, child: Text('警告')),
              TTag(theme: TTagTheme.danger, child: Text('危险')),
              TTag(theme: TTagTheme.success, child: Text('成功')),
            ],
          ),
        ),
        const DemoSection(
          title: '不同尺寸',
          child: TSpace(
            size: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              TTag(size: TComponentSize.small, child: Text('小')),
              TTag(child: Text('中')),
              TTag(size: TComponentSize.large, child: Text('大')),
            ],
          ),
        ),
        DemoSection(
          title: '可关闭',
          child: TSpace(
            size: 12,
            children: [
              for (final tag in _tags)
                TTag(
                  closable: true,
                  onClose: () => setState(
                    () => _tags = [
                      for (final item in _tags)
                        if (item != tag) item,
                    ],
                  ),
                  child: Text(tag),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class TooltipDemoPage extends StatelessWidget {
  const TooltipDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GalleryPage(
      title: 'Tooltip 文字提示',
      source: 'components/tooltip',
      children: [
        DemoSection(
          title: '弹出位置',
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 28),
            child: TSpace(
              size: 16,
              children: [
                for (final item in _placements)
                  TTooltip(
                    placement: item.$1,
                    content: const Text('文字提示仅展示文本内容'),
                    child: TButton(
                      theme: TButtonTheme.defaultTheme,
                      variant: TButtonVariant.outline,
                      onPressed: () {},
                      child: Text(item.$2),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

const _placements = <(TPlacement, String)>[
  (TPlacement.top, 'top'),
  (TPlacement.topLeft, 'top-left'),
  (TPlacement.topRight, 'top-right'),
  (TPlacement.bottom, 'bottom'),
  (TPlacement.bottomLeft, 'bottom-left'),
  (TPlacement.bottomRight, 'bottom-right'),
  (TPlacement.left, 'left'),
  (TPlacement.leftTop, 'left-top'),
  (TPlacement.leftBottom, 'left-bottom'),
  (TPlacement.right, 'right'),
  (TPlacement.rightTop, 'right-top'),
  (TPlacement.rightBottom, 'right-bottom'),
];
