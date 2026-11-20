import 'package:flutter/widgets.dart';
import 'package:tdesign_flutter_multi_desktop/tdesign_flutter_multi_desktop.dart';

import '../scaffold.dart';

class BreadcrumbDemoPage extends StatefulWidget {
  const BreadcrumbDemoPage({super.key});

  @override
  State<BreadcrumbDemoPage> createState() => _BreadcrumbDemoPageState();
}

class _BreadcrumbDemoPageState extends State<BreadcrumbDemoPage> {
  var _clicks = 0;

  @override
  Widget build(BuildContext context) {
    return GalleryPage(
      title: 'Breadcrumb 面包屑',
      source: 'components/breadcrumb',
      children: [
        const DemoSection(
          title: '基础面包屑',
          child: TBreadcrumb(
            items: [
              TBreadcrumbItem(label: Text('页面1')),
              TBreadcrumbItem(label: Text('页面2')),
              TBreadcrumbItem(label: Text('页面3')),
            ],
          ),
        ),
        const DemoSection(
          title: '自定义分隔符',
          child: TBreadcrumb(
            separator: '>',
            items: [
              TBreadcrumbItem(label: Text('首页')),
              TBreadcrumbItem(label: Text('组件')),
              TBreadcrumbItem(label: Text('面包屑')),
            ],
          ),
        ),
        DemoSection(
          title: '可点击',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TBreadcrumb(
                items: [
                  TBreadcrumbItem(
                    label: const Text('首页'),
                    onPressed: () => setState(() => _clicks += 1),
                  ),
                  TBreadcrumbItem(
                    label: const Text('页面1'),
                    onPressed: () => setState(() => _clicks += 1),
                  ),
                  const TBreadcrumbItem(label: Text('当前页')),
                ],
              ),
              const SizedBox(height: 12),
              Text('点击计数器：$_clicks'),
            ],
          ),
        ),
      ],
    );
  }
}

class DropdownDemoPage extends StatefulWidget {
  const DropdownDemoPage({super.key});

  @override
  State<DropdownDemoPage> createState() => _DropdownDemoPageState();
}

class _DropdownDemoPageState extends State<DropdownDemoPage> {
  String? _picked;
  String? _longPicked;

  @override
  Widget build(BuildContext context) {
    return GalleryPage(
      title: 'Dropdown 下拉菜单',
      source: 'components/dropdown',
      children: [
        DemoSection(
          title: '基础下拉菜单',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TDropdown(
                onSelected: (value) => setState(() => _picked = value),
                options: const [
                  TDropdownOption(value: '1', label: Text('操作一')),
                  TDropdownOption(value: '2', label: Text('操作二')),
                  TDropdownOption(value: '3', label: Text('操作三')),
                  TDropdownOption(value: '4', label: Text('操作四')),
                ],
                child: const DemoTrigger('更多'),
              ),
              const SizedBox(height: 12),
              Text(_picked == null ? '未选择' : '选中【$_picked】'),
            ],
          ),
        ),
        DemoSection(
          title: '较长菜单',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TDropdown(
                onSelected: (value) => setState(() => _longPicked = value),
                options: [
                  for (var i = 1; i <= 8; i++)
                    TDropdownOption(value: '$i', label: Text('操作$i')),
                ],
                child: const DemoTrigger('更多操作'),
              ),
              const SizedBox(height: 12),
              Text(_longPicked == null ? '未选择' : '选中【$_longPicked】'),
            ],
          ),
        ),
      ],
    );
  }
}

class MenuDemoPage extends StatefulWidget {
  const MenuDemoPage({super.key});

  @override
  State<MenuDemoPage> createState() => _MenuDemoPageState();
}

class _MenuDemoPageState extends State<MenuDemoPage> {
  var _side = 'dashboard';
  var _nested = 'mail-1';
  var _collapsed = false;
  var _collapsedValue = 'item1';
  var _wide = 'item2';
  var _top = 'home';
  var _dark = 'dashboard';

  @override
  Widget build(BuildContext context) {
    return GalleryPage(
      title: 'Menu 导航菜单',
      source: 'components/menu',
      children: [
        DemoSection(
          title: '侧边导航',
          child: _MenuFrame(
            child: TMenu(
              value: _side,
              onChanged: (value) => setState(() => _side = value),
              items: const [
                TMenuItem(value: 'dashboard', label: Text('仪表盘')),
                TMenuItem(value: 'resource', label: Text('资源列表')),
                TMenuItem(value: 'root', label: Text('根目录')),
                TMenuItem(value: 'monitor', label: Text('精准监控')),
                TMenuItem(value: 'message', label: Text('消息区')),
                TMenuItem(value: 'user', label: Text('个人中心')),
              ],
            ),
          ),
        ),
        DemoSection(
          title: '多级菜单',
          child: _MenuFrame(
            height: 360,
            child: TMenu(
              value: _nested,
              onChanged: (value) => setState(() => _nested = value),
              items: const [
                TMenuItem(
                  value: 'mail',
                  label: Text('消息区'),
                  children: [
                    TMenuItem(value: 'mail-1', label: Text('二级菜单内容')),
                    TMenuItem(
                      value: 'mail-sub',
                      label: Text('二级菜单'),
                      children: [
                        TMenuItem(value: 'mail-sub-1', label: Text('三级菜单内容')),
                        TMenuItem(value: 'mail-sub-2', label: Text('三级菜单内容')),
                      ],
                    ),
                    TMenuItem(value: 'mail-2', label: Text('二级菜单内容')),
                  ],
                ),
                TMenuItem(value: 'user', label: Text('个人中心')),
                TMenuItem(
                  value: 'video',
                  label: Text('视频区'),
                  children: [
                    TMenuItem(value: 'video-1', label: Text('二级菜单内容')),
                    TMenuItem(value: 'video-2', label: Text('二级菜单内容')),
                  ],
                ),
              ],
            ),
          ),
        ),
        DemoSection(
          title: '可收起',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TButton(
                theme: TButtonTheme.defaultTheme,
                variant: TButtonVariant.outline,
                onPressed: () => setState(() => _collapsed = !_collapsed),
                child: Text(_collapsed ? '展开' : '收起'),
              ),
              const SizedBox(height: 12),
              _MenuFrame(
                child: TMenu(
                  collapsed: _collapsed,
                  value: _collapsedValue,
                  onChanged: (value) => setState(() => _collapsedValue = value),
                  items: const [
                    TMenuItem(value: 'item1', label: Text('仪表盘')),
                    TMenuItem(
                      value: 'info',
                      label: Text('信息区'),
                      children: [
                        TMenuItem(value: 'info-1', label: Text('菜单内容一')),
                        TMenuItem(value: 'info-2', label: Text('菜单内容二')),
                      ],
                    ),
                    TMenuItem(value: 'user', label: Text('个人中心')),
                  ],
                ),
              ),
            ],
          ),
        ),
        DemoSection(
          title: '自定义宽度',
          child: _MenuFrame(
            child: TMenu(
              width: 200,
              value: _wide,
              onChanged: (value) => setState(() => _wide = value),
              items: const [
                TMenuItem(value: 'item1', label: Text('菜单内容')),
                TMenuItem(value: 'item2', label: Text('菜单内容')),
                TMenuItem(value: 'item3', label: Text('菜单内容')),
                TMenuItem(value: 'item4', label: Text('菜单内容')),
              ],
            ),
          ),
        ),
        DemoSection(
          title: '图标、暗色与顶栏',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TMenu(
                axis: TMenuAxis.horizontal,
                value: _top,
                onChanged: (value) => setState(() => _top = value),
                items: const [
                  TMenuItem(
                    value: 'home',
                    icon: Icon(TIcons.home),
                    label: Text('首页'),
                  ),
                  TMenuItem(
                    value: 'docs',
                    icon: Icon(TIcons.view_list),
                    label: Text('文档'),
                  ),
                  TMenuItem(
                    value: 'user',
                    icon: Icon(TIcons.user),
                    label: Text('个人中心'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _MenuFrame(
                height: 180,
                child: TMenu(
                  theme: TMenuTheme.dark,
                  value: _dark,
                  onChanged: (value) => setState(() => _dark = value),
                  items: const [
                    TMenuItem(
                      value: 'dashboard',
                      icon: Icon(
                        TIcons.circle,
                        size: 12,
                        color: Color(0xFFFFFFFF),
                      ),
                      label: Text('仪表盘'),
                    ),
                    TMenuItem(
                      value: 'resource',
                      icon: Icon(
                        TIcons.circle,
                        size: 12,
                        color: Color(0xFFFFFFFF),
                      ),
                      label: Text('资源列表'),
                    ),
                    TMenuItem(
                      value: 'message',
                      icon: Icon(
                        TIcons.circle,
                        size: 12,
                        color: Color(0xFFFFFFFF),
                      ),
                      label: Text('消息区'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class PaginationDemoPage extends StatefulWidget {
  const PaginationDemoPage({super.key});

  @override
  State<PaginationDemoPage> createState() => _PaginationDemoPageState();
}

class _PaginationDemoPageState extends State<PaginationDemoPage> {
  var _base = 1;
  var _totalPage = 12;
  var _jump = 1;
  var _pageSize = 10;
  var _sizedPage = 1;
  var _simple = 1;

  @override
  Widget build(BuildContext context) {
    return GalleryPage(
      title: 'Pagination 分页',
      source: 'components/pagination',
      children: [
        DemoSection(
          title: '基础分页',
          child: TPagination(
            total: 100,
            pageSize: 10,
            current: _base,
            onChanged: (page) => setState(() => _base = page),
          ),
        ),
        DemoSection(
          title: '极简分页',
          child: TPagination(
            total: 100,
            pageSize: 10,
            current: _simple,
            theme: TPaginationTheme.simple,
            onChanged: (page) => setState(() => _simple = page),
          ),
        ),
        DemoSection(
          title: '数据总数',
          child: TSpace(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text('共 685 项数据'),
              TPagination(
                total: 685,
                pageSize: 10,
                current: _totalPage,
                onChanged: (page) => setState(() => _totalPage = page),
              ),
            ],
          ),
        ),
        DemoSection(
          title: '页码跳转',
          child: TPagination(
            total: 100,
            pageSize: 10,
            current: _jump,
            showJumper: true,
            onChanged: (page) => setState(() => _jump = page),
          ),
        ),
        DemoSection(
          title: '每页条数',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('每页 $_pageSize 条，共 36 条'),
              const SizedBox(height: 8),
              TPagination(
                total: 36,
                pageSize: _pageSize,
                current: _sizedPage,
                onChanged: (page) => setState(() => _sizedPage = page),
                pageSizeOptions: TPagination.defaultPageSizeOptions,
                onPageSizeChanged: (size) {
                  setState(() {
                    _pageSize = size;
                    final pages = (36 + size - 1) ~/ size;
                    if (_sizedPage > pages) _sizedPage = pages;
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class TabsDemoPage extends StatefulWidget {
  const TabsDemoPage({super.key});

  @override
  State<TabsDemoPage> createState() => _TabsDemoPageState();
}

class _TabsDemoPageState extends State<TabsDemoPage> {
  var _value = '1';
  var _listValue = 'a';
  var _sideValue = '1';
  var _cardValue = '1';

  @override
  Widget build(BuildContext context) {
    return GalleryPage(
      title: 'Tabs 选项卡',
      source: 'components/tabs',
      children: [
        DemoSection(
          title: '基础选项卡',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TTabs(
                value: _value,
                onChanged: (value) => setState(() => _value = value),
                items: const [
                  TTabItem(value: '1', label: Text('选项卡1')),
                  TTabItem(value: '2', label: Text('选项卡2')),
                  TTabItem(value: '3', label: Text('选项卡3')),
                ],
              ),
              const SizedBox(height: 16),
              Text('选项卡$_value 的内容'),
            ],
          ),
        ),
        DemoSection(
          title: '列表定义',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TTabs(
                value: _listValue,
                onChanged: (value) => setState(() => _listValue = value),
                items: const [
                  TTabItem(value: 'a', label: Text('选项卡一')),
                  TTabItem(value: 'b', label: Text('选项卡二')),
                ],
              ),
              const SizedBox(height: 16),
              Text(_listValue == 'a' ? '这是选项卡一的内容' : '这是选项卡二的内容'),
            ],
          ),
        ),
        DemoSection(
          title: '卡片风格',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TTabs(
                theme: TTabsTheme.card,
                value: _cardValue,
                onChanged: (value) => setState(() => _cardValue = value),
                items: const [
                  TTabItem(value: '1', label: Text('选项卡1')),
                  TTabItem(value: '2', label: Text('选项卡2')),
                  TTabItem(value: '3', label: Text('选项卡3')),
                ],
              ),
              const SizedBox(height: 16),
              Text('卡片选项卡$_cardValue 的内容'),
            ],
          ),
        ),
        DemoSection(
          title: '左侧大尺寸',
          child: TTabs(
            placement: TTabPlacement.left,
            size: TTabsSize.large,
            value: _sideValue,
            onChanged: (value) => setState(() => _sideValue = value),
            items: const [
              TTabItem(value: '1', label: Text('选项卡1')),
              TTabItem(value: '2', label: Text('选项卡2')),
              TTabItem(value: '3', label: Text('选项卡3')),
            ],
          ),
        ),
      ],
    );
  }
}

class _MenuFrame extends StatelessWidget {
  const _MenuFrame({required this.child, this.height = 280});

  final Widget child;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height, child: child);
  }
}
