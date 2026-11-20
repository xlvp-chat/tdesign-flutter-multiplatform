import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tdesign_flutter_multi_core/tdesign_flutter_multi_core.dart';
import 'package:tdesign_flutter_multi_desktop/tdesign_flutter_multi_desktop.dart';

void main() {
  testWidgets('clearable calls onChanged with an empty string', (tester) async {
    var value = 'hello';

    Future<void> pump() {
      return tester.pumpWidget(
        _host(
          TInput(
            value: value,
            clearable: true,
            onChanged: (next) => value = next,
          ),
        ),
      );
    }

    await pump();
    expect(find.bySemanticsLabel('清空'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('TInput.clear')));
    await pump();

    expect(value, '');
    expect(find.bySemanticsLabel('清空'), findsNothing);

    await tester.pumpWidget(_host(const TInput(clearable: true, value: '')));
    expect(find.byKey(const ValueKey<String>('TInput.clear')), findsNothing);

    await tester.pumpWidget(
      _host(const TInput(clearable: true, enabled: false, value: 'hello')),
    );
    expect(find.byKey(const ValueKey<String>('TInput.clear')), findsNothing);
  });

  testWidgets('obscureText toggles masking without changing the value', (
    tester,
  ) async {
    var changes = 0;
    await tester.pumpWidget(
      _host(
        TInput(value: 'secret', obscureText: true, onChanged: (_) => changes++),
      ),
    );

    EditableText field() =>
        tester.widget<EditableText>(find.byType(EditableText));

    expect(field().obscureText, isTrue);
    expect(field().controller.text, 'secret');
    expect(find.bySemanticsLabel('显示密码'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('TInput.obscure')));
    await tester.pump();

    expect(field().obscureText, isFalse);
    expect(field().controller.text, 'secret');
    expect(changes, 0);
    expect(find.bySemanticsLabel('隐藏密码'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('TInput.obscure')));
    await tester.pump();

    expect(field().obscureText, isTrue);
    expect(field().controller.text, 'secret');
    expect(changes, 0);
  });

  testWidgets('status changes only the border color', (tester) async {
    Future<void> pump(TInputStatus status) {
      return tester.pumpWidget(_host(TInput(status: status, value: '姓名')));
    }

    await pump(TInputStatus.normal);
    final height = tester.getSize(find.byType(TInput)).height;
    expect(height, 32);
    expect(
      _borderColor(tester),
      _parse(TDesignTokens.light.colors['componentBorder']!),
    );

    await pump(TInputStatus.success);
    expect(tester.getSize(find.byType(TInput)).height, height);
    expect(
      _borderColor(tester),
      _parse(TDesignTokens.light.colors['successColor5']!),
    );

    await pump(TInputStatus.warning);
    expect(tester.getSize(find.byType(TInput)).height, height);
    expect(
      _borderColor(tester),
      _parse(TDesignTokens.light.colors['warningColor5']!),
    );

    await pump(TInputStatus.error);
    expect(tester.getSize(find.byType(TInput)).height, height);
    expect(
      _borderColor(tester),
      _parse(TDesignTokens.light.colors['errorColor6']!),
    );
    expect(_border(tester).top.width, 1);
  });

  testWidgets('input colors follow the inherited token scope', (tester) async {
    await tester.pumpWidget(
      _host(
        const TDesignTokenScope(
          tokens: TDesignTokens.dark,
          child: TInput(status: TInputStatus.error, value: '姓名'),
        ),
      ),
    );

    expect(
      _borderColor(tester),
      _parse(TDesignTokens.dark.colors['errorColor6']!),
    );
    final decorated = tester.widget<DecoratedBox>(find.byType(DecoratedBox));
    final decoration = decorated.decoration as BoxDecoration;
    expect(
      decoration.color,
      _parse(TDesignTokens.dark.colors['bgColorContainer']!),
    );
    final field = tester.widget<EditableText>(find.byType(EditableText));
    expect(
      field.style.color,
      _parse(TDesignTokens.dark.colors['textColorPrimary']!),
    );
  });

  testWidgets('maxLength uses String.length and showLimit shows current/max', (
    tester,
  ) async {
    var value = '';

    Future<void> pump({int maxLength = 3, bool showLimit = true}) {
      return tester.pumpWidget(
        _host(
          StatefulBuilder(
            builder: (context, setState) {
              return TInput(
                value: value,
                maxLength: maxLength,
                showLimit: showLimit,
                onChanged: (next) => setState(() => value = next),
              );
            },
          ),
        ),
      );
    }

    await pump(maxLength: 10);
    expect(find.text('0/10'), findsOneWidget);

    await tester.enterText(find.byType(EditableText), '你好');
    await pump(maxLength: 10);
    expect(value, '你好');
    expect(value.length, 2);
    expect(find.text('2/10'), findsOneWidget);
    expect(find.text('4/10'), findsNothing);

    await pump();
    expect(find.text('2/3'), findsOneWidget);

    await tester.enterText(find.byType(EditableText), '你好世多余');
    await pump();
    expect(value, '你好世');
    expect(value.length, 3);
    expect(find.text('3/3'), findsOneWidget);

    await tester.enterText(find.byType(EditableText), '你好世界啊');
    await pump();
    expect(value, '你好世');
    expect(find.text('3/3'), findsOneWidget);

    await tester.pumpWidget(
      _host(const TInput(value: '你好', maxLength: 10, showLimit: false)),
    );
    expect(find.text('2/10'), findsNothing);
    expect(find.text('4/10'), findsNothing);
  });

  testWidgets('placeholder uses textColorPlaceholder when the value is empty', (
    tester,
  ) async {
    const placeholder = '请输入内容';
    const expected = Color(0x66000000);

    await tester.pumpWidget(_host(const TInput(placeholder: placeholder)));
    expect(_placeholderColor(tester, placeholder), expected);

    await tester.pumpWidget(
      _host(const TInput(value: '', placeholder: placeholder)),
    );
    expect(_placeholderColor(tester, placeholder), expected);

    await tester.pumpWidget(
      _host(const TInput(value: '有内容', placeholder: placeholder)),
    );
    expect(find.text(placeholder), findsNothing);
  });
}

Color _parse(String hex) {
  var value = hex.replaceFirst('#', '');
  if (value.length == 6) value = 'FF$value';
  return Color(int.parse(value, radix: 16));
}

Color _placeholderColor(WidgetTester tester, String placeholder) {
  return tester.widget<Text>(find.text(placeholder)).style!.color!;
}

Border _border(WidgetTester tester) {
  final decorated = tester.widget<DecoratedBox>(find.byType(DecoratedBox));
  return (decorated.decoration as BoxDecoration).border! as Border;
}

Color _borderColor(WidgetTester tester) {
  final border = _border(tester);
  expect(border.right.color, border.top.color);
  expect(border.bottom.color, border.top.color);
  expect(border.left.color, border.top.color);
  return border.top.color;
}

Widget _host(Widget child) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: Center(child: SizedBox(width: 240, child: child)),
  );
}
