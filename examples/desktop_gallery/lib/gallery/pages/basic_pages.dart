import 'package:flutter/widgets.dart';
import 'package:tdesign_flutter_core/tdesign_flutter_core.dart';
import 'package:tdesign_flutter_desktop/tdesign_flutter_desktop.dart';

import '../scaffold.dart';

class ButtonDemoPage extends StatelessWidget {
  const ButtonDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const GalleryPage(
      title: 'Button 按钮',
      source: 'components/button',
      children: [
        DemoSection(
          title: '基础按钮',
          child: _VariantRow(theme: TButtonTheme.defaultTheme),
        ),
        DemoSection(
          title: '按钮主题',
          child: TSpace(
            direction: Axis.vertical,
            size: 16,
            crossAxisAlignment: WrapCrossAlignment.start,
            children: [
              _VariantRow(theme: TButtonTheme.defaultTheme),
              _VariantRow(theme: TButtonTheme.primary),
              _VariantRow(theme: TButtonTheme.danger),
              _VariantRow(theme: TButtonTheme.warning),
              _VariantRow(theme: TButtonTheme.success),
            ],
          ),
        ),
        DemoSection(title: '虚框按钮', child: _DashedThemes()),
        DemoSection(
          title: '幽灵按钮',
          child: TSpace(
            direction: Axis.vertical,
            size: 16,
            crossAxisAlignment: WrapCrossAlignment.start,
            children: [
              _VariantRow(
                theme: TButtonTheme.defaultTheme,
                ghost: true,
                variants: _ghostVariants,
              ),
              _VariantRow(
                theme: TButtonTheme.primary,
                ghost: true,
                variants: _ghostVariants,
              ),
              _VariantRow(
                theme: TButtonTheme.success,
                ghost: true,
                variants: _ghostVariants,
              ),
              _VariantRow(
                theme: TButtonTheme.warning,
                ghost: true,
                variants: _ghostVariants,
              ),
              _VariantRow(
                theme: TButtonTheme.danger,
                ghost: true,
                variants: _ghostVariants,
              ),
            ],
          ),
        ),
        DemoSection(
          title: '按钮形状',
          child: TSpace(
            direction: Axis.vertical,
            size: 16,
            crossAxisAlignment: WrapCrossAlignment.start,
            children: [
              _ShapeRow(
                theme: TButtonTheme.primary,
                variant: TButtonVariant.base,
              ),
              _ShapeRow(variant: TButtonVariant.outline),
              _ShapeRow(variant: TButtonVariant.dashed),
              _ShapeRow(variant: TButtonVariant.text),
            ],
          ),
        ),
        DemoSection(
          title: '按钮尺寸',
          child: TSpace(
            direction: Axis.vertical,
            size: 16,
            crossAxisAlignment: WrapCrossAlignment.start,
            children: [
              _SizeRow(TComponentSize.small),
              _SizeRow(TComponentSize.medium),
              _SizeRow(TComponentSize.large),
            ],
          ),
        ),
        DemoSection(
          title: '加载中状态',
          child: TSpace(
            size: 16,
            children: [
              TButton(
                theme: TButtonTheme.primary,
                loading: true,
                onPressed: _noop,
                child: Text('加载中'),
              ),
              TButton(
                theme: TButtonTheme.defaultTheme,
                variant: TButtonVariant.outline,
                loading: true,
                onPressed: _noop,
                child: Text('加载中'),
              ),
            ],
          ),
        ),
        DemoSection(
          title: '图标按钮',
          child: TSpace(
            size: 16,
            children: [
              TButton(
                theme: TButtonTheme.primary,
                icon: Text('+'),
                onPressed: _noop,
                child: Text('新建'),
              ),
              TButton(
                theme: TButtonTheme.defaultTheme,
                variant: TButtonVariant.outline,
                suffix: Text('›'),
                onPressed: _noop,
                child: Text('下一步'),
              ),
            ],
          ),
        ),
        DemoSection(
          title: '通栏按钮',
          child: SizedBox(
            width: 320,
            child: TButton(
              block: true,
              theme: TButtonTheme.primary,
              onPressed: _noop,
              child: Text('通栏按钮'),
            ),
          ),
        ),
        DemoSection(
          title: '链接按钮',
          child: TButton(
            theme: TButtonTheme.primary,
            variant: TButtonVariant.text,
            href: 'https://tdesign.tencent.com/',
            onPressed: _noop,
            child: Text('TDesign 官网'),
          ),
        ),
        DemoSection(
          title: '禁用状态',
          child: TSpace(
            size: 16,
            children: [
              TButton(theme: TButtonTheme.primary, child: Text('填充按钮')),
              TButton(
                theme: TButtonTheme.defaultTheme,
                variant: TButtonVariant.outline,
                child: Text('描边按钮'),
              ),
              TButton(
                theme: TButtonTheme.defaultTheme,
                variant: TButtonVariant.dashed,
                child: Text('虚框按钮'),
              ),
              TButton(
                theme: TButtonTheme.defaultTheme,
                variant: TButtonVariant.text,
                child: Text('文字按钮'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

const _ghostVariants = <TButtonVariant>[
  TButtonVariant.outline,
  TButtonVariant.dashed,
  TButtonVariant.text,
];

class _VariantRow extends StatelessWidget {
  const _VariantRow({
    required this.theme,
    this.ghost = false,
    this.variants = const <TButtonVariant>[
      TButtonVariant.base,
      TButtonVariant.outline,
      TButtonVariant.dashed,
      TButtonVariant.text,
    ],
  });

  final TButtonTheme theme;
  final bool ghost;
  final List<TButtonVariant> variants;

  @override
  Widget build(BuildContext context) {
    return TSpace(
      size: 16,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final variant in variants)
          TButton(
            theme: theme,
            variant: variant,
            ghost: ghost,
            onPressed: _noop,
            child: Text(ghost ? '幽灵按钮' : _variantLabel(variant)),
          ),
      ],
    );
  }
}

class _DashedThemes extends StatelessWidget {
  const _DashedThemes();

  @override
  Widget build(BuildContext context) {
    return const TSpace(
      size: 16,
      children: [
        TButton(
          theme: TButtonTheme.defaultTheme,
          variant: TButtonVariant.dashed,
          onPressed: _noop,
          child: Text('虚框按钮'),
        ),
        TButton(
          theme: TButtonTheme.primary,
          variant: TButtonVariant.dashed,
          onPressed: _noop,
          child: Text('虚框按钮'),
        ),
        TButton(
          theme: TButtonTheme.danger,
          variant: TButtonVariant.dashed,
          onPressed: _noop,
          child: Text('虚框按钮'),
        ),
        TButton(
          theme: TButtonTheme.warning,
          variant: TButtonVariant.dashed,
          onPressed: _noop,
          child: Text('虚框按钮'),
        ),
        TButton(
          theme: TButtonTheme.success,
          variant: TButtonVariant.dashed,
          onPressed: _noop,
          child: Text('虚框按钮'),
        ),
      ],
    );
  }
}

class _ShapeRow extends StatelessWidget {
  const _ShapeRow({
    required this.variant,
    this.theme = TButtonTheme.defaultTheme,
  });

  final TButtonVariant variant;
  final TButtonTheme theme;

  @override
  Widget build(BuildContext context) {
    return TSpace(
      size: 16,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final shape in TButtonShape.values)
          TButton(
            theme: theme,
            variant: variant,
            shape: shape,
            onPressed: _noop,
            child: Text(_shapeLabel(shape, variant)),
          ),
      ],
    );
  }
}

class _SizeRow extends StatelessWidget {
  const _SizeRow(this.size);

  final TComponentSize size;

  @override
  Widget build(BuildContext context) {
    return TSpace(
      size: 16,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        TButton(
          theme: TButtonTheme.primary,
          size: size,
          onPressed: _noop,
          child: const Text('填充按钮'),
        ),
        TButton(
          theme: TButtonTheme.defaultTheme,
          variant: TButtonVariant.outline,
          size: size,
          onPressed: _noop,
          child: const Text('描边按钮'),
        ),
        TButton(
          theme: TButtonTheme.defaultTheme,
          variant: TButtonVariant.dashed,
          size: size,
          onPressed: _noop,
          child: const Text('虚框按钮'),
        ),
        TButton(
          theme: TButtonTheme.defaultTheme,
          variant: TButtonVariant.text,
          size: size,
          onPressed: _noop,
          child: const Text('文字按钮'),
        ),
      ],
    );
  }
}

String _variantLabel(TButtonVariant variant) {
  return switch (variant) {
    TButtonVariant.base => '填充按钮',
    TButtonVariant.outline => '描边按钮',
    TButtonVariant.dashed => '虚框按钮',
    TButtonVariant.text => '文字按钮',
  };
}

String _shapeLabel(TButtonShape shape, TButtonVariant variant) {
  if (shape == TButtonShape.square || shape == TButtonShape.circle) {
    return '+';
  }
  return _variantLabel(variant);
}

class LinkDemoPage extends StatelessWidget {
  const LinkDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const GalleryPage(
      title: 'Link 链接',
      source: 'components/link',
      children: [
        DemoSection(
          title: '不同主题',
          child: TSpace(
            size: 16,
            children: [
              TLink(
                theme: TLinkTheme.defaultTheme,
                onPressed: _noop,
                child: Text('跳转链接'),
              ),
              TLink(onPressed: _noop, child: Text('跳转链接')),
              TLink(
                theme: TLinkTheme.danger,
                onPressed: _noop,
                child: Text('跳转链接'),
              ),
              TLink(
                theme: TLinkTheme.warning,
                onPressed: _noop,
                child: Text('跳转链接'),
              ),
              TLink(
                theme: TLinkTheme.success,
                onPressed: _noop,
                child: Text('跳转链接'),
              ),
            ],
          ),
        ),
        DemoSection(
          title: '下划线',
          child: TSpace(
            size: 16,
            children: [
              TLink(underline: true, onPressed: _noop, child: Text('带下划线')),
              TLink(underline: false, onPressed: _noop, child: Text('无下划线')),
            ],
          ),
        ),
        DemoSection(
          title: '禁用状态',
          child: TSpace(
            size: 16,
            children: [
              TLink(disabled: true, child: Text('禁用链接')),
              TLink(
                theme: TLinkTheme.danger,
                disabled: true,
                child: Text('禁用链接'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

void _noop() {}
