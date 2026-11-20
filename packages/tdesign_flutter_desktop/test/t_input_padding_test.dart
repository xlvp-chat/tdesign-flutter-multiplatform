import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tdesign_flutter_core/tdesign_flutter_core.dart';
import 'package:tdesign_flutter_desktop/tdesign_flutter_desktop.dart';

void main() {
  testWidgets('medium input keeps 8px horizontal inset', (tester) async {
    await tester.pumpWidget(_host(const TInput(value: '姓名')));

    final input = tester.getRect(find.byType(TInput));
    final text = tester.getRect(find.byType(EditableText));

    expect(text.left - input.left, greaterThanOrEqualTo(8));
    expect(input.right - text.right, greaterThanOrEqualTo(8));
  });

  testWidgets('large input keeps 12px horizontal inset', (tester) async {
    await tester.pumpWidget(
      _host(const TInput(value: '姓名', size: TComponentSize.large)),
    );

    final input = tester.getRect(find.byType(TInput));
    final text = tester.getRect(find.byType(EditableText));

    expect(text.left - input.left, greaterThanOrEqualTo(12));
    expect(input.right - text.right, greaterThanOrEqualTo(12));
  });
}

Widget _host(Widget child) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: Center(child: SizedBox(width: 240, child: child)),
  );
}
