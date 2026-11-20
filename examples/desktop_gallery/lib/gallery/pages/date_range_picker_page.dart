import 'package:flutter/widgets.dart';
import 'package:tdesign_flutter_desktop/tdesign_flutter_desktop.dart';

import '../scaffold.dart';

class DateRangePickerDemoPage extends StatefulWidget {
  const DateRangePickerDemoPage({super.key});

  @override
  State<DateRangePickerDemoPage> createState() =>
      _DateRangePickerDemoPageState();
}

class _DateRangePickerDemoPageState extends State<DateRangePickerDemoPage> {
  var _range = const TDateRange();

  @override
  Widget build(BuildContext context) {
    return GalleryPage(
      title: 'DateRangePicker 日期区间选择器',
      source: 'components/date-picker',
      children: [
        DemoSection(
          title: '选择日期区间',
          child: SizedBox(
            width: 320,
            child: TDateRangePicker(
              value: _range,
              clearable: true,
              onChanged: (value) => setState(() => _range = value),
            ),
          ),
        ),
      ],
    );
  }
}
