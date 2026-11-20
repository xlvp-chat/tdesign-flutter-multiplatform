import 'package:flutter/widgets.dart';
import 'package:tdesign_flutter_desktop/tdesign_flutter_desktop.dart';

import '../scaffold.dart';

const _options = <TCascaderOption>[
  TCascaderOption(
    value: '1',
    label: '选项一',
    children: [
      TCascaderOption(value: '1.1', label: '子选项一'),
      TCascaderOption(value: '1.2', label: '子选项二'),
      TCascaderOption(value: '1.3', label: '子选项三'),
    ],
  ),
  TCascaderOption(
    value: '2',
    label: '选项二',
    children: [
      TCascaderOption(value: '2.1', label: '子选项一'),
      TCascaderOption(value: '2.2', label: '子选项二'),
    ],
  ),
];

class CascaderDemoPage extends StatefulWidget {
  const CascaderDemoPage({super.key});

  @override
  State<CascaderDemoPage> createState() => _CascaderDemoPageState();
}

class _CascaderDemoPageState extends State<CascaderDemoPage> {
  String? _value = '1.1';
  String? _leafOnly;

  @override
  Widget build(BuildContext context) {
    return GalleryPage(
      title: 'Cascader 级联选择器',
      source: 'components/cascader',
      children: [
        DemoSection(
          title: '基础级联选择器',
          child: SizedBox(
            width: 280,
            child: TCascader(
              options: _options,
              value: _value,
              clearable: true,
              onChanged: (value) => setState(() => _value = value),
            ),
          ),
        ),
        DemoSection(
          title: '只显示最后一级',
          child: SizedBox(
            width: 280,
            child: TCascader(
              options: _options,
              value: _leafOnly,
              showAllLevels: false,
              clearable: true,
              placeholder: '请选择地区',
              onChanged: (value) => setState(() => _leafOnly = value),
            ),
          ),
        ),
      ],
    );
  }
}
