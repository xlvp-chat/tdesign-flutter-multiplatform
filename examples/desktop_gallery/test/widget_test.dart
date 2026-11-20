import 'package:desktop_gallery/gallery/catalog.dart';
import 'package:desktop_gallery/main.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('catalog lists every implemented P0 component', () {
    final ids = galleryComponents.map((component) => component.id).toSet();
    expect(ids, containsAll(p0ComponentIds));
    expect(p0ComponentIds, hasLength(23));
  });

  testWidgets('gallery opens Button and can switch to Link', (tester) async {
    await tester.pumpWidget(const DesktopGalleryApp());
    await tester.pump();

    expect(find.text('Button 按钮'), findsWidgets);
    expect(find.text('基础按钮'), findsOneWidget);

    await tester.tap(find.text('Link 链接'));
    await tester.pump();

    expect(find.text('不同主题'), findsOneWidget);
    expect(find.text('下划线'), findsOneWidget);
  });

  testWidgets('every P0 page builds', (tester) async {
    for (final component in galleryComponents) {
      if (!p0ComponentIds.contains(component.id)) continue;
      await tester.pumpWidget(
        WidgetsApp(
          color: const Color(0xFF0052D9),
          home: component.create(),
          pageRouteBuilder: <T>(RouteSettings settings, WidgetBuilder builder) {
            return PageRouteBuilder<T>(
              settings: settings,
              pageBuilder: (context, animation, secondaryAnimation) =>
                  builder(context),
            );
          },
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.textContaining(component.title), findsWidgets);
    }
  });

  testWidgets('gallery can open a desktop-only component page', (tester) async {
    await tester.pumpWidget(const DesktopGalleryApp());
    await tester.pump();

    await tester.scrollUntilVisible(
      find.text('Pagination 分页'),
      80,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Pagination 分页'));
    await tester.pump();

    expect(find.text('基础分页'), findsOneWidget);
    expect(find.text('数据总数'), findsOneWidget);
    expect(find.text('每页条数'), findsOneWidget);
  });
}
