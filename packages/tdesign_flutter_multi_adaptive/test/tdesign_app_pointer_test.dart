import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tdesign_flutter_multi_adaptive/tdesign_flutter_multi_adaptive.dart';

void main() {
  testWidgets('pointer and keyboard follow later input', (tester) async {
    await tester.pumpWidget(
      const TDesignApp(child: SizedBox(width: 800, height: 600)),
    );

    final initial = AdaptiveScope.of(
      tester.element(find.byType(SizedBox)),
    ).contextData;
    expect(initial.primaryPointer, AdaptivePointer.touch);
    expect(initial.keyboardAvailable, isFalse);

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: const Offset(20, 20));
    await mouse.moveTo(const Offset(40, 40));
    await tester.pump();
    expect(
      AdaptiveScope.of(tester.element(find.byType(SizedBox)))
          .contextData
          .primaryPointer,
      AdaptivePointer.mouse,
    );

    await tester.tap(find.byType(Listener));
    await tester.pump();
    expect(
      AdaptiveScope.of(tester.element(find.byType(SizedBox)))
          .contextData
          .primaryPointer,
      AdaptivePointer.touch,
    );

    final stylus = await tester.startGesture(
      const Offset(30, 30),
      kind: PointerDeviceKind.stylus,
    );
    await tester.pump();
    expect(
      AdaptiveScope.of(tester.element(find.byType(SizedBox)))
          .contextData
          .primaryPointer,
      AdaptivePointer.stylus,
    );
    await stylus.up();

    await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
    await tester.pump();
    expect(
      AdaptiveScope.of(tester.element(find.byType(SizedBox)))
          .contextData
          .keyboardAvailable,
      isTrue,
    );

    await mouse.moveTo(const Offset(60, 40));
    await tester.pump();
    expect(
      AdaptiveScope.of(tester.element(find.byType(SizedBox)))
          .contextData
          .primaryPointer,
      AdaptivePointer.mouse,
    );
    await mouse.removePointer();
  });
}
