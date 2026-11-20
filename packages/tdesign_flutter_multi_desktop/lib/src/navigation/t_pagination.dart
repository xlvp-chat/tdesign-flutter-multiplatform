import 'package:flutter/widgets.dart';
import 'package:tdesign_flutter_icons/tdesign_flutter_icons.dart';
import 'package:tdesign_flutter_multi_core/tdesign_flutter_multi_core.dart';

import '../basic/t_button.dart';
import '../feedback/t_dropdown.dart';
import '../form/t_input.dart';
import '../token/t_token_color.dart';

/// Pagination look. Matches Vue Next `theme`: `default` | `simple`.
enum TPaginationTheme {
  /// Page-number buttons with optional jumper and page size. Default.
  defaultTheme,

  /// Previous / next only, with a `current / pageCount` label.
  simple,
}

/// Desktop pagination. [current] is 1-based.
///
/// Previous and next stay available. Every page is shown when there are 7 or
/// fewer. With more pages, the first page, the last page, and the current
/// page plus one neighbor on each side stay visible. Each skipped range is
/// one ellipsis that does not receive taps. A range next to either end does
/// not add another ellipsis or repeat a page number.
///
/// [showJumper] adds a page field and a jump action. The entered number is
/// clamped to `1` through the page count and passed to [onChanged]. Input
/// that is not an integer is ignored. Defaults to false.
///
/// [pageSizeOptions] shows a page-size control only when it is not null.
/// [defaultPageSizeOptions] is the usual set. Choosing a size calls
/// [onPageSizeChanged] and does not change [current].
///
/// [theme] [TPaginationTheme.simple] hides page numbers, jumper, and page
/// size, showing only previous / next and `current / pageCount`.
class TPagination extends StatelessWidget {
  const TPagination({
    super.key,
    required this.total,
    required this.pageSize,
    required this.current,
    required this.onChanged,
    this.showJumper = false,
    this.pageSizeOptions,
    this.onPageSizeChanged,
    this.theme = TPaginationTheme.defaultTheme,
  });

  /// Usual sizes for [pageSizeOptions]. Passing this list opts into the
  /// page-size control. Omitting [pageSizeOptions] leaves the control hidden.
  static const List<int> defaultPageSizeOptions = <int>[5, 10, 20, 50];

  /// Total item count used to derive the page count.
  final int total;

  /// Items per page. The page count is at least 1.
  final int pageSize;

  /// Selected page. The first page is 1.
  final int current;

  /// Called with the next 1-based page from a page button, previous, next,
  /// or the jumper.
  final ValueChanged<int> onChanged;

  /// Shows an input and a jump action when true. Defaults to false.
  final bool showJumper;

  /// Sizes shown in the page-size control. Null hides that control.
  final List<int>? pageSizeOptions;

  /// Called with the size chosen from [pageSizeOptions].
  ///
  /// This does not update [current]. The caller owns both controlled values.
  final ValueChanged<int>? onPageSizeChanged;

  /// [TPaginationTheme.defaultTheme] or [TPaginationTheme.simple].
  final TPaginationTheme theme;

  int get _pageCount {
    if (total <= 0) return 1;
    return (total + pageSize - 1) ~/ pageSize;
  }

  @override
  Widget build(BuildContext context) {
    final labelStyle = _labelStyle(tTokenColor(context, 'textColorPrimary'));
    final pageCount = _pageCount;
    if (theme == TPaginationTheme.simple) {
      return _prevNextRow(
        current: current,
        pageCount: pageCount,
        onChanged: onChanged,
        middle: Text('$current / $pageCount', style: labelStyle),
        gap: 12,
      );
    }
    final slots = _pageSlots(pageCount, current);
    final options = pageSizeOptions;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ..._prevNextChildren(
          current: current,
          pageCount: pageCount,
          onChanged: onChanged,
          middle: [
            for (final slot in slots) ...[
              const SizedBox(width: 8),
              _slotButton(slot, labelStyle),
            ],
          ],
          gap: 8,
        ),
        if (options != null) ...[
          const SizedBox(width: 8),
          TDropdown(
            onSelected: _selectPageSize,
            options: [
              for (final size in options)
                TDropdownOption(
                  value: '$size',
                  label: Text(_pageSizeLabel(size)),
                ),
            ],
            child: _PageSizeTrigger(
              label: _pageSizeLabel(pageSize),
              labelStyle: labelStyle,
            ),
          ),
        ],
        if (showJumper) ...[
          const SizedBox(width: 8),
          _PaginationJumper(
            pageCount: pageCount,
            labelStyle: labelStyle,
            onJump: onChanged,
          ),
        ],
      ],
    );
  }

  Widget _slotButton(int? slot, TextStyle labelStyle) {
    if (slot == null) {
      return Text('…', style: labelStyle);
    }
    final selected = slot == current;
    return TButton(
      size: TComponentSize.small,
      theme: selected ? TButtonTheme.primary : TButtonTheme.defaultTheme,
      variant: selected ? TButtonVariant.base : TButtonVariant.outline,
      onPressed: () => onChanged(slot),
      child: Text('$slot'),
    );
  }

  void _selectPageSize(String value) {
    final size = int.tryParse(value);
    if (size == null) return;
    onPageSizeChanged?.call(size);
  }
}

Widget _prevNextRow({
  required int current,
  required int pageCount,
  required ValueChanged<int> onChanged,
  required Widget middle,
  required double gap,
}) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: _prevNextChildren(
      current: current,
      pageCount: pageCount,
      onChanged: onChanged,
      middle: [
        SizedBox(width: gap),
        middle,
      ],
      gap: gap,
    ),
  );
}

List<Widget> _prevNextChildren({
  required int current,
  required int pageCount,
  required ValueChanged<int> onChanged,
  required List<Widget> middle,
  required double gap,
}) {
  return [
    _stepButton(
      label: '上一页',
      enabled: current > 1,
      onPressed: () => onChanged(current - 1),
    ),
    ...middle,
    SizedBox(width: gap),
    _stepButton(
      label: '下一页',
      enabled: current < pageCount,
      onPressed: () => onChanged(current + 1),
    ),
  ];
}

Widget _stepButton({
  required String label,
  required bool enabled,
  required VoidCallback onPressed,
}) {
  return TButton(
    size: TComponentSize.small,
    theme: TButtonTheme.defaultTheme,
    variant: TButtonVariant.outline,
    onPressed: enabled ? onPressed : null,
    child: Text(label),
  );
}

class _PageSizeTrigger extends StatelessWidget {
  const _PageSizeTrigger({required this.label, required this.labelStyle});

  final String label;
  final TextStyle labelStyle;

  @override
  Widget build(BuildContext context) {
    final tokens = TDesignTokenScope.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tTokenColorOf(tokens, 'bgColorContainer'),
        borderRadius: BorderRadius.circular(tTokenRadius(tokens)),
        border: Border.all(color: tTokenColorOf(tokens, 'componentBorder')),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: SizedBox(
          height: 24,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: labelStyle),
              const SizedBox(width: 8),
              Icon(
                TIcons.caret_down_small,
                size: labelStyle.fontSize ?? 12,
                color: labelStyle.color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaginationJumper extends StatefulWidget {
  const _PaginationJumper({
    required this.pageCount,
    required this.labelStyle,
    required this.onJump,
  });

  final int pageCount;
  final TextStyle labelStyle;
  final ValueChanged<int> onJump;

  @override
  State<_PaginationJumper> createState() => _PaginationJumperState();
}

class _PaginationJumperState extends State<_PaginationJumper> {
  var _text = '';

  void _onText(String value) {
    setState(() => _text = value);
  }

  void _jump() {
    final parsed = int.tryParse(_text.trim());
    if (parsed == null) return;
    final page = _clampPage(parsed, widget.pageCount);
    final shown = '$page';
    if (_text != shown) {
      setState(() => _text = shown);
    }
    widget.onJump(page);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('跳至', style: widget.labelStyle),
        const SizedBox(width: 8),
        SizedBox(
          width: 64,
          child: TInput(
            size: TComponentSize.small,
            value: _text,
            onChanged: _onText,
          ),
        ),
        const SizedBox(width: 8),
        Text('页', style: widget.labelStyle),
        const SizedBox(width: 8),
        TButton(
          size: TComponentSize.small,
          theme: TButtonTheme.defaultTheme,
          variant: TButtonVariant.outline,
          onPressed: _jump,
          child: const Text('跳转'),
        ),
      ],
    );
  }
}

TextStyle _labelStyle(Color color) => TextStyle(fontSize: 13, color: color);

String _pageSizeLabel(int size) => '$size 条/页';

int _clampPage(int page, int pageCount) {
  if (page < 1) return 1;
  if (page > pageCount) return pageCount;
  return page;
}

/// Page buttons for [pageCount]. Null entries are ellipses.
///
/// Seven or fewer pages are listed in full. Otherwise the result always
/// includes page 1, the last page, and [current] with one page on each side,
/// then inserts a single ellipsis wherever a number was skipped.
List<int?> _pageSlots(int pageCount, int current) {
  if (pageCount <= 7) {
    return [for (var page = 1; page <= pageCount; page++) page];
  }
  final center = _clampPage(current, pageCount);
  final pages = <int>{1, pageCount, center - 1, center, center + 1}
    ..removeWhere((page) => page < 1 || page > pageCount);
  final sorted = pages.toList()..sort();
  final slots = <int?>[];
  for (var index = 0; index < sorted.length; index++) {
    final page = sorted[index];
    if (index > 0 && page - sorted[index - 1] > 1) {
      slots.add(null);
    }
    slots.add(page);
  }
  return slots;
}
