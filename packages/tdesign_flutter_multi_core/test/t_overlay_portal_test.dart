import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tdesign_flutter_multi_core/tdesign_flutter_multi_core.dart';

void main() {
  testWidgets('restores focus to previous node on close', (tester) async {
    final anchorFocus = FocusNode();
    addTearDown(anchorFocus.dispose);
    var visible = false;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Overlay(
          initialEntries: [
            OverlayEntry(
              builder: (context) {
                return StatefulBuilder(
                  builder: (context, setState) {
                    return Center(
                      child: TOverlayPortal(
                        visible: visible,
                        onVisibleChanged: (v) => setState(() => visible = v),
                        options: const TOverlayPortalOptions(
                          preferredPlacement: TPlacement.bottomLeft,
                        ),
                        anchor: Focus(
                          focusNode: anchorFocus,
                          child: GestureDetector(
                            onTap: () => setState(() => visible = true),
                            child: const SizedBox(
                              width: 80,
                              height: 32,
                              child: Text('Anchor'),
                            ),
                          ),
                        ),
                        overlayBuilder: (context) => const SizedBox(
                          width: 120,
                          height: 80,
                          child: Text('Popup'),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    anchorFocus.requestFocus();
    await tester.pump();
    expect(anchorFocus.hasFocus, isTrue);

    await tester.tap(find.text('Anchor'));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.text('Popup'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Popup'), findsNothing);
    expect(anchorFocus.hasFocus, isTrue);
  });

  testWidgets('flips upward when bottom placement overflows', (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: MediaQuery(
          data: const MediaQueryData(size: Size(400, 300)),
          child: Overlay(
            initialEntries: [
              OverlayEntry(
                builder: (context) {
                  return Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: TOverlayPortal(
                        visible: true,
                        options: const TOverlayPortalOptions(
                          preferredPlacement: TPlacement.bottomLeft,
                          viewportPadding: EdgeInsets.all(4),
                        ),
                        anchor: const SizedBox(
                          width: 100,
                          height: 24,
                          child: Text('NearBottom'),
                        ),
                        overlayBuilder: (context) => const SizedBox(
                          width: 160,
                          height: 200,
                          child: ColoredBox(
                            color: Color(0xFFEEEEEE),
                            child: Text('TallPopup'),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('TallPopup'), findsOneWidget);
    final popup = tester.getRect(find.text('TallPopup'));
    final anchor = tester.getRect(find.text('NearBottom'));
    expect(popup.bottom <= anchor.top + 1, isTrue);
  });
}
