import 'package:flutter/widgets.dart';
import 'package:tdesign_flutter_desktop/tdesign_flutter_desktop.dart';

import '../scaffold.dart';

class DatePickerDemoPage extends StatefulWidget {
  const DatePickerDemoPage({super.key});

  @override
  State<DatePickerDemoPage> createState() => _DatePickerDemoPageState();
}

class _DatePickerDemoPageState extends State<DatePickerDemoPage> {
  DateTime? _date;
  DateTime? _clearable;
  DateTime? _input;
  DateTime? _preset;

  @override
  Widget build(BuildContext context) {
    return GalleryPage(
      title: 'DatePicker 日期选择器',
      source: 'components/date-picker',
      children: [
        DemoSection(
          title: '基础日期选择',
          child: SizedBox(
            width: 240,
            child: TDatePicker(
              value: _date,
              onChanged: (value) => setState(() => _date = value),
            ),
          ),
        ),
        DemoSection(
          title: '可清除',
          child: SizedBox(
            width: 240,
            child: TDatePicker(
              value: _clearable,
              clearable: true,
              placeholder: '可清除的日期选择器',
              onChanged: (value) => setState(() => _clearable = value),
            ),
          ),
        ),
        DemoSection(
          title: '可输入',
          child: SizedBox(
            width: 240,
            child: TDatePicker(
              value: _input,
              allowInput: true,
              clearable: true,
              placeholder: 'YYYY-MM-DD',
              onChanged: (value) => setState(() => _input = value),
            ),
          ),
        ),
        DemoSection(
          title: '快捷预设',
          child: SizedBox(
            width: 240,
            child: TDatePicker(
              value: _preset,
              clearable: true,
              presets: [
                const TDatePreset(label: '今天', date: DateTime.now),
                TDatePreset(
                  label: '昨天',
                  date: () => DateTime.now().subtract(const Duration(days: 1)),
                ),
                TDatePreset(label: '元旦', date: () => DateTime(2026, 1, 1)),
              ],
              onChanged: (value) => setState(() => _preset = value),
            ),
          ),
        ),
      ],
    );
  }
}
