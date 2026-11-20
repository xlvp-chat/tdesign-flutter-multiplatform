import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tdesign_flutter_core/tdesign_flutter_core.dart';
import 'package:tdesign_flutter_desktop/tdesign_flutter_desktop.dart';

Widget _harness(Widget child) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: Overlay(
      initialEntries: [
        OverlayEntry(
          builder: (context) {
            return Align(alignment: Alignment.topLeft, child: child);
          },
        ),
      ],
    ),
  );
}

Color _parse(String hex) {
  var value = hex.replaceFirst('#', '');
  if (value.length == 6) value = 'FF$value';
  return Color(int.parse(value, radix: 16));
}

void main() {
  testWidgets('menu item shows an optional leading icon', (tester) async {
    await tester.pumpWidget(
      _harness(
        const SizedBox(
          height: 160,
          child: TMenu(
            value: 'home',
            onChanged: _noop,
            items: [
              TMenuItem(
                value: 'home',
                icon: SizedBox(key: Key('menu-icon'), width: 16, height: 16),
                label: Text('Home'),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('menu-icon')), findsOneWidget);
    final icon = tester.getRect(find.byKey(const Key('menu-icon')));
    final label = tester.getRect(find.text('Home'));
    expect(icon.right, lessThan(label.left));

    final surface = tester.widget<DecoratedBox>(find.byType(DecoratedBox));
    final decoration = surface.decoration as BoxDecoration;
    expect(
      decoration.color,
      _parse(TDesignTokens.light.colors['bgColorContainer']!),
    );
  });

  testWidgets('dark menu uses the dark container and textColorAnti', (
    tester,
  ) async {
    final background = _parse(TDesignTokens.dark.colors['bgColorContainer']!);
    final text = _parse(TDesignTokens.dark.colors['textColorAnti']!);
    expect(background, const Color(0xFF242424));
    expect(text, const Color(0xFFFFFFFF));
    expect(TDesignTokens.dark.colors.containsKey('grayColor13'), isFalse);

    await tester.pumpWidget(
      _harness(
        const SizedBox(
          height: 160,
          child: TMenu(
            theme: TMenuTheme.dark,
            value: 'selected',
            onChanged: _noop,
            items: [
              TMenuItem(value: 'selected', label: Text('Selected')),
              TMenuItem(value: 'other', label: Text('Other')),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(DecoratedBox), findsOneWidget);
    final surface = tester.widget<DecoratedBox>(find.byType(DecoratedBox));
    final decoration = surface.decoration as BoxDecoration;
    expect(decoration.color, background);

    final style = tester.widget<DefaultTextStyle>(
      find
          .ancestor(
            of: find.text('Other'),
            matching: find.byType(DefaultTextStyle),
          )
          .first,
    );
    expect(style.style.color, text);
  });

  testWidgets('light menu reads the inherited token scope', (tester) async {
    await tester.pumpWidget(
      _harness(
        const TDesignTokenScope(
          tokens: TDesignTokens.dark,
          child: SizedBox(
            height: 160,
            child: TMenu(
              value: 'home',
              onChanged: _noop,
              items: [
                TMenuItem(value: 'home', label: Text('Home')),
                TMenuItem(value: 'other', label: Text('Other')),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final surface = tester.widget<DecoratedBox>(find.byType(DecoratedBox));
    final decoration = surface.decoration as BoxDecoration;
    expect(
      decoration.color,
      _parse(TDesignTokens.dark.colors['bgColorContainer']!),
    );
    final style = tester.widget<DefaultTextStyle>(
      find
          .ancestor(
            of: find.text('Other'),
            matching: find.byType(DefaultTextStyle),
          )
          .first,
    );
    expect(
      style.style.color,
      _parse(TDesignTokens.dark.colors['textColorPrimary']!),
    );
  });

  testWidgets('dark menu provides the dark token set to descendants', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        const TDesignTokenScope(
          tokens: TDesignTokens.light,
          child: SizedBox(
            height: 200,
            child: TMenu(
              theme: TMenuTheme.dark,
              value: 'selected',
              onChanged: _noop,
              items: [
                TMenuItem(
                  value: 'selected',
                  label: TButton(onPressed: _noopButton, child: Text('Inside')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final button = find.byType(TButton);
    final box = tester.widget<DecoratedBox>(
      find.descendant(of: button, matching: find.byType(DecoratedBox)),
    );
    final decoration = box.decoration as BoxDecoration;
    expect(
      decoration.color,
      _parse(TDesignTokens.dark.colors['bgColorContainer']!),
    );
  });

  testWidgets('vertical menu indents nested items', (tester) async {
    await tester.pumpWidget(
      _harness(
        const SizedBox(
          height: 200,
          child: TMenu(
            value: 'child',
            onChanged: _noop,
            items: [
              TMenuItem(
                value: 'group',
                label: Text('Group'),
                children: [TMenuItem(value: 'child', label: Text('Child'))],
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Child'), findsOneWidget);
    final groupLeft = tester.getTopLeft(find.text('Group')).dx;
    final childLeft = tester.getTopLeft(find.text('Child')).dx;
    expect(childLeft, greaterThan(groupLeft + 10));
  });

  testWidgets('horizontal children open in an overlay without left indent', (
    tester,
  ) async {
    String? selected;

    await tester.pumpWidget(
      _harness(
        StatefulBuilder(
          builder: (context, setState) {
            return TMenu(
              axis: TMenuAxis.horizontal,
              value: selected,
              onChanged: (value) => setState(() => selected = value),
              items: const [
                TMenuItem(value: 'home', label: Text('Home')),
                TMenuItem(
                  value: 'group',
                  label: Text('Group'),
                  children: [TMenuItem(value: 'child', label: Text('Child'))],
                ),
              ],
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Child'), findsNothing);

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(selected, 'home');
    expect(find.text('Child'), findsNothing);

    await tester.tap(find.text('Group'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Child'), findsOneWidget);
    expect(selected, 'home');
    final group = tester.getRect(find.text('Group'));
    final child = tester.getRect(find.text('Child'));
    expect(child.top, greaterThan(group.bottom - 1));
    expect((child.left - group.left).abs(), lessThan(4));

    await tester.tap(find.text('Child'));
    await tester.pumpAndSettle();
    expect(selected, 'child');
    expect(find.text('Child'), findsNothing);
  });
}

void _noop(String value) {}

void _noopButton() {}
