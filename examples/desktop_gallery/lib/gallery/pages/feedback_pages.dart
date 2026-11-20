import 'package:flutter/widgets.dart';
import 'package:tdesign_flutter_core/tdesign_flutter_core.dart';
import 'package:tdesign_flutter_desktop/tdesign_flutter_desktop.dart';

import '../scaffold.dart';

class DialogDemoPage extends StatefulWidget {
  const DialogDemoPage({super.key});

  @override
  State<DialogDemoPage> createState() => _DialogDemoPageState();
}

class _DialogDemoPageState extends State<DialogDemoPage> {
  var _base = false;
  var _custom = false;
  var _content = false;
  var _note = '';

  @override
  Widget build(BuildContext context) {
    return GalleryPage(
      title: 'Dialog 对话框',
      source: 'components/dialog',
      children: [
        DemoSection(
          title: '基础对话框',
          child: TButton(
            theme: TButtonTheme.primary,
            onPressed: () => setState(() => _base = true),
            child: const Text('基础确认对话框'),
          ),
        ),
        DemoSection(
          title: '自定义按钮文案',
          child: TButton(
            theme: TButtonTheme.defaultTheme,
            variant: TButtonVariant.outline,
            onPressed: () => setState(() => _custom = true),
            child: const Text('打开对话框'),
          ),
        ),
        DemoSection(
          title: '自定义内容',
          child: TButton(
            theme: TButtonTheme.defaultTheme,
            variant: TButtonVariant.outline,
            onPressed: () => setState(() => _content = true),
            child: const Text('打开对话框'),
          ),
        ),
        if (_note.isNotEmpty) Text(_note),
        TDialog(
          visible: _base,
          onVisibleChanged: (value) => setState(() => _base = value),
          title: const Text('对话框标题'),
          body: const Text('这是弹框内容'),
          onConfirm: () => setState(() {
            _base = false;
            _note = '已确认基础对话框';
          }),
        ),
        TDialog(
          visible: _custom,
          confirmText: '知道了',
          cancelText: '关闭',
          onVisibleChanged: (value) => setState(() => _custom = value),
          title: const Text('自定义按钮'),
          body: const Text('确定与取消按钮使用自定义文案'),
          onConfirm: () => setState(() {
            _custom = false;
            _note = '已点击知道了';
          }),
        ),
        TDialog(
          visible: _content,
          onVisibleChanged: (value) => setState(() => _content = value),
          title: const Text('新建记录'),
          body: const SizedBox(width: 320, child: TInput(placeholder: '请输入名称')),
          onConfirm: () => setState(() {
            _content = false;
            _note = '已确认自定义内容';
          }),
        ),
      ],
    );
  }
}

class PopoverDemoPage extends StatelessWidget {
  const PopoverDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GalleryPage(
      title: 'Popover 弹出层',
      source: 'components/popup',
      children: [
        const DemoSection(
          title: '点击触发',
          child: TPopover(content: Text('弹出层内容'), child: DemoTrigger('点击弹出')),
        ),
        DemoSection(
          title: '弹出位置',
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 36),
            child: TSpace(
              size: 16,
              children: [
                for (final item in _placements)
                  TPopover(
                    placement: item.$1,
                    content: Text(item.$2),
                    child: DemoTrigger(item.$2),
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
  (TPlacement.bottom, 'bottom'),
  (TPlacement.left, 'left'),
  (TPlacement.right, 'right'),
  (TPlacement.topLeft, 'top-left'),
  (TPlacement.topRight, 'top-right'),
  (TPlacement.bottomLeft, 'bottom-left'),
  (TPlacement.bottomRight, 'bottom-right'),
];
