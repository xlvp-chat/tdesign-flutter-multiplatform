import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tdesign_flutter_multi_desktop/tdesign_flutter_multi_desktop.dart';

void main() {
  testWidgets('required fails on submit until the input has text', (
    tester,
  ) async {
    final controller = TFormController();
    addTearDown(controller.dispose);
    var name = '';
    var submitted = 0;

    Future<void> pump() {
      return tester.pumpWidget(
        _host(
          TForm(
            controller: controller,
            onSubmit: () => submitted++,
            children: [
              TFormItem(
                name: 'name',
                label: '姓名',
                required: true,
                rules: const [TFormRule(required: true)],
                child: TInput(value: name, onChanged: (value) => name = value),
              ),
            ],
          ),
        ),
      );
    }

    await pump();
    controller.submit();
    await pump();

    expect(submitted, 0);
    expect(find.text('不能为空'), findsOneWidget);
    expect(_inputBorder(tester), const Color(0xFFD54941));
    expect(tester.getSize(find.byType(TInput)).height, 32);

    await tester.enterText(find.byType(EditableText), 'Ann');
    await pump();

    expect(name, 'Ann');
    expect(find.text('不能为空'), findsNothing);
    expect(controller.values['name'], 'Ann');

    controller.submit();
    await pump();
    expect(submitted, 1);
  });

  testWidgets('explicit input status wins over a rule failure', (tester) async {
    final controller = TFormController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      _host(
        TForm(
          controller: controller,
          children: const [
            TFormItem(
              name: 'name',
              label: '姓名',
              rules: [TFormRule(required: true)],
              child: TInput(status: TInputStatus.warning),
            ),
          ],
        ),
      ),
    );

    controller.submit();
    await tester.pump();

    expect(find.text('不能为空'), findsOneWidget);
    expect(_inputBorder(tester), const Color(0xFFE37318));
  });

  testWidgets('email pattern uses change and submit accepts a full address', (
    tester,
  ) async {
    final controller = TFormController();
    addTearDown(controller.dispose);
    var email = '';
    var submitted = 0;

    Future<void> pump() {
      return tester.pumpWidget(
        _host(
          TForm(
            controller: controller,
            onSubmit: () => submitted++,
            children: [
              TFormItem(
                name: 'email',
                label: '邮箱',
                rules: const [TFormRule.email()],
                child: TInput(
                  value: email,
                  onChanged: (value) => email = value,
                ),
              ),
            ],
          ),
        ),
      );
    }

    await pump();
    controller.submit();
    await pump();
    expect(submitted, 1);
    expect(find.text('请输入正确的邮箱'), findsNothing);

    await tester.enterText(find.byType(EditableText), 'not-an-email');
    await pump();
    expect(find.text('请输入正确的邮箱'), findsOneWidget);

    controller.submit();
    await pump();
    expect(submitted, 1);

    await tester.enterText(find.byType(EditableText), 'a@b.c');
    await pump();
    expect(find.text('请输入正确的邮箱'), findsNothing);

    controller.submit();
    await pump();
    expect(submitted, 2);
  });

  testWidgets(
    'submit runs blur-only rules and reset restores the first value',
    (tester) async {
      final controller = TFormController();
      addTearDown(controller.dispose);
      var name = 'Ann';
      var submitted = 0;

      await tester.pumpWidget(
        _host(
          StatefulBuilder(
            builder: (context, setState) {
              return TForm(
                controller: controller,
                onSubmit: () => submitted++,
                children: [
                  TFormItem(
                    name: 'name',
                    label: '姓名',
                    rules: const [
                      TFormRule(required: true, trigger: {TFormTrigger.blur}),
                    ],
                    child: TInput(
                      value: name,
                      onChanged: (value) => setState(() => name = value),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );
      await tester.pump();
      expect(controller.values['name'], 'Ann');

      await tester.enterText(find.byType(EditableText), '');
      await tester.pump();
      expect(name, '');
      expect(find.text('不能为空'), findsNothing);

      controller.submit();
      await tester.pump();
      expect(submitted, 0);
      expect(find.text('不能为空'), findsOneWidget);

      controller.reset();
      await tester.pump();
      await tester.pump();

      expect(name, 'Ann');
      expect(find.text('不能为空'), findsNothing);
      expect(
        tester.widget<EditableText>(find.byType(EditableText)).controller.text,
        'Ann',
      );

      controller.submit();
      await tester.pump();
      expect(submitted, 1);
    },
  );

  testWidgets('pattern, helpers, min, max, and empty values', (tester) async {
    final controller = TFormController();
    addTearDown(controller.dispose);

    Future<void> show(List<TFormRule> rules, Object? value) {
      return tester.pumpWidget(
        _host(
          TForm(
            controller: controller,
            children: [
              TFormItem(
                name: 'field',
                label: '字段',
                rules: rules,
                child: _ValueReporter(value),
              ),
            ],
          ),
        ),
      );
    }

    Future<void> expectFailure(
      List<TFormRule> rules,
      Object? value,
      String message,
    ) async {
      await show(rules, value);
      expect(controller.validate(), isFalse);
      await tester.pump();
      expect(find.text(message), findsOneWidget);
    }

    Future<void> expectPass(List<TFormRule> rules, Object? value) async {
      await show(rules, value);
      expect(controller.validate(), isTrue);
      await tester.pump();
    }

    const email = TFormRule.email();
    const url = TFormRule.url();
    const tel = TFormRule.telnumber();
    final code = TFormRule(pattern: RegExp('abc'));
    const length = TFormRule(min: 2, max: 4);
    const atLeastOne = TFormRule(min: 1);
    const custom = TFormRule(message: '不会用这条', validator: _rejectNo);

    await expectPass(const [email], '');
    await expectPass(const [email], 'a@b.c');
    await expectFailure(const [email], 'a@b', '请输入正确的邮箱');

    await expectPass(const [url], 'HTTPS://example.com/a');
    await expectPass(const [url], 'ftp://files');
    await expectFailure(const [url], 'www.example.com', '请输入正确的链接');
    await expectFailure(const [url], 'http://', '请输入正确的链接');

    await expectPass(const [tel], '');
    await expectPass(const [tel], '13812345678');
    await expectFailure(const [tel], '12812345678', '请输入正确的手机号码');
    await expectFailure(const [tel], '1381234567', '请输入正确的手机号码');

    await expectPass([code], '');
    await expectPass([code], 'abc');
    await expectFailure([code], 'abcd', '格式不正确');
    await expectFailure([code], 'zabc', '格式不正确');

    await expectFailure(const [length], 'a', '不能小于最小值');
    await expectPass(const [length], 'ab');
    await expectPass(const [length], 'abcd');
    await expectFailure(const [length], 'abcde', '不能大于最大值');
    await expectFailure(const [atLeastOne], 0, '不能小于最小值');
    await expectPass(const [atLeastOne], 1);
    await expectFailure(const [TFormRule(max: 4)], 5, '不能大于最大值');

    await expectPass(const [TFormRule(required: true)], 0);
    await expectPass(const [TFormRule(required: true)], false);
    await expectPass(const [TFormRule(required: true)], ' ');
    await expectFailure(const [TFormRule(required: true)], null, '不能为空');
    await expectFailure(const [TFormRule(required: true)], '', '不能为空');
    await expectFailure(const [TFormRule(required: true)], <String>[], '不能为空');

    await expectFailure([custom], 'no', '自定义');
    await expectPass([custom], 'yes');
  });

  testWidgets('unnamed items keep external error text', (tester) async {
    await tester.pumpWidget(
      _host(
        const TForm(
          children: [
            TFormItem(label: '备注', errorText: '手写错误', child: Text('内容')),
          ],
        ),
      ),
    );

    expect(find.text('手写错误'), findsOneWidget);
    expect(find.text('内容'), findsOneWidget);
  });

  testWidgets(
    'select reports the picked value and required fails before that',
    (tester) async {
      final controller = TFormController();
      addTearDown(controller.dispose);
      String? fruit;

      await tester.pumpWidget(
        _overlay(
          TForm(
            controller: controller,
            children: [
              TFormItem(
                name: 'fruit',
                label: '水果',
                rules: const [TFormRule(required: true)],
                child: StatefulBuilder(
                  builder: (context, setState) {
                    return TSelect<String>(
                      value: fruit,
                      placeholder: 'Pick fruit',
                      options: const ['Apple', 'Banana'],
                      labelBuilder: _label,
                      onChanged: (value) => setState(() => fruit = value),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(controller.validate(), isFalse);
      await tester.pump();
      expect(find.text('不能为空'), findsOneWidget);

      await tester.tap(find.byType(TSelect<String>), warnIfMissed: false);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Banana'));
      await tester.pumpAndSettle();

      expect(fruit, 'Banana');
      expect(controller.values['fruit'], 'Banana');
      expect(find.text('不能为空'), findsNothing);
      expect(controller.validate(), isTrue);
    },
  );
}

String? _rejectNo(Object? value) => value == 'no' ? '自定义' : null;

String _label(String value) => value;

Color _inputBorder(WidgetTester tester) {
  final decorated = tester.widget<DecoratedBox>(
    find.descendant(
      of: find.byType(TInput),
      matching: find.byType(DecoratedBox),
    ),
  );
  final border = (decorated.decoration as BoxDecoration).border! as Border;
  return border.top.color;
}

Widget _host(Widget child) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: Center(child: SizedBox(width: 360, child: child)),
  );
}

Widget _overlay(Widget child) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: Overlay(
      initialEntries: [
        OverlayEntry(
          builder: (context) =>
              Center(child: SizedBox(width: 360, child: child)),
        ),
      ],
    ),
  );
}

class _ValueReporter extends StatefulWidget {
  const _ValueReporter(this.value);

  final Object? value;

  @override
  State<_ValueReporter> createState() => _ValueReporterState();
}

class _ValueReporterState extends State<_ValueReporter> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _send();
  }

  @override
  void didUpdateWidget(_ValueReporter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) _send();
  }

  void _send() {
    TFormFieldScope.maybeOf(context)?.report(widget.value);
  }

  @override
  Widget build(BuildContext context) => const SizedBox(width: 8, height: 8);
}
