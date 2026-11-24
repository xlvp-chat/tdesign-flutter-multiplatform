import 'package:flutter/widgets.dart';

import 'pages/basic_pages.dart';
import 'pages/date_picker_page.dart';
import 'pages/date_range_picker_page.dart';
import 'pages/time_picker_page.dart';
import 'pages/data_pages.dart';
import 'pages/feedback_pages.dart';
import 'pages/gap_pages.dart';
import 'pages/input_pages.dart';
import 'pages/layout_pages.dart';
import 'pages/navigation_pages.dart';
import 'pages/scene_page.dart';
import 'pages/cascader_page.dart';
import 'pages/tree_page.dart';
import 'pages/tree_select_page.dart';
import 'pages/upload_page.dart';

class GalleryComponent {
  const GalleryComponent({
    required this.id,
    required this.title,
    required this.create,
  });

  final String id;
  final String title;
  final Widget Function() create;
}

class GalleryCategory {
  const GalleryCategory({required this.title, required this.components});

  final String title;
  final List<GalleryComponent> components;
}

/// Categories follow tdesign-vue-next site.config order.
/// Entries are the implemented Desktop P0 set, plus one composed scene.
const galleryCategories = <GalleryCategory>[
  GalleryCategory(
    title: '基础',
    components: [
      GalleryComponent(
        id: 'button',
        title: 'Button 按钮',
        create: ButtonDemoPage.new,
      ),
      GalleryComponent(id: 'link', title: 'Link 链接', create: LinkDemoPage.new),
      GalleryComponent(id: 'avatar', title: 'Avatar 头像', create: AvatarDemoPage.new),
    ],
  ),
  GalleryCategory(
    title: '布局',
    components: [
      GalleryComponent(
        id: 'divider',
        title: 'Divider 分割线',
        create: DividerDemoPage.new,
      ),
      GalleryComponent(
        id: 'space',
        title: 'Space 间距',
        create: SpaceDemoPage.new,
      ),
    ],
  ),
  GalleryCategory(
    title: '导航',
    components: [
      GalleryComponent(
        id: 'breadcrumb',
        title: 'Breadcrumb 面包屑',
        create: BreadcrumbDemoPage.new,
      ),
      GalleryComponent(
        id: 'dropdown',
        title: 'Dropdown 下拉菜单',
        create: DropdownDemoPage.new,
      ),
      GalleryComponent(
        id: 'menu',
        title: 'Menu 导航菜单',
        create: MenuDemoPage.new,
      ),
      GalleryComponent(
        id: 'pagination',
        title: 'Pagination 分页',
        create: PaginationDemoPage.new,
      ),
      GalleryComponent(id: 'tabs', title: 'Tabs 选项卡', create: TabsDemoPage.new),
      GalleryComponent(
        id: 'back-top',
        title: 'BackTop 回到顶部',
        create: BackTopDemoPage.new,
      ),
      GalleryComponent(
        id: 'steps',
        title: 'Steps 步骤条',
        create: StepsDemoPage.new,
      ),
    ],
  ),
  GalleryCategory(
    title: '输入',
    components: [
      GalleryComponent(
        id: 'cascader',
        title: 'Cascader 级联选择器',
        create: CascaderDemoPage.new,
      ),
      GalleryComponent(
        id: 'checkbox',
        title: 'Checkbox 多选框',
        create: CheckboxDemoPage.new,
      ),
      GalleryComponent(
        id: 'date-picker',
        title: 'DatePicker 日期选择器',
        create: DatePickerDemoPage.new,
      ),
      GalleryComponent(
        id: 'date-range-picker',
        title: 'DateRangePicker 日期区间选择器',
        create: DateRangePickerDemoPage.new,
      ),
      GalleryComponent(
        id: 'time-picker',
        title: 'TimePicker 时间选择器',
        create: TimePickerDemoPage.new,
      ),
      GalleryComponent(id: 'form', title: 'Form 表单', create: FormDemoPage.new),
      GalleryComponent(
        id: 'input',
        title: 'Input 输入框',
        create: InputDemoPage.new,
      ),
      GalleryComponent(
        id: 'input-number',
        title: 'InputNumber 数字输入框',
        create: InputNumberDemoPage.new,
      ),
      GalleryComponent(
        id: 'radio',
        title: 'Radio 单选框',
        create: RadioDemoPage.new,
      ),
      GalleryComponent(
        id: 'select',
        title: 'Select 选择器',
        create: SelectDemoPage.new,
      ),
      GalleryComponent(
        id: 'switch',
        title: 'Switch 开关',
        create: SwitchDemoPage.new,
      ),
      GalleryComponent(
        id: 'textarea',
        title: 'Textarea 多行文本框',
        create: TextareaDemoPage.new,
      ),
      GalleryComponent(
        id: 'tree-select',
        title: 'TreeSelect 树选择',
        create: TreeSelectDemoPage.new,
      ),
      GalleryComponent(
        id: 'upload',
        title: 'Upload 上传',
        create: UploadDemoPage.new,
      ),
    ],
  ),
  GalleryCategory(
    title: '数据展示',
    components: [
      GalleryComponent(
        id: 'badge',
        title: 'Badge 徽标',
        create: BadgeDemoPage.new,
      ),
      GalleryComponent(
        id: 'table',
        title: 'Table 表格',
        create: TableDemoPage.new,
      ),
      GalleryComponent(id: 'tag', title: 'Tag 标签', create: TagDemoPage.new),
      GalleryComponent(
        id: 'tooltip',
        title: 'Tooltip 文字提示',
        create: TooltipDemoPage.new,
      ),
      GalleryComponent(id: 'tree', title: 'Tree 树', create: TreeDemoPage.new),
      GalleryComponent(
        id: 'calendar',
        title: 'Calendar 日历',
        create: CalendarDemoPage.new,
      ),
      GalleryComponent(
        id: 'collapse',
        title: 'Collapse 折叠面板',
        create: CollapseDemoPage.new,
      ),
      GalleryComponent(
        id: 'empty',
        title: 'Empty 空状态',
        create: EmptyDemoPage.new,
      ),
      GalleryComponent(id: 'image', title: 'Image 图片', create: ImageDemoPage.new),
      GalleryComponent(
        id: 'progress',
        title: 'Progress 进度条',
        create: ProgressDemoPage.new,
      ),
      GalleryComponent(id: 'rate', title: 'Rate 评分', create: RateDemoPage.new),
      GalleryComponent(
        id: 'skeleton',
        title: 'Skeleton 骨架屏',
        create: SkeletonDemoPage.new,
      ),
      GalleryComponent(
        id: 'slider',
        title: 'Slider 滑块',
        create: SliderDemoPage.new,
      ),
      GalleryComponent(
        id: 'swiper',
        title: 'Swiper 轮播',
        create: SwiperDemoPage.new,
      ),
    ],
  ),
  GalleryCategory(
    title: '消息提醒',
    components: [
      GalleryComponent(
        id: 'dialog',
        title: 'Dialog 对话框',
        create: DialogDemoPage.new,
      ),
      GalleryComponent(
        id: 'popover',
        title: 'Popover 弹出层',
        create: PopoverDemoPage.new,
      ),
      GalleryComponent(
        id: 'drawer',
        title: 'Drawer 抽屉',
        create: DrawerDemoPage.new,
      ),
      GalleryComponent(
        id: 'image-viewer',
        title: 'ImageViewer 图片预览',
        create: ImageViewerDemoPage.new,
      ),
      GalleryComponent(
        id: 'loading',
        title: 'Loading 加载',
        create: LoadingDemoPage.new,
      ),
      GalleryComponent(
        id: 'message',
        title: 'Message 全局提示',
        create: MessageDemoPage.new,
      ),
    ],
  ),
  GalleryCategory(
    title: '场景',
    components: [
      GalleryComponent(id: 'scene', title: '用户管理', create: SceneDemoPage.new),
    ],
  ),
];

/// P0 components that must each have a gallery page.
const p0ComponentIds = <String>[
  'button',
  'link',
  'divider',
  'space',
  'tag',
  'badge',
  'input',
  'textarea',
  'input-number',
  'checkbox',
  'radio',
  'switch',
  'form',
  'tooltip',
  'popover',
  'dialog',
  'dropdown',
  'select',
  'tabs',
  'menu',
  'pagination',
  'breadcrumb',
  'table',
];

List<GalleryComponent> get galleryComponents => [
  for (final category in galleryCategories) ...category.components,
];
