import 'package:flutter/widgets.dart';
import 'package:tdesign_flutter_icons/tdesign_flutter_icons.dart';
import 'package:tdesign_flutter_multi_core/tdesign_flutter_multi_core.dart';

import '../form/t_checkbox.dart';
import '../token/t_token_color.dart';

/// How [TTree.checkedKeys] lists checked nodes when [TTree.checkStrictly] is
/// false. Matches Vue Next `valueMode` (`onlyLeaf` | `all`).
enum TTreeValueMode {
  /// Only leaf values appear in [TTree.checkedKeys]. Default.
  onlyLeaf,

  /// Parents that become fully checked are included with their children.
  all,
}

/// One node in [TTree.items].
class TTreeNode {
  const TTreeNode({
    required this.value,
    required this.label,
    this.children = const [],
    this.disabled = false,
  });

  final String value;
  final String label;
  final List<TTreeNode> children;
  final bool disabled;

  bool get isLeaf => children.isEmpty;
}

/// Desktop tree: expand, optional highlight, optional checkboxes.
///
/// Spec source: tdesign-vue-next `Tree` (local clone). Controlled
/// [expandedKeys], [activedKeys], and [checkedKeys] mirror Vue `expanded` /
/// `actived` / `value`.
class TTree extends StatelessWidget {
  const TTree({
    super.key,
    required this.items,
    this.expandedKeys = const <String>{},
    this.onExpandedKeysChanged,
    this.activable = false,
    this.activedKeys = const <String>{},
    this.onActivedChanged,
    this.checkable = false,
    this.checkedKeys = const <String>{},
    this.onCheckedChanged,
    this.checkStrictly = false,
    this.valueMode = TTreeValueMode.onlyLeaf,
    this.hover = true,
    this.filter,
  });

  final List<TTreeNode> items;
  final Set<String> expandedKeys;
  final ValueChanged<Set<String>>? onExpandedKeysChanged;
  final bool activable;
  final Set<String> activedKeys;
  final ValueChanged<Set<String>>? onActivedChanged;
  final bool checkable;
  final Set<String> checkedKeys;
  final ValueChanged<Set<String>>? onCheckedChanged;
  final bool checkStrictly;
  final TTreeValueMode valueMode;
  final bool hover;

  /// Case-insensitive label query. Null or empty shows the expanded tree.
  ///
  /// A match stays visible with its ancestors. Matching branches are shown
  /// expanded for the query, without writing [expandedKeys].
  final String? filter;

  bool get _filtering => filter != null && filter!.trim().isNotEmpty;

  bool _matches(TTreeNode node) {
    if (!_filtering) return true;
    return _subtreeMatches(node, filter!.trim().toLowerCase());
  }

  bool _subtreeMatches(TTreeNode node, String query) {
    if (node.label.toLowerCase().contains(query)) return true;
    for (final child in node.children) {
      if (_subtreeMatches(child, query)) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = TDesignTokenScope.of(context);
    final index = _TreeIndex(items);
    final rows = <Widget>[];
    void walk(TTreeNode node, int depth) {
      if (!_matches(node)) return;
      final expanded = _filtering || expandedKeys.contains(node.value);
      rows.add(
        _TreeRow(
          node: node,
          depth: depth,
          expanded: expanded,
          actived: activedKeys.contains(node.value),
          checkState: _checkState(node, index),
          activable: activable,
          checkable: checkable,
          hover: hover,
          tokens: tokens,
          onToggleExpand: node.isLeaf || onExpandedKeysChanged == null
              ? null
              : () => _toggleExpand(node.value),
          onActivate: !activable || node.disabled || onActivedChanged == null
              ? null
              : () => _toggleActive(node.value),
          onCheck: !checkable || node.disabled || onCheckedChanged == null
              ? null
              : () => _toggleCheck(node, index),
        ),
      );
      if (!node.isLeaf && expanded) {
        for (final child in node.children) {
          walk(child, depth + 1);
        }
      }
    }

    for (final root in items) {
      walk(root, 0);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: rows,
    );
  }

  void _toggleExpand(String value) {
    onExpandedKeysChanged!(_toggleSetMember(expandedKeys, value));
  }

  void _toggleActive(String value) {
    if (activedKeys.contains(value)) {
      onActivedChanged!(<String>{});
    } else {
      onActivedChanged!({value});
    }
  }

  _CheckState _checkState(TTreeNode node, _TreeIndex index) {
    if (checkStrictly || node.isLeaf) {
      return checkedKeys.contains(node.value)
          ? _CheckState.checked
          : _CheckState.unchecked;
    }
    final leaves = index.leavesOf(node.value);
    if (leaves.isEmpty) {
      return checkedKeys.contains(node.value)
          ? _CheckState.checked
          : _CheckState.unchecked;
    }
    final enabled = leaves.where((leaf) => !index.nodeOf(leaf)!.disabled);
    final total = enabled.length;
    if (total == 0) {
      return _CheckState.unchecked;
    }
    final hit = enabled.where(checkedKeys.contains).length;
    if (hit == 0) return _CheckState.unchecked;
    if (hit == total) return _CheckState.checked;
    return _CheckState.indeterminate;
  }

  void _toggleCheck(TTreeNode node, _TreeIndex index) {
    if (checkStrictly) {
      onCheckedChanged!(_toggleSetMember(checkedKeys, node.value));
      return;
    }
    final next = {...checkedKeys};

    final state = _checkState(node, index);
    final checking = state != _CheckState.checked;
    final targets = node.isLeaf
        ? <String>[node.value]
        : index.leavesOf(node.value);
    for (final value in targets) {
      final target = index.nodeOf(value);
      if (target == null || target.disabled) continue;
      if (checking) {
        next.add(value);
      } else {
        next.remove(value);
      }
    }

    if (valueMode == TTreeValueMode.all) {
      _syncParents(next, index);
    } else {
      next.removeWhere((value) {
        final n = index.nodeOf(value);
        return n != null && !n.isLeaf;
      });
    }
    onCheckedChanged!(next);
  }

  void _syncParents(Set<String> next, _TreeIndex index) {
    for (final value in index.allValues) {
      final node = index.nodeOf(value)!;
      if (node.isLeaf) continue;
      final leaves = index.leavesOf(value);
      final enabled = leaves.where((leaf) => !index.nodeOf(leaf)!.disabled);
      if (enabled.isEmpty) continue;
      if (enabled.every(next.contains)) {
        next.add(value);
      } else {
        next.remove(value);
      }
    }
  }
}

Set<E> _toggleSetMember<E>(Set<E> current, E member) {
  final next = {...current};
  if (!next.add(member)) {
    next.remove(member);
  }
  return next;
}

enum _CheckState { unchecked, checked, indeterminate }

class _TreeIndex {
  _TreeIndex(List<TTreeNode> roots) {
    void walk(TTreeNode node) {
      _nodes[node.value] = node;
      if (node.isLeaf) {
        _leaves[node.value] = [node.value];
      } else {
        final leaves = <String>[];
        for (final child in node.children) {
          walk(child);
          leaves.addAll(_leaves[child.value]!);
        }
        _leaves[node.value] = leaves;
      }
      _all.add(node.value);
    }

    for (final root in roots) {
      walk(root);
    }
  }

  final Map<String, TTreeNode> _nodes = {};
  final Map<String, List<String>> _leaves = {};
  final List<String> _all = [];

  Iterable<String> get allValues => _all;

  TTreeNode? nodeOf(String value) => _nodes[value];

  List<String> leavesOf(String value) =>
      List<String>.unmodifiable(_leaves[value] ?? const []);
}

class _TreeRow extends StatelessWidget {
  const _TreeRow({
    required this.node,
    required this.depth,
    required this.expanded,
    required this.actived,
    required this.checkState,
    required this.activable,
    required this.checkable,
    required this.hover,
    required this.tokens,
    required this.onToggleExpand,
    required this.onActivate,
    required this.onCheck,
  });

  final TTreeNode node;
  final int depth;
  final bool expanded;
  final bool actived;
  final _CheckState checkState;
  final bool activable;
  final bool checkable;
  final bool hover;
  final TDesignTokenSet tokens;
  final VoidCallback? onToggleExpand;
  final VoidCallback? onActivate;
  final VoidCallback? onCheck;

  @override
  Widget build(BuildContext context) {
    final activedBg = tTokenColorOf(tokens, 'brandColorLight');
    final hoverColor = tTokenColorOf(tokens, 'bgColorContainerHover');
    final textColor = tTokenColorOf(tokens, 'textColorPrimary');
    final disabledColor = tTokenColorOf(tokens, 'textColorPlaceholder');

    return TInteractiveRegion(
      enabled: onActivate != null || onToggleExpand != null || onCheck != null,
      onActivate: onActivate ?? onToggleExpand,
      builder: (context, state) {
        Color? background;
        if (actived) {
          background = activedBg;
        } else if (hover && state == TComponentState.hovered) {
          background = hoverColor;
        }
        return ColoredBox(
          color: background ?? const Color(0x00000000),
          child: Padding(
            padding: EdgeInsets.fromLTRB(8.0 + depth * 16.0, 4, 8, 4),
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: node.isLeaf
                      ? null
                      : GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: onToggleExpand,
                          child: Center(
                            child: Icon(
                              expanded
                                  ? TIcons.caret_down_small
                                  : TIcons.caret_right_small,
                              size: 12,
                              color: textColor,
                            ),
                          ),
                        ),
                ),
                if (checkable) ...[
                  const SizedBox(width: 4),
                  TCheckbox(
                    checked: checkState == _CheckState.checked,
                    indeterminate: checkState == _CheckState.indeterminate,
                    enabled: !node.disabled && onCheck != null,
                    onChanged: onCheck == null ? null : (_) => onCheck!(),
                  ),
                  const SizedBox(width: 8),
                ] else
                  const SizedBox(width: 4),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (onCheck != null && !activable) {
                        onCheck!();
                      } else {
                        onActivate?.call();
                      }
                    },
                    child: Text(
                      node.label,
                      style: TextStyle(
                        fontSize: 14,
                        color: node.disabled ? disabledColor : textColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
