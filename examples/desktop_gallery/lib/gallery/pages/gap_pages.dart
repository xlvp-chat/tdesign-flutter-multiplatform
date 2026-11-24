import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:tdesign_flutter_multi_desktop/tdesign_flutter_multi_desktop.dart';

import '../scaffold.dart';

class AvatarDemoPage extends StatelessWidget {
  const AvatarDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const GalleryPage(
      title: 'Avatar 头像',
      source: 'components/avatar',
      children: [
        DemoSection(
          title: '尺寸与形状',
          child: TSpace(
            size: 16,
            children: [
              TAvatar(size: TAvatarSize.small, child: Text('A')),
              TAvatar(child: Text('B')),
              TAvatar(size: TAvatarSize.large, shape: TAvatarShape.round, child: Text('C')),
              TAvatar(icon: TIcon(TIcons.user)),
            ],
          ),
        ),
        DemoSection(
          title: '头像组',
          child: TAvatarGroup(
            max: 3,
            children: [
              TAvatar(child: Text('1')),
              TAvatar(child: Text('2')),
              TAvatar(child: Text('3')),
              TAvatar(child: Text('4')),
            ],
          ),
        ),
      ],
    );
  }
}

class BackTopDemoPage extends StatefulWidget {
  const BackTopDemoPage({super.key});

  @override
  State<BackTopDemoPage> createState() => _BackTopDemoPageState();
}

class _BackTopDemoPageState extends State<BackTopDemoPage> {
  final _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GalleryPage(
      title: 'BackTop 回到顶部',
      source: 'components/back-top',
      children: [
        DemoSection(
          title: '滚动后出现',
          child: SizedBox(
            height: 240,
            child: Stack(
              children: [
                ListView(
                  controller: _controller,
                  children: [
                    for (var i = 0; i < 20; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text('第 ${i + 1} 行'),
                      ),
                  ],
                ),
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: TBackTop(controller: _controller, visibilityHeight: 40),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class CalendarDemoPage extends StatefulWidget {
  const CalendarDemoPage({super.key});

  @override
  State<CalendarDemoPage> createState() => _CalendarDemoPageState();
}

class _CalendarDemoPageState extends State<CalendarDemoPage> {
  DateTime? _value = DateTime(2026, 11, 22);

  @override
  Widget build(BuildContext context) {
    return GalleryPage(
      title: 'Calendar 日历',
      source: 'components/calendar',
      children: [
        DemoSection(
          title: '月视图',
          child: TCalendar(
            value: _value,
            onChanged: (value) => setState(() => _value = value),
          ),
        ),
      ],
    );
  }
}

class CollapseDemoPage extends StatefulWidget {
  const CollapseDemoPage({super.key});

  @override
  State<CollapseDemoPage> createState() => _CollapseDemoPageState();
}

class _CollapseDemoPageState extends State<CollapseDemoPage> {
  var _value = const <int>[0];

  @override
  Widget build(BuildContext context) {
    return GalleryPage(
      title: 'Collapse 折叠面板',
      source: 'components/collapse',
      children: [
        DemoSection(
          title: '基础',
          child: TCollapse(
            value: _value,
            onChanged: (value) => setState(() => _value = value),
            panels: const [
              TCollapsePanel(title: '面板一', child: Text('第一段内容')),
              TCollapsePanel(title: '面板二', child: Text('第二段内容')),
            ],
          ),
        ),
      ],
    );
  }
}

class DrawerDemoPage extends StatefulWidget {
  const DrawerDemoPage({super.key});

  @override
  State<DrawerDemoPage> createState() => _DrawerDemoPageState();
}

class _DrawerDemoPageState extends State<DrawerDemoPage> {
  var _visible = false;

  @override
  Widget build(BuildContext context) {
    return GalleryPage(
      title: 'Drawer 抽屉',
      source: 'components/drawer',
      children: [
        DemoSection(
          title: '右侧抽屉',
          child: TSpace(
            children: [
              TButton(
                onPressed: () => setState(() => _visible = true),
                child: const Text('打开抽屉'),
              ),
              TDrawer(
                visible: _visible,
                header: const Text('标题'),
                body: const Text('抽屉内容'),
                onVisibleChanged: (value) => setState(() => _visible = value),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class EmptyDemoPage extends StatelessWidget {
  const EmptyDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const GalleryPage(
      title: 'Empty 空状态',
      source: 'components/empty',
      children: [
        DemoSection(
          title: '基础',
          child: TEmpty(title: '暂无数据', description: '可以先去创建一条记录'),
        ),
        DemoSection(
          title: '成功',
          child: TEmpty(
            type: TEmptyType.success,
            title: '成功',
            description: '操作已完成',
          ),
        ),
      ],
    );
  }
}

class ImageDemoPage extends StatelessWidget {
  const ImageDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const GalleryPage(
      title: 'Image 图片',
      source: 'components/image',
      children: [
        DemoSection(
          title: '加载失败占位',
          child: TImage(width: 120, height: 80, alt: '加载失败'),
        ),
      ],
    );
  }
}

class ImageViewerDemoPage extends StatefulWidget {
  const ImageViewerDemoPage({super.key});

  @override
  State<ImageViewerDemoPage> createState() => _ImageViewerDemoPageState();
}

class _ImageViewerDemoPageState extends State<ImageViewerDemoPage> {
  var _visible = false;
  var _index = 0;
  final _images = <ImageProvider>[
    MemoryImage(_pixel),
    MemoryImage(_pixel),
  ];

  @override
  Widget build(BuildContext context) {
    return GalleryPage(
      title: 'ImageViewer 图片预览',
      source: 'components/image-viewer',
      children: [
        DemoSection(
          title: '多图预览',
          child: TSpace(
            children: [
              TButton(
                onPressed: () => setState(() => _visible = true),
                child: const Text('预览'),
              ),
              TImageViewer(
                visible: _visible,
                index: _index,
                images: _images,
                onVisibleChanged: (value) => setState(() => _visible = value),
                onIndexChanged: (value) => setState(() => _index = value),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

final Uint8List _pixel = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
);

class LoadingDemoPage extends StatelessWidget {
  const LoadingDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const GalleryPage(
      title: 'Loading 加载',
      source: 'components/loading',
      children: [
        DemoSection(
          title: '包裹内容',
          child: SizedBox(
            width: 240,
            height: 80,
            child: TLoading(
              text: '加载中',
              child: SizedBox.expand(),
            ),
          ),
        ),
      ],
    );
  }
}

class MessageDemoPage extends StatelessWidget {
  const MessageDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GalleryPage(
      title: 'Message 全局提示',
      source: 'components/message',
      children: [
        DemoSection(
          title: '主题',
          child: TSpace(
            children: [
              TButton(
                onPressed: () => TMessage.show(context, content: '这是一条消息'),
                child: const Text('信息'),
              ),
              TButton(
                onPressed: () => TMessage.show(
                  context,
                  content: '已保存',
                  theme: TMessageTheme.success,
                ),
                child: const Text('成功'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ProgressDemoPage extends StatelessWidget {
  const ProgressDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const GalleryPage(
      title: 'Progress 进度条',
      source: 'components/progress',
      children: [
        DemoSection(
          title: '线形',
          child: SizedBox(width: 240, child: TProgress(percentage: 40)),
        ),
        DemoSection(
          title: '环形',
          child: TProgress(percentage: 70, theme: TProgressTheme.circle),
        ),
      ],
    );
  }
}

class RateDemoPage extends StatefulWidget {
  const RateDemoPage({super.key});

  @override
  State<RateDemoPage> createState() => _RateDemoPageState();
}

class _RateDemoPageState extends State<RateDemoPage> {
  var _value = 3;

  @override
  Widget build(BuildContext context) {
    return GalleryPage(
      title: 'Rate 评分',
      source: 'components/rate',
      children: [
        DemoSection(
          title: '基础',
          child: TRate(
            value: _value,
            onChanged: (value) => setState(() => _value = value),
          ),
        ),
      ],
    );
  }
}

class SkeletonDemoPage extends StatelessWidget {
  const SkeletonDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const GalleryPage(
      title: 'Skeleton 骨架屏',
      source: 'components/skeleton',
      children: [
        DemoSection(
          title: '加载占位',
          child: SizedBox(width: 280, child: TSkeleton()),
        ),
      ],
    );
  }
}

class SliderDemoPage extends StatefulWidget {
  const SliderDemoPage({super.key});

  @override
  State<SliderDemoPage> createState() => _SliderDemoPageState();
}

class _SliderDemoPageState extends State<SliderDemoPage> {
  var _value = 30.0;

  @override
  Widget build(BuildContext context) {
    return GalleryPage(
      title: 'Slider 滑块',
      source: 'components/slider',
      children: [
        DemoSection(
          title: '基础',
          child: SizedBox(
            width: 280,
            child: TSlider(
              value: _value,
              onChanged: (value) => setState(() => _value = value),
            ),
          ),
        ),
      ],
    );
  }
}

class StepsDemoPage extends StatelessWidget {
  const StepsDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const GalleryPage(
      title: 'Steps 步骤条',
      source: 'components/steps',
      children: [
        DemoSection(
          title: '基础',
          child: TSteps(
            current: 1,
            items: [
              TStepItem(title: '填写信息', content: '已完成'),
              TStepItem(title: '确认订单', content: '进行中'),
              TStepItem(title: '完成', content: '未开始'),
            ],
          ),
        ),
      ],
    );
  }
}

class SwiperDemoPage extends StatelessWidget {
  const SwiperDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const GalleryPage(
      title: 'Swiper 轮播',
      source: 'components/swiper',
      children: [
        DemoSection(
          title: '基础',
          child: TSwiper(
            children: [
              ColoredBox(color: Color(0xFFF2F3FF), child: Center(child: Text('1'))),
              ColoredBox(color: Color(0xFFE3F9E9), child: Center(child: Text('2'))),
              ColoredBox(color: Color(0xFFFFF1E9), child: Center(child: Text('3'))),
            ],
          ),
        ),
      ],
    );
  }
}
