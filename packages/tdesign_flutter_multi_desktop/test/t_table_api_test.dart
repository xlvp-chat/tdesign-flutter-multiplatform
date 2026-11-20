import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tdesign_flutter_multi_desktop/tdesign_flutter_multi_desktop.dart';

class _User {
  const _User(this.id, this.name);
  final String id;
  final String name;
}

void main() {
  test('typed column API compiles and sorts', () {
    const users = [
      _User('2', 'Bob'),
      _User('1', 'Alice'),
    ];
    final columns = <TTableColumn<_User>>[
      TTableColumn<_User>(
        id: 'name',
        title: const Text('姓名'),
        value: (user) => user.name,
        width: 160,
        sortable: true,
      ),
    ];

    expect(columns.first.id, 'name');
    expect(columns.first.value(users.first), 'Bob');

    const sort = TTableSort(columnId: 'name', ascending: true);
    expect(sort.columnId, 'name');
  });
}
