import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tdesign_flutter_multi_desktop/tdesign_flutter_multi_desktop.dart';

class _Person {
  const _Person(this.id, this.name, this.status);

  final String id;
  final String name;
  final String status;
}

class _Wide {
  const _Wide(this.left, this.middle, this.right);

  final String left;
  final String middle;
  final String right;
}

class _Node {
  const _Node(this.id, this.name, [this.children = const []]);

  final String id;
  final String name;
  final List<_Node> children;
}

Widget _host(Widget child, {double? width}) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: Overlay(
      initialEntries: [
        OverlayEntry(
          builder: (context) {
            return Align(
              alignment: Alignment.topLeft,
              child: width == null
                  ? child
                  : SizedBox(width: width, child: child),
            );
          },
        ),
      ],
    ),
  );
}

void main() {
  testWidgets('confirm applies a column filter and cancel does not', (
    tester,
  ) async {
    var filters = <String, Object?>{};
    var commits = 0;
    const people = [_Person('1', '贾明', '健康'), _Person('2', '张三', '警告')];

    Future<void> pump() {
      return tester.pumpWidget(
        _host(
          StatefulBuilder(
            builder: (context, setState) {
              return TTable<_Person>(
                data: people,
                rowKey: (row) => row.id,
                filterValue: filters,
                onFilterChanged: (next) {
                  commits += 1;
                  setState(() => filters = next);
                },
                columns: const [
                  TTableColumn(
                    id: 'name',
                    title: Text('申请人'),
                    value: _personName,
                    width: 140,
                  ),
                  TTableColumn(
                    id: 'status',
                    title: Text('状态'),
                    value: _personStatus,
                    width: 160,
                    filter: TTableFilter(
                      type: TTableFilterType.single,
                      options: [
                        TTableFilterOption(value: '健康', label: '健康'),
                        TTableFilterOption(value: '警告', label: '警告'),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );
    }

    await pump();
    await tester.pumpAndSettle();
    expect(find.text('贾明'), findsOneWidget);
    expect(find.text('张三'), findsOneWidget);

    await _openFilter(tester, 'status');
    await tester.tap(
      find.byKey(const ValueKey<String>('TTable.filter.option.status.警告')),
    );
    await tester.pump();
    await tester.tap(
      find.byKey(const ValueKey<String>('TTable.filter.cancel.status')),
    );
    await tester.pumpAndSettle();

    expect(commits, 0);
    expect(filters, isEmpty);
    expect(find.text('贾明'), findsOneWidget);
    expect(find.text('张三'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('TTable.filter.confirm.status')),
      findsNothing,
    );

    await _openFilter(tester, 'status');
    await tester.tap(
      find.byKey(const ValueKey<String>('TTable.filter.option.status.警告')),
    );
    await tester.pump();
    await tester.tapAt(const Offset(720, 540));
    await tester.pumpAndSettle();

    expect(commits, 0);
    expect(filters, isEmpty);
    expect(find.text('贾明'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('TTable.filter.confirm.status')),
      findsNothing,
    );

    await _openFilter(tester, 'status');
    await tester.tap(
      find.byKey(const ValueKey<String>('TTable.filter.option.status.警告')),
    );
    await tester.pump();
    await tester.tap(
      find.byKey(const ValueKey<String>('TTable.filter.confirm.status')),
    );
    await tester.pumpAndSettle();

    expect(commits, 1);
    expect(filters, <String, Object?>{'status': '警告'});
    expect(find.text('贾明'), findsNothing);
    expect(find.text('张三'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('TTable.filter.confirm.status')),
      findsNothing,
    );
  });

  testWidgets('left and right fixed columns stay put while the body scrolls', (
    tester,
  ) async {
    const row = _Wide('左侧固定', '中间滚动', '右侧固定');
    await tester.pumpWidget(
      _host(
        const TTable<_Wide>(
          data: [row],
          rowKey: _wideKey,
          columns: [
            TTableColumn(
              id: 'left',
              title: Text('左'),
              value: _wideLeft,
              width: 120,
              fixed: TTableFixed.left,
            ),
            TTableColumn(
              id: 'middle',
              title: Text('中'),
              value: _wideMiddle,
              width: 420,
            ),
            TTableColumn(
              id: 'right',
              title: Text('右'),
              value: _wideRight,
              width: 120,
              fixed: TTableFixed.right,
            ),
          ],
        ),
        width: 360,
      ),
    );
    await tester.pumpAndSettle();

    final table = tester.getRect(find.byType(TTable<_Wide>));
    final leftBefore = tester.getTopLeft(find.text('左侧固定'));
    final middleBefore = tester.getTopLeft(find.text('中间滚动'));
    final rightBefore = tester.getTopLeft(find.text('右侧固定'));
    expect(leftBefore.dx, greaterThanOrEqualTo(table.left));
    expect(rightBefore.dx, lessThan(table.right));
    expect(middleBefore.dx, greaterThan(leftBefore.dx));

    await tester.drag(
      find.byKey(const ValueKey<String>('TTable.scroll')),
      const Offset(-160, 0),
    );
    await tester.pumpAndSettle();

    final leftAfter = tester.getTopLeft(find.text('左侧固定'));
    final middleAfter = tester.getTopLeft(find.text('中间滚动'));
    final rightAfter = tester.getTopLeft(find.text('右侧固定'));
    expect(leftAfter.dx, closeTo(leftBefore.dx, 0.5));
    expect(rightAfter.dx, closeTo(rightBefore.dx, 0.5));
    expect(middleAfter.dx, lessThan(middleBefore.dx - 40));
    expect(leftAfter.dx, greaterThanOrEqualTo(table.left));
    expect(rightAfter.dx, lessThan(table.right));
    expect(rightAfter.dx, greaterThan(leftAfter.dx));
  });

  testWidgets('tree rows expand and collapse with indented children', (
    tester,
  ) async {
    var expanded = <Object>{};
    var selected = <Object>{};
    const root = _Node('p', '父节点', [
      _Node('c', '子节点', [_Node('g', '孙节点')]),
    ]);

    Future<void> pump() {
      return tester.pumpWidget(
        _host(
          StatefulBuilder(
            builder: (context, setState) {
              return TTable<_Node>(
                data: const [root],
                rowKey: _nodeId,
                expandedKeys: expanded,
                onExpandedKeysChanged: (keys) =>
                    setState(() => expanded = keys),
                onSelectionChanged: (keys) => setState(() => selected = keys),
                childrenOf: _nodeChildren,
                columns: const [
                  TTableColumn(
                    id: 'name',
                    title: Text('名称'),
                    value: _nodeName,
                    width: 240,
                  ),
                ],
              );
            },
          ),
        ),
      );
    }

    await pump();
    await tester.pumpAndSettle();
    expect(find.text('父节点'), findsOneWidget);
    expect(find.text('子节点'), findsNothing);
    expect(find.text('孙节点'), findsNothing);

    await tester.tap(find.byKey(const ValueKey<String>('TTable.expand.p')));
    await tester.pumpAndSettle();
    expect(selected, isEmpty);
    expect(expanded, {'p'});
    expect(find.text('子节点'), findsOneWidget);
    expect(find.text('孙节点'), findsNothing);
    final parentX = tester.getTopLeft(find.text('父节点')).dx;
    final childX = tester.getTopLeft(find.text('子节点')).dx;
    expect(childX, greaterThan(parentX + 8));

    await tester.tap(find.byKey(const ValueKey<String>('TTable.expand.c')));
    await tester.pumpAndSettle();
    expect(selected, isEmpty);
    expect(expanded, {'p', 'c'});
    expect(find.text('孙节点'), findsOneWidget);
    final grandX = tester.getTopLeft(find.text('孙节点')).dx;
    expect(grandX, greaterThan(childX + 8));

    await tester.tap(find.byKey(const ValueKey<String>('TTable.expand.p')));
    await tester.pumpAndSettle();
    expect(expanded, {'c'});
    expect(find.text('子节点'), findsNothing);
    expect(find.text('孙节点'), findsNothing);
    expect(find.text('父节点'), findsOneWidget);
  });

  testWidgets('a null expand callback does not open rows on its own', (
    tester,
  ) async {
    const root = _Node('p', '父节点', [_Node('c', '子节点')]);
    var expanded = <Object>{};
    late StateSetter rebuild;

    await tester.pumpWidget(
      _host(
        StatefulBuilder(
          builder: (context, setState) {
            rebuild = setState;
            return TTable<_Node>(
              data: const [root],
              rowKey: _nodeId,
              childrenOf: _nodeChildren,
              expandedKeys: expanded,
              columns: const [
                TTableColumn(
                  id: 'name',
                  title: Text('名称'),
                  value: _nodeName,
                  width: 200,
                ),
              ],
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey<String>('TTable.expand.p')));
    await tester.pumpAndSettle();
    expect(expanded, isEmpty);
    expect(find.text('子节点'), findsNothing);

    rebuild(() => expanded = {'p'});
    await tester.pumpAndSettle();
    expect(find.text('子节点'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('子节点')).dx,
      greaterThan(tester.getTopLeft(find.text('父节点')).dx),
    );
  });

  testWidgets('single sort cycles and row selection stays controlled', (
    tester,
  ) async {
    TTableSort? sort;
    var selected = <Object>{};
    const people = [
      _Person('1', '贾明', '健康'),
      _Person('2', '张三', '警告'),
      _Person('3', '王芳', '异常'),
      _Person('4', '李四', '健康'),
    ];

    Future<void> pump() {
      return tester.pumpWidget(
        _host(
          StatefulBuilder(
            builder: (context, setState) {
              return TTable<_Person>(
                data: people,
                rowKey: _personId,
                sort: sort,
                onSortChanged: (next) => setState(() => sort = next),
                selectedKeys: selected,
                onSelectionChanged: (keys) => setState(() => selected = keys),
                columns: const [
                  TTableColumn(
                    id: 'name',
                    title: Text('姓名'),
                    value: _personName,
                    width: 120,
                  ),
                  TTableColumn(
                    id: 'status',
                    title: Text('状态'),
                    value: _personStatus,
                    width: 120,
                    sortable: true,
                  ),
                ],
              );
            },
          ),
        ),
      );
    }

    await pump();
    await tester.pumpAndSettle();
    expect(_above('贾明', '张三'), isTrue);
    expect(_above('张三', '王芳'), isTrue);
    expect(_above('王芳', '李四'), isTrue);

    await tester.tap(find.text('贾明'));
    await tester.pumpAndSettle();
    expect(selected, {'1'});

    await tester.tap(find.text('贾明'));
    await tester.pumpAndSettle();
    expect(selected, isEmpty);

    await tester.tap(find.text('状态'));
    await tester.pumpAndSettle();
    expect(sort?.columnId, 'status');
    expect(sort?.ascending, isTrue);
    expect(_above('贾明', '王芳'), isTrue);
    expect(_above('王芳', '张三'), isTrue);

    await tester.tap(find.text('状态'));
    await tester.pumpAndSettle();
    expect(sort?.columnId, 'status');
    expect(sort?.ascending, isFalse);
    expect(_above('张三', '王芳'), isTrue);
    expect(_above('王芳', '贾明'), isTrue);

    await tester.tap(find.text('状态'));
    await tester.pumpAndSettle();
    expect(sort, isNull);
    expect(_above('贾明', '张三'), isTrue);
    expect(_above('张三', '王芳'), isTrue);
    expect(_above('王芳', '李四'), isTrue);
  });

  testWidgets('maxHeight keeps the header and scrolls the body', (tester) async {
    final people = [
      for (var i = 0; i < 20; i++) _Person('$i', '用户$i', '健康'),
    ];
    await tester.pumpWidget(
      _host(
        TTable<_Person>(
          data: people,
          rowKey: _personId,
          maxHeight: 160,
          columns: const [
            TTableColumn(
              id: 'name',
              title: Text('申请人'),
              value: _personName,
              width: 140,
            ),
          ],
        ),
        width: 200,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('TTable.body')), findsOneWidget);
    expect(find.text('申请人'), findsOneWidget);
    expect(find.text('用户0'), findsOneWidget);
    expect(find.text('用户19'), findsNothing);

    await tester.scrollUntilVisible(
      find.text('用户19'),
      80,
      scrollable: find.descendant(
        of: find.byKey(const ValueKey<String>('TTable.body')),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('申请人'), findsOneWidget);
    expect(find.text('用户19'), findsOneWidget);
  });

  testWidgets('dragSort reports old and new indices', (tester) async {
    var people = const [
      _Person('1', '贾明', '健康'),
      _Person('2', '张三', '警告'),
      _Person('3', '王芳', '异常'),
    ];
    int? from;
    int? to;

    await tester.pumpWidget(
      _host(
        StatefulBuilder(
          builder: (context, setState) {
            return TTable<_Person>(
              data: people,
              rowKey: _personId,
              dragSort: true,
              onDragSort: (oldIndex, newIndex) {
                from = oldIndex;
                to = newIndex;
                setState(() {
                  final next = [...people];
                  final item = next.removeAt(oldIndex);
                  next.insert(newIndex, item);
                  people = next;
                });
              },
              columns: const [
                TTableColumn(
                  id: 'name',
                  title: Text('申请人'),
                  value: _personName,
                  width: 140,
                ),
              ],
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    final handle = find.byKey(const ValueKey<String>('TTable.drag.1'));
    final target = find.byKey(const ValueKey<String>('TTable.drag.3'));
    final gesture = await tester.startGesture(tester.getCenter(handle));
    await tester.pump(const Duration(seconds: 1));
    await gesture.moveTo(tester.getCenter(target));
    await gesture.up();
    await tester.pumpAndSettle();

    expect(from, 0);
    expect(to, 2);
    expect(people.first.name, '张三');
    expect(people.last.name, '贾明');
  });

  testWidgets('editable cell commits on submit', (tester) async {
    var people = const [_Person('1', '贾明', '健康')];
    String? edited;

    await tester.pumpWidget(
      _host(
        StatefulBuilder(
          builder: (context, setState) {
            return TTable<_Person>(
              data: people,
              rowKey: _personId,
              onCellEdited: (row, columnId, text) {
                edited = '$columnId:$text';
                setState(() {
                  people = [_Person(row.id, text, row.status)];
                });
              },
              columns: const [
                TTableColumn(
                  id: 'name',
                  title: Text('申请人'),
                  value: _personName,
                  width: 140,
                  editable: true,
                ),
                TTableColumn(
                  id: 'status',
                  title: Text('状态'),
                  value: _personStatus,
                  width: 160,
                ),
              ],
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('贾明'));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.text('贾明'));
    await tester.pumpAndSettle();

    final field = find.byKey(const ValueKey<String>('TTable.edit.1.name'));
    expect(field, findsOneWidget);
    await tester.enterText(field, '张三');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(edited, 'name:张三');
    expect(find.text('张三'), findsOneWidget);
  });

  testWidgets('resizable updates controlled columnWidths', (tester) async {
    var widths = <String, double>{};
    const people = [_Person('1', '贾明', '健康')];

    await tester.pumpWidget(
      _host(
        StatefulBuilder(
          builder: (context, setState) {
            return TTable<_Person>(
              data: people,
              rowKey: _personId,
              resizable: true,
              columnWidths: widths,
              onColumnWidthsChanged: (next) => setState(() => widths = next),
              columns: const [
                TTableColumn(
                  id: 'name',
                  title: Text('申请人'),
                  value: _personName,
                  width: 140,
                ),
                TTableColumn(
                  id: 'status',
                  title: Text('状态'),
                  value: _personStatus,
                  width: 160,
                  resizable: false,
                ),
              ],
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('TTable.resize.status')), findsNothing);

    final handle = find.byKey(const ValueKey<String>('TTable.resize.name'));
    expect(handle, findsOneWidget);
    final gesture = await tester.startGesture(tester.getCenter(handle));
    await gesture.moveBy(const Offset(40, 0));
    await gesture.up();
    await tester.pumpAndSettle();

    expect(widths['name'], 180);
    expect(widths.containsKey('status'), isFalse);
  });
}

Future<void> _openFilter(WidgetTester tester, String columnId) async {
  await tester.tap(find.byKey(ValueKey<String>('TTable.filter.$columnId')));
  await tester.pump();
  await tester.pumpAndSettle();
  expect(
    find.byKey(ValueKey<String>('TTable.filter.confirm.$columnId')),
    findsOneWidget,
  );
}

bool _above(String upper, String lower) {
  final upperY = find.text(upper).evaluate().single;
  final lowerY = find.text(lower).evaluate().single;
  final upperBox = upperY.renderObject! as RenderBox;
  final lowerBox = lowerY.renderObject! as RenderBox;
  return upperBox.localToGlobal(Offset.zero).dy <
      lowerBox.localToGlobal(Offset.zero).dy;
}

String _personId(_Person row) => row.id;

String _personName(_Person row) => row.name;

String _personStatus(_Person row) => row.status;

Object _wideKey(_Wide row) => row.left;

String _wideLeft(_Wide row) => row.left;

String _wideMiddle(_Wide row) => row.middle;

String _wideRight(_Wide row) => row.right;

String _nodeId(_Node row) => row.id;

String _nodeName(_Node row) => row.name;

List<_Node> _nodeChildren(_Node row) => row.children;
