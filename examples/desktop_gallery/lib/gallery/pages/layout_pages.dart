import 'package:flutter/widgets.dart';
import 'package:tdesign_flutter_desktop/tdesign_flutter_desktop.dart';

import '../scaffold.dart';

class DividerDemoPage extends StatelessWidget {
  const DividerDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const GalleryPage(
      title: 'Divider 分割线',
      source: 'components/divider',
      children: [
        DemoSection(
          title: '基础分割线',
          child: SizedBox(width: 360, child: TDivider()),
        ),
        DemoSection(
          title: '带缩进',
          child: SizedBox(
            width: 360,
            child: TDivider(indent: 24, endIndent: 24),
          ),
        ),
        DemoSection(
          title: '垂直分割线',
          child: SizedBox(
            height: 32,
            child: Row(
              children: [
                Text('文本'),
                SizedBox(width: 12),
                TDivider(vertical: true),
                SizedBox(width: 12),
                Text('文本'),
                SizedBox(width: 12),
                TDivider(vertical: true, thickness: 2),
                SizedBox(width: 12),
                Text('文本'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class SpaceDemoPage extends StatelessWidget {
  const SpaceDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GalleryPage(
      title: 'Space 间距',
      source: 'components/space',
      children: [
        const DemoSection(
          title: '基本用法',
          child: TSpace(
            children: [
              TButton(
                theme: TButtonTheme.primary,
                onPressed: _noop,
                child: Text('按钮'),
              ),
              TButton(
                theme: TButtonTheme.primary,
                onPressed: _noop,
                child: Text('按钮'),
              ),
              TButton(
                theme: TButtonTheme.primary,
                onPressed: _noop,
                child: Text('按钮'),
              ),
            ],
          ),
        ),
        const DemoSection(
          title: '垂直排列',
          child: TSpace(
            direction: Axis.vertical,
            crossAxisAlignment: WrapCrossAlignment.start,
            children: [
              TButton(
                theme: TButtonTheme.primary,
                onPressed: _noop,
                child: Text('按钮'),
              ),
              TButton(
                theme: TButtonTheme.primary,
                onPressed: _noop,
                child: Text('按钮'),
              ),
              TButton(
                theme: TButtonTheme.primary,
                onPressed: _noop,
                child: Text('按钮'),
              ),
            ],
          ),
        ),
        DemoSection(
          title: '间距大小',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final size in const [8.0, 16.0, 24.0]) ...[
                Text('${size.toInt()}px'),
                const SizedBox(height: 8),
                TSpace(
                  size: size,
                  children: const [
                    TButton(
                      theme: TButtonTheme.primary,
                      onPressed: _noop,
                      child: Text('按钮'),
                    ),
                    TButton(
                      theme: TButtonTheme.primary,
                      onPressed: _noop,
                      child: Text('按钮'),
                    ),
                    TButton(
                      theme: TButtonTheme.primary,
                      onPressed: _noop,
                      child: Text('按钮'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
        const DemoSection(
          title: '对齐方式',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 360,
                child: TSpace(
                  align: WrapAlignment.start,
                  children: [
                    TButton(
                      theme: TButtonTheme.primary,
                      onPressed: _noop,
                      child: Text('起点'),
                    ),
                    TButton(
                      theme: TButtonTheme.primary,
                      onPressed: _noop,
                      child: Text('起点'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8),
              SizedBox(
                width: 360,
                child: TSpace(
                  align: WrapAlignment.center,
                  children: [
                    TButton(
                      theme: TButtonTheme.primary,
                      onPressed: _noop,
                      child: Text('居中'),
                    ),
                    TButton(
                      theme: TButtonTheme.primary,
                      onPressed: _noop,
                      child: Text('居中'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8),
              SizedBox(
                width: 360,
                child: TSpace(
                  align: WrapAlignment.end,
                  children: [
                    TButton(
                      theme: TButtonTheme.primary,
                      onPressed: _noop,
                      child: Text('终点'),
                    ),
                    TButton(
                      theme: TButtonTheme.primary,
                      onPressed: _noop,
                      child: Text('终点'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const DemoSection(
          title: '自动换行',
          child: SizedBox(
            width: 220,
            child: TSpace(
              children: [
                TButton(
                  theme: TButtonTheme.primary,
                  onPressed: _noop,
                  child: Text('按钮一'),
                ),
                TButton(
                  theme: TButtonTheme.primary,
                  onPressed: _noop,
                  child: Text('按钮二'),
                ),
                TButton(
                  theme: TButtonTheme.primary,
                  onPressed: _noop,
                  child: Text('按钮三'),
                ),
                TButton(
                  theme: TButtonTheme.primary,
                  onPressed: _noop,
                  child: Text('按钮四'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

void _noop() {}
