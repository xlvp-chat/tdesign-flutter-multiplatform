import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tdesign_flutter_desktop/tdesign_flutter_desktop.dart';

Widget _harness(Widget child) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: Overlay(
      initialEntries: [
        OverlayEntry(
          builder: (context) =>
              Center(child: SizedBox(width: 240, child: child)),
        ),
      ],
    ),
  );
}

Future<void> _pumpOpenSettle(WidgetTester tester) async {
  await tester.pump();
  await tester.pumpAndSettle();
}

Future<void> _tapSelect(WidgetTester tester) async {
  await tester.tap(find.byType(TSelect<String>), warnIfMissed: false);
  await _pumpOpenSettle(tester);
}

void main() {
  testWidgets('onSearch skips local filtering and reports the query', (
    tester,
  ) async {
    final queries = <String>[];
    var options = <String>['Apple', 'Banana'];
    await tester.pumpWidget(
      _harness(
        StatefulBuilder(
          builder: (context, setState) {
            return TSelect<String>(
              options: options,
              labelBuilder: (v) => v,
              placeholder: 'Pick',
              filterable: true,
              onSearch: (query) {
                queries.add(query);
                setState(() {
                  options = query.isEmpty
                      ? const ['Apple', 'Banana']
                      : [
                          for (final item in const ['Apple', 'Banana', 'Apricot'])
                            if (item.toLowerCase().startsWith(query.toLowerCase()))
                              item,
                        ];
                });
              },
              onChanged: (_) {},
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    await _tapSelect(tester);

    await tester.enterText(
      find.byKey(const ValueKey<String>('TSelect.filter')),
      'Ap',
    );
    await tester.pumpAndSettle();

    expect(queries, ['Ap']);
    expect(find.text('Apple'), findsOneWidget);
    expect(find.text('Apricot'), findsOneWidget);
    expect(find.text('Banana'), findsNothing);
  });

  testWidgets('creatable shows a create row for a novel query', (tester) async {
    var options = <String>['Apple', 'Banana'];
    String? selected;
    await tester.pumpWidget(
      _harness(
        StatefulBuilder(
          builder: (context, setState) {
            return TSelect<String>(
              options: options,
              labelBuilder: (v) => v,
              value: selected,
              placeholder: 'Pick',
              filterable: true,
              creatable: true,
              onCreate: (query) {
                setState(() {
                  options = [...options, query];
                  selected = query;
                });
              },
              onChanged: (v) => setState(() => selected = v),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    await _tapSelect(tester);

    await tester.enterText(
      find.byKey(const ValueKey<String>('TSelect.filter')),
      'Durian',
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey<String>('TSelect.create')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('TSelect.create')));
    await tester.pumpAndSettle();
    expect(selected, 'Durian');
    expect(options, contains('Durian'));
  });

  testWidgets('disabled options cannot be chosen', (tester) async {
    String? selected;
    await tester.pumpWidget(
      _harness(
        StatefulBuilder(
          builder: (context, setState) {
            return TSelect<String>(
              options: const ['Apple', 'Banana', 'Cherry'],
              labelBuilder: (v) => v,
              value: selected,
              placeholder: 'Pick fruit',
              optionDisabled: (v) => v == 'Banana',
              onChanged: (v) => setState(() => selected = v),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    await _tapSelect(tester);
    await tester.tap(find.text('Banana'));
    await tester.pumpAndSettle();
    expect(selected, isNull);
    expect(find.text('Banana'), findsOneWidget);
  });

  testWidgets('optionGroup inserts a section header', (tester) async {
    await tester.pumpWidget(
      _harness(
        TSelect<String>(
          options: const ['Apple', 'Banana', 'Carrot'],
          labelBuilder: (v) => v,
          placeholder: 'Pick',
          optionGroup: (v) => v == 'Carrot' ? '蔬菜' : '水果',
          onChanged: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    await _tapSelect(tester);
    expect(find.byKey(const ValueKey<String>('TSelect.group.水果')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('TSelect.group.蔬菜')), findsOneWidget);
  });

  testWidgets('Select opens on activate and closes on Escape', (tester) async {
    String? selected;

    await tester.pumpWidget(
      _harness(
        TSelect<String>(
          options: const ['Apple', 'Banana', 'Cherry'],
          labelBuilder: (v) => v,
          value: selected,
          placeholder: 'Pick fruit',
          onChanged: (v) => selected = v,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pick fruit'), findsOneWidget);
    expect(find.text('Banana'), findsNothing);

    await _tapSelect(tester);
    expect(find.text('Banana'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('TSelect.filter')), findsNothing);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Banana'), findsNothing);
  });

  testWidgets('Select chooses option and restores closed state', (
    tester,
  ) async {
    String? selected;

    await tester.pumpWidget(
      _harness(
        StatefulBuilder(
          builder: (context, setState) {
            return TSelect<String>(
              options: const ['Apple', 'Banana', 'Cherry'],
              labelBuilder: (v) => v,
              value: selected,
              placeholder: 'Pick fruit',
              onChanged: (v) => setState(() => selected = v),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _tapSelect(tester);
    await tester.tap(find.text('Banana'));
    await tester.pumpAndSettle();

    expect(selected, 'Banana');
    expect(find.text('Banana'), findsOneWidget);
    expect(find.text('Cherry'), findsNothing);
  });

  testWidgets('ArrowDown opens Select when focused', (tester) async {
    await tester.pumpWidget(
      _harness(
        const TSelect<String>(
          options: ['A', 'B'],
          labelBuilder: _identity,
          placeholder: 'Pick',
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await _pumpOpenSettle(tester);
    expect(find.text('B'), findsOneWidget);
  });

  testWidgets('multiple select renders tags and removes one', (tester) async {
    var values = <String>[];
    var singleChanges = 0;

    Future<void> pump() {
      return tester.pumpWidget(
        _harness(
          StatefulBuilder(
            builder: (context, setState) {
              return TSelect<String>(
                multiple: true,
                values: values,
                options: const ['Apple', 'Banana', 'Cherry'],
                labelBuilder: _identity,
                placeholder: 'Pick fruit',
                onChanged: (_) => singleChanges++,
                onValuesChanged: (next) => setState(() => values = next),
              );
            },
          ),
        ),
      );
    }

    await pump();
    await tester.pumpAndSettle();
    expect(find.text('Pick fruit'), findsOneWidget);
    expect(find.byType(TTag), findsNothing);

    await _tapSelect(tester);
    await tester.tap(_option('Apple'));
    await tester.pumpAndSettle();
    await tester.tap(_option('Banana'));
    await tester.pumpAndSettle();

    expect(singleChanges, 0);
    expect(values, <String>['Apple', 'Banana']);
    expect(find.byType(TTag), findsNWidgets(2));

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Cherry'), findsNothing);

    await tester.tap(
      find.byKey(const ValueKey<String>('TSelect.tag-close.Apple')),
    );
    await tester.pumpAndSettle();

    expect(values, <String>['Banana']);
    expect(find.byType(TTag), findsOneWidget);
    expect(find.text('Cherry'), findsNothing);
  });

  testWidgets('filterable matches label substrings without case', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        const TSelect<String>(
          filterable: true,
          options: ['Apple', 'Banana', 'Cherry'],
          labelBuilder: _identity,
          placeholder: 'Pick fruit',
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _tapSelect(tester);
    expect(find.text('搜索'), findsOneWidget);
    expect(_option('Cherry'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey<String>('TSelect.filter')),
      'BAN',
    );
    await tester.pump();

    expect(_option('Banana'), findsOneWidget);
    expect(_option('Apple'), findsNothing);
    expect(_option('Cherry'), findsNothing);

    await tester.enterText(
      find.byKey(const ValueKey<String>('TSelect.filter')),
      'app',
    );
    await tester.pump();

    expect(_option('Apple'), findsOneWidget);
    expect(_option('Banana'), findsNothing);

    await tester.enterText(
      find.byKey(const ValueKey<String>('TSelect.filter')),
      '',
    );
    await tester.pump();

    expect(_option('Apple'), findsOneWidget);
    expect(_option('Banana'), findsOneWidget);
    expect(_option('Cherry'), findsOneWidget);
  });

  testWidgets('clearable clears single and multiple values', (tester) async {
    String? selected = 'Banana';
    var values = <String>['Apple', 'Banana'];
    var singleChanges = 0;
    var listChanges = 0;

    await tester.pumpWidget(
      _harness(
        StatefulBuilder(
          builder: (context, setState) {
            return Column(
              children: [
                TSelect<String>(
                  clearable: true,
                  value: selected,
                  options: const ['Apple', 'Banana', 'Cherry'],
                  labelBuilder: _identity,
                  placeholder: 'Pick fruit',
                  onChanged: (value) => setState(() => selected = value),
                  onValuesChanged: (_) => listChanges++,
                ),
                TSelect<String>(
                  multiple: true,
                  clearable: true,
                  values: values,
                  options: const ['Apple', 'Banana', 'Cherry'],
                  labelBuilder: _identity,
                  onChanged: (_) => singleChanges++,
                  onValuesChanged: (next) => setState(() => values = next),
                ),
              ],
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('TSelect.clear')),
      findsNWidgets(2),
    );

    await tester.tap(find.byKey(const ValueKey<String>('TSelect.clear')).first);
    await tester.pumpAndSettle();

    expect(selected, isNull);
    expect(listChanges, 0);
    expect(find.text('Pick fruit'), findsOneWidget);
    expect(find.text('Banana'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('TSelect.clear')));
    await tester.pumpAndSettle();

    expect(values, isEmpty);
    expect(singleChanges, 0);
    expect(find.byType(TTag), findsNothing);
    expect(find.byKey(const ValueKey<String>('TSelect.clear')), findsNothing);
  });
}

Finder _option(String label) {
  return find.descendant(of: find.byType(ListView), matching: find.text(label));
}

String _identity(String value) => value;
