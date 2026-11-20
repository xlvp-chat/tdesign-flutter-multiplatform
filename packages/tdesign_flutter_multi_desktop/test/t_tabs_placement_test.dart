import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tdesign_flutter_multi_core/tdesign_flutter_multi_core.dart';
import 'package:tdesign_flutter_multi_desktop/tdesign_flutter_multi_desktop.dart';

Widget _harness(Widget child) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: Align(alignment: Alignment.topLeft, child: child),
  );
}

Color _parse(String hex) {
  var value = hex.replaceFirst('#', '');
  if (value.length == 6) value = 'FF$value';
  return Color(int.parse(value, radix: 16));
}

void main() {
  final brand = _parse(TDesignTokens.light.colors['brandColor7']!);

  Finder indicator() {
    return find.byWidgetPredicate(
      (widget) => widget is ColoredBox && widget.color == brand,
    );
  }

  Rect itemRect(WidgetTester tester, String label) {
    return tester.getRect(
      find
          .ancestor(
            of: find.text(label),
            matching: find.byType(TInteractiveRegion),
          )
          .first,
    );
  }

  void expectIndicator(TTabPlacement placement, Rect item, Rect bar) {
    const thickness = 3.0;
    const eps = 0.5;
    switch (placement) {
      case TTabPlacement.top:
        expect(bar.height, thickness);
        expect(bar.bottom, closeTo(item.bottom, eps));
        expect(bar.left, closeTo(item.left, eps));
        expect(bar.right, closeTo(item.right, eps));
      case TTabPlacement.bottom:
        expect(bar.height, thickness);
        expect(bar.top, closeTo(item.top, eps));
        expect(bar.left, closeTo(item.left, eps));
        expect(bar.right, closeTo(item.right, eps));
      case TTabPlacement.left:
        expect(bar.width, thickness);
        expect(bar.right, closeTo(item.right, eps));
        expect(bar.top, closeTo(item.top, eps));
        expect(bar.bottom, closeTo(item.bottom, eps));
      case TTabPlacement.right:
        expect(bar.width, thickness);
        expect(bar.left, closeTo(item.left, eps));
        expect(bar.top, closeTo(item.top, eps));
        expect(bar.bottom, closeTo(item.bottom, eps));
    }
  }

  testWidgets('indicator follows the selected tab for every placement', (
    tester,
  ) async {
    for (final placement in TTabPlacement.values) {
      var value = 'first';
      await tester.pumpWidget(
        _harness(
          StatefulBuilder(
            builder: (context, setState) {
              return TTabs(
                placement: placement,
                value: value,
                onChanged: (next) => setState(() => value = next),
                items: const [
                  TTabItem(value: 'first', label: Text('First')),
                  TTabItem(value: 'second', label: Text('Second')),
                ],
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      final first = tester.getRect(find.text('First'));
      final second = tester.getRect(find.text('Second'));
      if (placement == TTabPlacement.top || placement == TTabPlacement.bottom) {
        expect(second.left, greaterThan(first.right - 1));
      } else {
        expect(second.top, greaterThan(first.bottom - 1));
      }

      expect(indicator(), findsOneWidget);
      expectIndicator(
        placement,
        itemRect(tester, 'First'),
        tester.getRect(indicator()),
      );

      await tester.tap(find.text('Second'));
      await tester.pumpAndSettle();

      expect(value, 'second');
      expect(indicator(), findsOneWidget);
      expectIndicator(
        placement,
        itemRect(tester, 'Second'),
        tester.getRect(indicator()),
      );
    }
  });

  testWidgets('defaults to top medium and large is 64px', (tester) async {
    await tester.pumpWidget(
      _harness(
        TTabs(
          value: 'a',
          onChanged: (_) {},
          items: const [
            TTabItem(value: 'a', label: Text('Alpha')),
            TTabItem(value: 'b', label: Text('Beta')),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    final alpha = tester.getRect(find.text('Alpha'));
    final beta = tester.getRect(find.text('Beta'));
    expect(beta.left, greaterThan(alpha.right - 1));
    expect(_itemHeight(tester, 'Alpha'), 48);
    expect(_labelStyle(tester, 'Alpha').fontSize, 14);

    await tester.pumpWidget(
      _harness(
        TTabs(
          size: TTabsSize.large,
          value: 'a',
          onChanged: (_) {},
          items: const [TTabItem(value: 'a', label: Text('Alpha'))],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(_itemHeight(tester, 'Alpha'), 64);
    expect(_labelStyle(tester, 'Alpha').fontSize, 16);
    expect(TTabsSize.values, [TTabsSize.medium, TTabsSize.large]);
  });

  testWidgets('card theme has no line indicator', (tester) async {
    await tester.pumpWidget(
      _harness(
        TTabs(
          theme: TTabsTheme.card,
          value: 'first',
          onChanged: (_) {},
          items: const [
            TTabItem(value: 'first', label: Text('First')),
            TTabItem(value: 'second', label: Text('Second')),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(indicator(), findsNothing);
    expect(find.text('First'), findsOneWidget);
    expect(TTabsTheme.values, [TTabsTheme.normal, TTabsTheme.card]);
  });
}

double _itemHeight(WidgetTester tester, String label) {
  return tester
      .getSize(
        find
            .ancestor(
              of: find.text(label),
              matching: find.byType(TInteractiveRegion),
            )
            .first,
      )
      .height;
}

TextStyle _labelStyle(WidgetTester tester, String label) {
  final style = tester.widget<DefaultTextStyle>(
    find
        .ancestor(of: find.text(label), matching: find.byType(DefaultTextStyle))
        .first,
  );
  return style.style;
}
