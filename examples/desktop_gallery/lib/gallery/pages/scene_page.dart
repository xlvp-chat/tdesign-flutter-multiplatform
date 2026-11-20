import 'package:flutter/widgets.dart';
import 'package:tdesign_flutter_desktop/tdesign_flutter_desktop.dart';

class _User {
  const _User({required this.id, required this.name, required this.role});

  final String id;
  final String name;
  final String role;

  _User copyWith({String? name, String? role}) {
    return _User(id: id, name: name ?? this.name, role: role ?? this.role);
  }
}

/// Composed CRUD page kept from the earlier shell demo.
class SceneDemoPage extends StatefulWidget {
  const SceneDemoPage({super.key});

  @override
  State<SceneDemoPage> createState() => _SceneDemoPageState();
}

class _SceneDemoPageState extends State<SceneDemoPage> {
  var _tab = 'list';

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF5F5F5),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const TBreadcrumb(
              items: [
                TBreadcrumbItem(label: Text('首页')),
                TBreadcrumbItem(label: Text('用户管理')),
              ],
            ),
            const SizedBox(height: 12),
            TTabs(
              value: _tab,
              onChanged: (value) => setState(() => _tab = value),
              items: const [
                TTabItem(value: 'list', label: Text('列表')),
                TTabItem(value: 'settings', label: Text('偏好')),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _tab == 'list' ? const _CrudPane() : const _SettingsPane(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsPane extends StatefulWidget {
  const _SettingsPane();

  @override
  State<_SettingsPane> createState() => _SettingsPaneState();
}

class _SettingsPaneState extends State<_SettingsPane> {
  var _notify = true;
  var _density = 'default';

  @override
  Widget build(BuildContext context) {
    return TForm(
      children: [
        TFormItem(
          label: '消息通知',
          child: TSwitch(
            value: _notify,
            onChanged: (value) => setState(() => _notify = value),
          ),
        ),
        TFormItem(
          label: '密度',
          child: TRadioGroup<String>(
            value: _density,
            onChanged: (value) => setState(() => _density = value),
            children: const [
              TRadio(groupValue: null, value: 'compact', label: Text('紧凑')),
              TRadio(groupValue: null, value: 'default', label: Text('默认')),
              TRadio(groupValue: null, value: 'comfortable', label: Text('舒适')),
            ],
          ),
        ),
        const TFormItem(
          label: '备注',
          child: TTextarea(value: '', placeholder: '可选说明'),
        ),
      ],
    );
  }
}

class _CrudPane extends StatefulWidget {
  const _CrudPane();

  @override
  State<_CrudPane> createState() => _CrudPaneState();
}

class _CrudPaneState extends State<_CrudPane> {
  final _users = <_User>[
    const _User(id: '1', name: 'Alice', role: 'Admin'),
    const _User(id: '2', name: 'Bob', role: 'Editor'),
    const _User(id: '3', name: 'Carol', role: 'Viewer'),
    const _User(id: '4', name: 'Dave', role: 'Viewer'),
    const _User(id: '5', name: 'Eve', role: 'Editor'),
    const _User(id: '6', name: 'Frank', role: 'Admin'),
  ];

  String _keyword = '';
  String? _roleFilter;
  TTableSort? _sort;
  Set<Object> _selected = {};
  var _dialogOpen = false;
  String _draftName = '';
  String _draftRole = 'Viewer';
  String? _editingId;
  var _page = 1;
  static const _pageSize = 5;

  List<_User> get _filtered {
    Iterable<_User> rows = _users;
    if (_keyword.isNotEmpty) {
      rows = rows.where(
        (user) => user.name.toLowerCase().contains(_keyword.toLowerCase()),
      );
    }
    if (_roleFilter != null) {
      rows = rows.where((user) => user.role == _roleFilter);
    }
    return rows.toList();
  }

  List<_User> get _paged {
    final all = _filtered;
    final start = (_page - 1) * _pageSize;
    if (start >= all.length) return const [];
    final end = (start + _pageSize).clamp(0, all.length);
    return all.sublist(start, end);
  }

  void _openCreate() {
    setState(() {
      _editingId = null;
      _draftName = '';
      _draftRole = 'Viewer';
      _dialogOpen = true;
    });
  }

  void _openEdit(_User user) {
    setState(() {
      _editingId = user.id;
      _draftName = user.name;
      _draftRole = user.role;
      _dialogOpen = true;
    });
  }

  void _save() {
    if (_draftName.trim().isEmpty) return;
    setState(() {
      if (_editingId == null) {
        _users.add(
          _User(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: _draftName.trim(),
            role: _draftRole,
          ),
        );
      } else {
        final index = _users.indexWhere((user) => user.id == _editingId);
        if (index >= 0) {
          _users[index] = _users[index].copyWith(
            name: _draftName.trim(),
            role: _draftRole,
          );
        }
      }
      _dialogOpen = false;
    });
  }

  void _deleteSelected() {
    setState(() {
      _users.removeWhere((user) => _selected.contains(user.id));
      _selected = {};
    });
  }

  @override
  Widget build(BuildContext context) {
    final rows = _paged;
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 220,
                  child: TInput(
                    value: _keyword,
                    placeholder: '搜索姓名',
                    onChanged: (value) => setState(() {
                      _keyword = value;
                      _page = 1;
                    }),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 160,
                  child: TSelect<String>(
                    value: _roleFilter,
                    placeholder: '角色筛选',
                    options: const ['Admin', 'Editor', 'Viewer'],
                    labelBuilder: (value) => value,
                    onChanged: (value) => setState(() {
                      _roleFilter = value;
                      _page = 1;
                    }),
                  ),
                ),
                const Spacer(),
                TSpace(
                  children: [
                    TButton(
                      theme: TButtonTheme.defaultTheme,
                      variant: TButtonVariant.outline,
                      onPressed: _selected.isEmpty ? null : _deleteSelected,
                      child: const Text('删除所选'),
                    ),
                    TButton(
                      theme: TButtonTheme.primary,
                      onPressed: _openCreate,
                      child: const Text('新建用户'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TTable<_User>(
                data: rows,
                rowKey: (user) => user.id,
                selectedKeys: _selected,
                onSelectionChanged: (keys) => setState(() => _selected = keys),
                sort: _sort,
                onSortChanged: (sort) => setState(() => _sort = sort),
                columns: [
                  TTableColumn<_User>(
                    id: 'name',
                    title: const Text('姓名'),
                    value: (user) => user.name,
                    width: 160,
                    sortable: true,
                  ),
                  TTableColumn<_User>(
                    id: 'role',
                    title: const Text('角色'),
                    value: (user) => user.role,
                    width: 120,
                    sortable: true,
                  ),
                ],
              ),
            ),
            Row(
              children: [
                TButton(
                  theme: TButtonTheme.defaultTheme,
                  variant: TButtonVariant.text,
                  onPressed: _selected.length == 1
                      ? () {
                          final id = _selected.first;
                          final user = _users.firstWhere(
                            (item) => item.id == id,
                          );
                          _openEdit(user);
                        }
                      : null,
                  child: const Text('编辑所选'),
                ),
                const Spacer(),
                TPagination(
                  total: _filtered.length,
                  pageSize: _pageSize,
                  current: _page,
                  onChanged: (page) => setState(() => _page = page),
                ),
              ],
            ),
          ],
        ),
        TDialog(
          visible: _dialogOpen,
          onVisibleChanged: (value) => setState(() => _dialogOpen = value),
          title: Text(_editingId == null ? '新建用户' : '编辑用户'),
          body: TForm(
            children: [
              TFormItem(
                label: '姓名',
                required: true,
                child: TInput(
                  value: _draftName,
                  placeholder: '姓名',
                  onChanged: (value) => setState(() => _draftName = value),
                ),
              ),
              TFormItem(
                label: '角色',
                child: TSelect<String>(
                  value: _draftRole,
                  options: const ['Admin', 'Editor', 'Viewer'],
                  labelBuilder: (value) => value,
                  onChanged: (value) {
                    if (value != null) setState(() => _draftRole = value);
                  },
                ),
              ),
            ],
          ),
          onConfirm: _save,
        ),
      ],
    );
  }
}
