import 'package:flutter/widgets.dart';
import 'package:tdesign_flutter_desktop/tdesign_flutter_desktop.dart';

import '../scaffold.dart';

const _demoItems = <TTreeNode>[
  TTreeNode(
    value: '1',
    label: '第一段',
    children: [
      TTreeNode(value: '1.1', label: '第二段'),
      TTreeNode(value: '1.2', label: '第二段'),
    ],
  ),
  TTreeNode(
    value: '2',
    label: '第一段',
    children: [
      TTreeNode(value: '2.1', label: '第二段'),
      TTreeNode(value: '2.2', label: '第二段'),
    ],
  ),
];

const _checkItems = <TTreeNode>[
  TTreeNode(
    value: '1',
    label: '1',
    children: [
      TTreeNode(
        value: '1.1',
        label: '1.1',
        children: [
          TTreeNode(value: '1.1.1', label: '1.1.1'),
          TTreeNode(value: '1.1.2', label: '1.1.2'),
        ],
      ),
      TTreeNode(value: '1.2', label: '1.2'),
    ],
  ),
];

class TreeDemoPage extends StatefulWidget {
  const TreeDemoPage({super.key});

  @override
  State<TreeDemoPage> createState() => _TreeDemoPageState();
}

class _TreeDemoPageState extends State<TreeDemoPage> {
  var _expanded = <String>{'1', '2'};
  var _actived = <String>{};
  var _checkExpanded = <String>{'1', '1.1'};
  var _checked = <String>{};

  @override
  Widget build(BuildContext context) {
    return GalleryPage(
      title: 'Tree 树',
      source: 'components/tree',
      children: [
        DemoSection(
          title: '基础树形结构',
          child: TTree(
            items: _demoItems,
            expandedKeys: _expanded,
            onExpandedKeysChanged: (value) {
              setState(() => _expanded = value);
            },
            activable: true,
            activedKeys: _actived,
            onActivedChanged: (value) {
              setState(() => _actived = value);
            },
          ),
        ),
        DemoSection(
          title: '可勾选',
          child: TTree(
            items: _checkItems,
            expandedKeys: _checkExpanded,
            onExpandedKeysChanged: (value) {
              setState(() => _checkExpanded = value);
            },
            checkable: true,
            checkedKeys: _checked,
            onCheckedChanged: (value) {
              setState(() => _checked = value);
            },
          ),
        ),
      ],
    );
  }
}
