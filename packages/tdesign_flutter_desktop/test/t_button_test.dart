import 'package:flutter/gestures.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tdesign_flutter_core/tdesign_flutter_core.dart';
import 'package:tdesign_flutter_desktop/tdesign_flutter_desktop.dart';

void main() {
  testWidgets('outline draws a 1px theme-colored border', (tester) async {
    await tester.pumpWidget(
      _host(
        const Column(
          children: [
            TButton(
              variant: TButtonVariant.outline,
              onPressed: _noop,
              child: Text('默认描边'),
            ),
            TButton(
              theme: TButtonTheme.primary,
              variant: TButtonVariant.outline,
              onPressed: _noop,
              child: Text('品牌描边'),
            ),
          ],
        ),
      ),
    );

    final neutral = _decoration(tester, _button('默认描边'));
    expect(neutral.color, const Color(0x00000000));
    expect(
      neutral.border,
      Border.all(color: _token('textColorPrimary'), width: 1),
    );
    expect(_labelColor(tester, _button('默认描边')), _token('textColorPrimary'));

    final brand = _decoration(tester, _button('品牌描边'));
    expect(brand.color, const Color(0x00000000));
    expect(brand.border, Border.all(color: _token('brandColor7'), width: 1));
    expect(_labelColor(tester, _button('品牌描边')), _token('brandColor7'));
    expect(_dashedPaint(_button('品牌描边')), findsNothing);
  });

  testWidgets('dashed border leaves gaps in the theme color', (tester) async {
    await tester.pumpWidget(
      _host(
        const TButton(
          theme: TButtonTheme.primary,
          variant: TButtonVariant.dashed,
          onPressed: _noop,
          child: Text('虚框'),
        ),
      ),
    );

    final decoration = _decoration(tester, find.byType(TButton));
    expect(decoration.color, const Color(0x00000000));
    expect(decoration.border, isNull);
    expect(_labelColor(tester, find.byType(TButton)), _token('brandColor7'));
    _expectDashed(tester, find.byType(TButton), _token('brandColor7'));

    await tester.pumpWidget(
      _host(
        const TButton(
          theme: TButtonTheme.danger,
          variant: TButtonVariant.dashed,
          onPressed: _noop,
          child: Text('虚框'),
        ),
      ),
    );
    expect(_labelColor(tester, find.byType(TButton)), _token('errorColor6'));
    _expectDashed(tester, find.byType(TButton), _token('errorColor6'));
  });

  testWidgets('ghost uses a transparent background and theme color', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const Column(
          children: [
            TButton(
              theme: TButtonTheme.primary,
              ghost: true,
              onPressed: _noop,
              child: Text('幽灵填充'),
            ),
            TButton(
              theme: TButtonTheme.warning,
              variant: TButtonVariant.outline,
              ghost: true,
              onPressed: _noop,
              child: Text('幽灵描边'),
            ),
            TButton(
              theme: TButtonTheme.success,
              variant: TButtonVariant.dashed,
              ghost: true,
              onPressed: _noop,
              child: Text('幽灵虚线'),
            ),
          ],
        ),
      ),
    );

    final filled = _decoration(tester, _button('幽灵填充'));
    expect(filled.color, const Color(0x00000000));
    expect(filled.border, isNull);
    expect(_labelColor(tester, _button('幽灵填充')), _token('brandColor7'));

    final outline = _decoration(tester, _button('幽灵描边'));
    expect(outline.color, const Color(0x00000000));
    expect(
      outline.border,
      Border.all(color: _token('warningColor5'), width: 1),
    );
    expect(_labelColor(tester, _button('幽灵描边')), _token('warningColor5'));

    final dashed = _decoration(tester, _button('幽灵虚线'));
    expect(dashed.color, const Color(0x00000000));
    expect(dashed.border, isNull);
    expect(_labelColor(tester, _button('幽灵虚线')), _token('successColor5'));
    expect(_dashedPaint(_button('幽灵虚线')), findsOneWidget);
  });

  testWidgets('filled themes use token colors and the fill interaction', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const Column(
          children: [
            TButton(onPressed: _noop, child: Text('默认填充')),
            TButton(
              theme: TButtonTheme.primary,
              onPressed: _noop,
              child: Text('品牌填充'),
            ),
            TButton(
              theme: TButtonTheme.danger,
              onPressed: _noop,
              child: Text('危险填充'),
            ),
            TButton(
              theme: TButtonTheme.warning,
              onPressed: _noop,
              child: Text('警告填充'),
            ),
            TButton(
              theme: TButtonTheme.success,
              onPressed: _noop,
              child: Text('成功填充'),
            ),
          ],
        ),
      ),
    );

    final neutral = _decoration(tester, _button('默认填充'));
    expect(neutral.color, _token('bgColorContainer'));
    expect(_labelColor(tester, _button('默认填充')), _token('textColorPrimary'));

    expect(_decoration(tester, _button('品牌填充')).color, _token('brandColor7'));
    expect(_labelColor(tester, _button('品牌填充')), const Color(0xFFFFFFFF));
    expect(_decoration(tester, _button('危险填充')).color, _token('errorColor6'));
    expect(_decoration(tester, _button('警告填充')).color, _token('warningColor5'));
    expect(_decoration(tester, _button('成功填充')).color, _token('successColor5'));
    expect(_labelColor(tester, _button('成功填充')), const Color(0xFFFFFFFF));

    final base = _token('brandColor7');
    tester.binding.focusManager.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional;
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: tester.getCenter(_button('品牌填充')));
    await tester.pump();
    expect(
      _decoration(tester, _button('品牌填充')).color,
      Color.lerp(base, const Color(0xFFFFFFFF), 0.08),
    );

    await gesture.down(tester.getCenter(_button('品牌填充')));
    await tester.pump();
    expect(
      _decoration(tester, _button('品牌填充')).color,
      Color.lerp(base, const Color(0xFF000000), 0.12),
    );
    await gesture.up();
    await gesture.removePointer();

    await tester.pumpWidget(
      _host(const TButton(theme: TButtonTheme.primary, child: Text('禁用填充'))),
    );
    expect(
      _decoration(tester, find.byType(TButton)).color,
      base.withValues(alpha: 0.4),
    );

    await tester.pumpWidget(
      _host(
        const TButton(
          theme: TButtonTheme.primary,
          loading: true,
          onPressed: _noop,
          child: Text('加载填充'),
        ),
      ),
    );
    expect(
      _decoration(tester, find.byType(TButton)).color,
      base.withValues(alpha: 0.4),
    );
  });

  testWidgets('defaultTheme hover uses bgColorContainerHover', (tester) async {
    await tester.pumpWidget(
      _host(const TButton(onPressed: _noop, child: Text('默认填充'))),
    );
    expect(
      _decoration(tester, find.byType(TButton)).color,
      _token('bgColorContainer'),
    );

    tester.binding.focusManager.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional;
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: tester.getCenter(find.byType(TButton)));
    await tester.pump();
    expect(
      _decoration(tester, find.byType(TButton)).color,
      _token('bgColorContainerHover'),
    );
    await gesture.removePointer();
  });

  testWidgets('button colors follow the inherited token scope', (tester) async {
    await tester.pumpWidget(
      _host(
        const TDesignTokenScope(
          tokens: TDesignTokens.dark,
          child: TButton(onPressed: _noop, child: Text('暗色填充')),
        ),
      ),
    );

    expect(
      _decoration(tester, find.byType(TButton)).color,
      _tokenFrom(TDesignTokens.dark, 'bgColorContainer'),
    );
    expect(
      _labelColor(tester, find.byType(TButton)),
      _tokenFrom(TDesignTokens.dark, 'textColorPrimary'),
    );
  });

  testWidgets('square and circle widths match the size height', (tester) async {
    await tester.pumpWidget(
      _host(
        const Row(
          children: [
            TButton(
              theme: TButtonTheme.primary,
              shape: TButtonShape.square,
              size: TComponentSize.small,
              onPressed: _noop,
              child: Text('小方'),
            ),
            TButton(
              theme: TButtonTheme.primary,
              shape: TButtonShape.square,
              onPressed: _noop,
              child: Text('中方'),
            ),
            TButton(
              theme: TButtonTheme.primary,
              shape: TButtonShape.circle,
              size: TComponentSize.large,
              onPressed: _noop,
              child: Text('大圆'),
            ),
            TButton(
              theme: TButtonTheme.primary,
              shape: TButtonShape.circle,
              onPressed: _noop,
              child: Text('中圆'),
            ),
            TButton(
              theme: TButtonTheme.primary,
              shape: TButtonShape.round,
              onPressed: _noop,
              child: Text('圆角'),
            ),
          ],
        ),
      ),
    );

    expect(tester.getSize(_button('小方')), const Size(24, 24));
    expect(tester.getSize(_button('中方')), const Size(32, 32));
    expect(tester.getSize(_button('大圆')), const Size(40, 40));
    expect(tester.getSize(_button('中圆')), const Size(32, 32));

    final radius = TDesignTokens.light.radii['radiusDefault']!;
    expect(
      _decoration(tester, _button('中方')).borderRadius,
      BorderRadius.circular(radius),
    );
    expect(
      _decoration(tester, _button('中圆')).borderRadius,
      BorderRadius.circular(16),
    );
    expect(
      _decoration(tester, _button('大圆')).borderRadius,
      BorderRadius.circular(20),
    );

    final round = tester.getSize(_button('圆角'));
    expect(round.height, 32);
    expect(round.width, greaterThan(round.height));
    expect(
      _decoration(tester, _button('圆角')).borderRadius,
      BorderRadius.circular(16),
    );
  });

  testWidgets('block stretches to the parent width', (tester) async {
    await tester.pumpWidget(
      _host(
        const SizedBox(
          width: 280,
          child: TButton(
            block: true,
            theme: TButtonTheme.primary,
            onPressed: _noop,
            child: Text('通栏'),
          ),
        ),
      ),
    );
    expect(tester.getSize(find.byType(TButton)).width, 280);
  });

  testWidgets('icon and suffix render beside the label', (tester) async {
    await tester.pumpWidget(
      _host(
        const TButton(
          theme: TButtonTheme.primary,
          icon: Text('+'),
          suffix: Text('›'),
          onPressed: _noop,
          child: Text('带图标'),
        ),
      ),
    );
    expect(find.text('+'), findsOneWidget);
    expect(find.text('›'), findsOneWidget);
    expect(find.text('带图标'), findsOneWidget);
  });

  testWidgets('href marks the button as a link for semantics', (tester) async {
    await tester.pumpWidget(
      _host(
        const TButton(
          theme: TButtonTheme.primary,
          variant: TButtonVariant.text,
          href: 'https://tdesign.tencent.com/',
          onPressed: _noop,
          child: Text('官网'),
        ),
      ),
    );
    final node = tester.getSemantics(find.byType(TButton));
    expect(node.hasFlag(SemanticsFlag.isLink), isTrue);
    expect(node.hasFlag(SemanticsFlag.isButton), isTrue);
    expect(node.label, '官网');
    expect(node.tooltip, 'https://tdesign.tencent.com/');
  });
}

void _noop() {}

Widget _host(Widget child) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: Center(child: child),
  );
}

Finder _button(String label) {
  return find.ancestor(of: find.text(label), matching: find.byType(TButton));
}

Finder _dashedPaint(Finder button) {
  return find.descendant(
    of: button,
    matching: find.byWidgetPredicate(
      (widget) => widget is CustomPaint && widget.foregroundPainter != null,
    ),
  );
}

BoxDecoration _decoration(WidgetTester tester, Finder button) {
  final box = tester.widget<DecoratedBox>(
    find.descendant(of: button, matching: find.byType(DecoratedBox)),
  );
  return box.decoration as BoxDecoration;
}

Color _labelColor(WidgetTester tester, Finder button) {
  final text = find.descendant(of: button, matching: find.byType(Text));
  return DefaultTextStyle.of(tester.element(text)).style.color!;
}

Color _token(String key) => _tokenFrom(TDesignTokens.light, key);

Color _tokenFrom(TDesignTokenSet tokens, String key) {
  var hex = tokens.colors[key]!.replaceFirst('#', '');
  if (hex.length == 6) hex = 'FF$hex';
  return Color(int.parse(hex, radix: 16));
}

void _expectDashed(WidgetTester tester, Finder button, Color color) {
  final paint = tester.widget<CustomPaint>(_dashedPaint(button));
  final painter = paint.foregroundPainter! as TButtonDashedBorderPainter;
  expect(painter.color, color);
  expect(TButtonDashedBorderPainter.strokeWidth, 1);
  expect(TButtonDashedBorderPainter.gapLength, greaterThan(0));

  final size = tester.getSize(button);
  final solid = painter.outlinePath(size);
  final dashed = painter.dashedPath(size);
  expect(_contourCount(solid), 1);
  expect(_contourCount(dashed), greaterThan(1));
  expect(_pathLength(dashed), lessThan(_pathLength(solid)));
}

int _contourCount(Path path) {
  var count = 0;
  for (final _ in path.computeMetrics()) {
    count += 1;
  }
  return count;
}

double _pathLength(Path path) {
  var length = 0.0;
  for (final metric in path.computeMetrics()) {
    length += metric.length;
  }
  return length;
}
