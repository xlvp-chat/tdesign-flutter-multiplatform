import 'package:flutter/widgets.dart';
import 'package:tdesign_flutter_desktop/tdesign_flutter_desktop.dart';

import '../scaffold.dart';

class TimePickerDemoPage extends StatefulWidget {
  const TimePickerDemoPage({super.key});

  @override
  State<TimePickerDemoPage> createState() => _TimePickerDemoPageState();
}

class _TimePickerDemoPageState extends State<TimePickerDemoPage> {
  TTime? _time = const TTime(hour: 20, minute: 22);
  TTime? _clearable;
  TTime? _steps = const TTime(hour: 10, minute: 0);
  TTime? _input;
  TTime? _preset;
  var _range = const TTimeRange(
    start: TTime(hour: 9, minute: 0),
    end: TTime(hour: 18, minute: 0),
  );

  @override
  Widget build(BuildContext context) {
    return GalleryPage(
      title: 'TimePicker 时间选择器',
      source: 'components/time-picker',
      children: [
        DemoSection(
          title: '基础时间选择',
          child: SizedBox(
            width: 240,
            child: TTimePicker(
              value: _time,
              onChanged: (value) => setState(() => _time = value),
            ),
          ),
        ),
        DemoSection(
          title: '可清除',
          child: SizedBox(
            width: 240,
            child: TTimePicker(
              value: _clearable,
              clearable: true,
              showSeconds: false,
              placeholder: '可清除的时间选择器',
              onChanged: (value) => setState(() => _clearable = value),
            ),
          ),
        ),
        DemoSection(
          title: '步长与禁用时刻',
          child: SizedBox(
            width: 240,
            child: TTimePicker(
              value: _steps,
              steps: const TTimeSteps(hour: 2, minute: 15, second: 30),
              disableTime: (h, m, s) => const TDisabledTime(hour: [0, 2, 4]),
              onChanged: (value) => setState(() => _steps = value),
            ),
          ),
        ),
        DemoSection(
          title: '可输入',
          child: SizedBox(
            width: 240,
            child: TTimePicker(
              value: _input,
              allowInput: true,
              clearable: true,
              placeholder: 'HH:mm:ss',
              onChanged: (value) => setState(() => _input = value),
            ),
          ),
        ),
        DemoSection(
          title: '快捷预设',
          child: SizedBox(
            width: 240,
            child: TTimePicker(
              value: _preset,
              clearable: true,
              showSeconds: false,
              presets: [
                TTimePreset(
                  label: '上班',
                  time: () => const TTime(hour: 9, minute: 0),
                ),
                TTimePreset(
                  label: '午休',
                  time: () => const TTime(hour: 12, minute: 0),
                ),
                TTimePreset(
                  label: '下班',
                  time: () => const TTime(hour: 18, minute: 0),
                ),
              ],
              onChanged: (value) => setState(() => _preset = value),
            ),
          ),
        ),
        DemoSection(
          title: '时间区间',
          child: SizedBox(
            width: 320,
            child: TTimeRangePicker(
              value: _range,
              clearable: true,
              showSeconds: false,
              onChanged: (value) => setState(() => _range = value),
            ),
          ),
        ),
      ],
    );
  }
}
