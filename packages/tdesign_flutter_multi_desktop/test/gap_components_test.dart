import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tdesign_flutter_multi_desktop/tdesign_flutter_multi_desktop.dart';

void main() {
  testWidgets('empty avatar progress skeleton and steps render', (tester) async {
    await tester.pumpWidget(
      host(
        const Column(
          children: [
            TEmpty(title: '暂无数据'),
            TAvatar(child: Text('A')),
            SizedBox(width: 120, child: TProgress(percentage: 40)),
            SizedBox(width: 160, child: TSkeleton(rows: 2)),
            TSteps(
              current: 1,
              items: [TStepItem(title: '一步'), TStepItem(title: '二步')],
            ),
          ],
        ),
      ),
    );
    expect(find.text('暂无数据'), findsOneWidget);
    expect(find.text('A'), findsOneWidget);
    expect(find.text('40%'), findsOneWidget);
    expect(find.byKey(const ValueKey('TSkeleton.row.0')), findsOneWidget);
    expect(find.text('二步'), findsOneWidget);
  });

  testWidgets('rate and collapse report changes', (tester) async {
    var score = 1;
    var open = const <int>[0];
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) {
            return Column(
              children: [
                TRate(
                  value: score,
                  onChanged: (value) => setState(() => score = value),
                ),
                TCollapse(
                  value: open,
                  onChanged: (value) => setState(() => open = value),
                  panels: const [
                    TCollapsePanel(title: '一', child: Text('甲')),
                    TCollapsePanel(title: '二', child: Text('乙')),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
    await tester.tap(find.byIcon(TIcons.star).first);
    await tester.pump();
    expect(score, 2);
    await tester.tap(find.text('二'));
    await tester.pump();
    expect(find.text('乙'), findsOneWidget);
  });

  testWidgets('slider drawer and message', (tester) async {
    var slider = 0.0;
    var drawer = false;
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) {
            return Column(
              children: [
                SizedBox(
                  width: 100,
                  child: TSlider(
                    value: slider,
                    onChanged: (value) => setState(() => slider = value),
                  ),
                ),
                TButton(
                  onPressed: () => TMessage.show(
                    context,
                    content: '已保存',
                    duration: Duration.zero,
                  ),
                  child: const Text('消息'),
                ),
                TDrawer(
                  visible: drawer,
                  body: const Text('抽屉正文'),
                  onVisibleChanged: (value) => setState(() => drawer = value),
                ),
                TButton(
                  onPressed: () => setState(() => drawer = true),
                  child: const Text('开抽屉'),
                ),
              ],
            );
          },
        ),
      ),
    );
    await tester.tap(find.byType(TSlider));
    await tester.pump();
    expect(slider, greaterThan(0));
    await tester.tap(find.text('消息'));
    await tester.pump();
    expect(find.text('已保存'), findsOneWidget);
    await tester.tap(find.text('开抽屉'));
    await tester.pump();
    await tester.pump();
    expect(find.text('抽屉正文'), findsOneWidget);
  });

  testWidgets('image viewer steps to the next image', (tester) async {
    var index = 0;
    final pixel = MemoryImage(_pixel);
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) {
            return Column(
              children: [
                TImageViewer(
                  visible: true,
                  images: [pixel, pixel],
                  index: index,
                  onVisibleChanged: (_) {},
                  onIndexChanged: (value) => setState(() => index = value),
                ),
              ],
            );
          },
        ),
      ),
    );
    await tester.pump();
    expect(find.byKey(const ValueKey('TImageViewer.next')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('TImageViewer.next')));
    await tester.pump();
    expect(index, 1);
  });

  testWidgets('calendar selects a day and swiper shows the first page', (
    tester,
  ) async {
    DateTime? picked;
    await tester.pumpWidget(
      host(
        Column(
          children: [
            TCalendar(
              value: DateTime(2026, 11, 1),
              onChanged: (value) => picked = value,
            ),
            const SizedBox(
              width: 200,
              child: TSwiper(
                height: 40,
                children: [Text('页一'), Text('页二')],
              ),
            ),
            const TImage(width: 40, height: 40, alt: '失败'),
            const TLoading(child: Text('被盖住')),
          ],
        ),
      ),
    );
    await tester.tap(find.text('15'));
    await tester.pump();
    expect(picked, DateTime(2026, 11, 15));
    expect(find.text('页一'), findsOneWidget);
    expect(find.text('失败'), findsOneWidget);
    expect(find.text('被盖住'), findsOneWidget);
  });

  testWidgets('back top appears after scrolling', (tester) async {
    final controller = ScrollController();
    await tester.pumpWidget(
      host(
        SizedBox(
          height: 100,
          child: Stack(
            children: [
              ListView(
                controller: controller,
                children: [
                  for (var i = 0; i < 20; i++)
                    const SizedBox(height: 30, child: Text('行')),
                ],
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: TBackTop(controller: controller, visibilityHeight: 20),
              ),
            ],
          ),
        ),
      ),
    );
    expect(find.byIcon(TIcons.chevron_up), findsNothing);
    controller.jumpTo(40);
    await tester.pump();
    expect(find.byIcon(TIcons.chevron_up), findsOneWidget);
  });
}

final Uint8List _pixel = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
);

Widget host(Widget child) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: Overlay(
      initialEntries: [
        OverlayEntry(
          builder: (context) => Align(
            alignment: Alignment.topLeft,
            child: child,
          ),
        ),
      ],
    ),
  );
}
