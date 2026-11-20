import 'package:flutter/widgets.dart';
import 'package:tdesign_flutter_desktop/tdesign_flutter_desktop.dart';

import '../scaffold.dart';

const _items = <TTreeNode>[
  TTreeNode(
    value: 'guangdong',
    label: '广东省',
    children: [
      TTreeNode(value: 'guangzhou', label: '广州市'),
      TTreeNode(value: 'shenzhen', label: '深圳市'),
    ],
  ),
  TTreeNode(
    value: 'jiangsu',
    label: '江苏省',
    disabled: true,
    children: [
      TTreeNode(value: 'nanjing', label: '南京市'),
      TTreeNode(value: 'suzhou', label: '苏州市'),
    ],
  ),
];

class TreeSelectDemoPage extends StatefulWidget {
  const TreeSelectDemoPage({super.key});

  @override
  State<TreeSelectDemoPage> createState() => _TreeSelectDemoPageState();
}

class _TreeSelectDemoPageState extends State<TreeSelectDemoPage> {
  String? _value;

  @override
  Widget build(BuildContext context) {
    return GalleryPage(
      title: 'TreeSelect 树选择',
      source: 'components/tree-select',
      children: [
        DemoSection(
          title: '基础树选择',
          child: SizedBox(
            width: 280,
            child: TTreeSelect(
              items: _items,
              value: _value,
              clearable: true,
              onChanged: (value) => setState(() => _value = value),
            ),
          ),
        ),
      ],
    );
  }
}
