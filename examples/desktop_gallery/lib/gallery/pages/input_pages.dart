import 'package:flutter/widgets.dart';
import 'package:tdesign_flutter_multi_core/tdesign_flutter_multi_core.dart';
import 'package:tdesign_flutter_multi_desktop/tdesign_flutter_multi_desktop.dart';

import '../scaffold.dart';

class CheckboxDemoPage extends StatefulWidget {
  const CheckboxDemoPage({super.key});

  @override
  State<CheckboxDemoPage> createState() => _CheckboxDemoPageState();
}

class _CheckboxDemoPageState extends State<CheckboxDemoPage> {
  var _checked = true;
  final _courses = <String>{'1'};

  static const _options = <(String, String)>[
    ('1', '选项一'),
    ('2', '选项二'),
    ('3', '选项三'),
  ];

  bool get _all => _courses.length == _options.length;

  bool get _indeterminate => _courses.isNotEmpty && !_all;

  void _toggleAll(bool checked) {
    setState(() {
      _courses
        ..clear()
        ..addAll(checked ? _options.map((item) => item.$1) : const []);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GalleryPage(
      title: 'Checkbox 多选框',
      source: 'components/checkbox',
      children: [
        DemoSection(
          title: '基础多选框',
          child: TSpace(
            size: 16,
            children: [
              const TCheckbox(checked: false, label: Text('未选中项')),
              TCheckbox(
                checked: _checked,
                label: const Text('选中项'),
                onChanged: (value) => setState(() => _checked = value),
              ),
              const TCheckbox(
                checked: false,
                enabled: false,
                label: Text('未选禁用项'),
              ),
              const TCheckbox(
                checked: true,
                enabled: false,
                label: Text('选中禁用项'),
              ),
            ],
          ),
        ),
        DemoSection(
          title: '全选与组合',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TCheckbox(
                checked: _all,
                indeterminate: _indeterminate,
                label: const Text('全选'),
                onChanged: _toggleAll,
              ),
              const SizedBox(height: 8),
              TSpace(
                size: 16,
                children: [
                  for (final option in _options)
                    TCheckbox(
                      checked: _courses.contains(option.$1),
                      label: Text(option.$2),
                      onChanged: (checked) {
                        setState(() {
                          if (checked) {
                            _courses.add(option.$1);
                          } else {
                            _courses.remove(option.$1);
                          }
                        });
                      },
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text('选中值：${_courses.join(',')}'),
            ],
          ),
        ),
      ],
    );
  }
}

class FormDemoPage extends StatefulWidget {
  const FormDemoPage({super.key});

  @override
  State<FormDemoPage> createState() => _FormDemoPageState();
}

class _FormDemoPageState extends State<FormDemoPage> {
  final _controller = TFormController();
  var _name = '';
  var _tel = '';
  var _sms = false;
  var _gender = '1';
  final _courses = <String>{};
  var _submitted = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() => _submitted = '');
    _controller.submit();
  }

  void _reset() {
    _controller.reset();
    setState(() {
      _name = '';
      _tel = '';
      _sms = false;
      _gender = '1';
      _courses.clear();
      _submitted = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return GalleryPage(
      title: 'Form 表单',
      source: 'components/form',
      children: [
        DemoSection(
          title: '基础表单',
          child: SizedBox(
            width: 480,
            child: TForm(
              controller: _controller,
              onSubmit: () => setState(() => _submitted = '提交成功'),
              children: [
                TFormItem(
                  name: 'name',
                  label: '姓名',
                  required: true,
                  rules: const [TFormRule(required: true, message: '姓名必填')],
                  child: TInput(
                    value: _name,
                    placeholder: '请输入内容',
                    onChanged: (value) => setState(() => _name = value),
                  ),
                ),
                TFormItem(
                  name: 'tel',
                  label: '手机号码',
                  rules: const [TFormRule.telnumber()],
                  child: TInput(
                    value: _tel,
                    placeholder: '请输入内容',
                    onChanged: (value) => setState(() => _tel = value),
                  ),
                ),
                TFormItem(
                  label: '接收短信',
                  child: TSwitch(
                    value: _sms,
                    onChanged: (value) => setState(() => _sms = value),
                  ),
                ),
                TFormItem(
                  label: '性别',
                  child: TRadioGroup<String>(
                    value: _gender,
                    onChanged: (value) => setState(() => _gender = value),
                    children: const [
                      TRadio(groupValue: null, value: '1', label: Text('男')),
                      TRadio(groupValue: null, value: '2', label: Text('女')),
                    ],
                  ),
                ),
                TFormItem(
                  label: '课程',
                  child: TSpace(
                    children: [
                      for (final course in const [
                        ('1', '语文'),
                        ('2', '数学'),
                        ('3', '英语'),
                      ])
                        TCheckbox(
                          checked: _courses.contains(course.$1),
                          label: Text(course.$2),
                          onChanged: (checked) {
                            setState(() {
                              if (checked) {
                                _courses.add(course.$1);
                              } else {
                                _courses.remove(course.$1);
                              }
                            });
                          },
                        ),
                    ],
                  ),
                ),
                TFormItem(
                  label: '',
                  child: TSpace(
                    children: [
                      TButton(
                        theme: TButtonTheme.primary,
                        variant: TButtonVariant.base,
                        onPressed: _submit,
                        child: const Text('提交'),
                      ),
                      TButton(
                        theme: TButtonTheme.defaultTheme,
                        variant: TButtonVariant.outline,
                        onPressed: _reset,
                        child: const Text('重置'),
                      ),
                    ],
                  ),
                ),
                if (_submitted.isNotEmpty) Text(_submitted),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class InputDemoPage extends StatefulWidget {
  const InputDemoPage({super.key});

  @override
  State<InputDemoPage> createState() => _InputDemoPageState();
}

class _InputDemoPageState extends State<InputDemoPage> {
  var _base = '';
  var _small = '';
  var _medium = '';
  var _large = '';
  var _addon = '';
  var _clearable = '可清空';
  var _password = '';
  var _limited = '';

  @override
  Widget build(BuildContext context) {
    return GalleryPage(
      title: 'Input 输入框',
      source: 'components/input',
      children: [
        DemoSection(
          title: '基础输入框',
          child: SizedBox(
            width: 320,
            child: TInput(
              value: _base,
              placeholder: '请输入内容',
              onChanged: (value) => setState(() => _base = value),
            ),
          ),
        ),
        DemoSection(
          title: '不同尺寸',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 320,
                child: TInput(
                  size: TComponentSize.small,
                  value: _small,
                  placeholder: '小尺寸',
                  onChanged: (value) => setState(() => _small = value),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 320,
                child: TInput(
                  value: _medium,
                  placeholder: '中尺寸',
                  onChanged: (value) => setState(() => _medium = value),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 320,
                child: TInput(
                  size: TComponentSize.large,
                  value: _large,
                  placeholder: '大尺寸',
                  onChanged: (value) => setState(() => _large = value),
                ),
              ),
            ],
          ),
        ),
        const DemoSection(
          title: '禁用状态',
          child: SizedBox(
            width: 320,
            child: TInput(enabled: false, value: '不可编辑', placeholder: '请输入内容'),
          ),
        ),
        DemoSection(
          title: '前缀与后缀',
          child: SizedBox(
            width: 320,
            child: TInput(
              value: _addon,
              placeholder: '请输入金额',
              prefix: const Text('¥'),
              suffix: const Text('元'),
              onChanged: (value) => setState(() => _addon = value),
            ),
          ),
        ),
        const DemoSection(
          title: '不同状态',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 320,
                child: TInput(status: TInputStatus.success, placeholder: '成功'),
              ),
              SizedBox(height: 12),
              SizedBox(
                width: 320,
                child: TInput(status: TInputStatus.warning, placeholder: '警告'),
              ),
              SizedBox(height: 12),
              SizedBox(
                width: 320,
                child: TInput(status: TInputStatus.error, placeholder: '错误'),
              ),
            ],
          ),
        ),
        DemoSection(
          title: '可清空',
          child: SizedBox(
            width: 320,
            child: TInput(
              value: _clearable,
              clearable: true,
              placeholder: '请输入内容',
              onChanged: (value) => setState(() => _clearable = value),
            ),
          ),
        ),
        DemoSection(
          title: '密码',
          child: SizedBox(
            width: 320,
            child: TInput(
              value: _password,
              obscureText: true,
              placeholder: '请输入密码',
              onChanged: (value) => setState(() => _password = value),
            ),
          ),
        ),
        DemoSection(
          title: '字数限制',
          child: SizedBox(
            width: 320,
            child: TInput(
              value: _limited,
              maxLength: 10,
              showLimit: true,
              placeholder: '最多 10 个字符',
              onChanged: (value) => setState(() => _limited = value),
            ),
          ),
        ),
      ],
    );
  }
}

class InputNumberDemoPage extends StatefulWidget {
  const InputNumberDemoPage({super.key});

  @override
  State<InputNumberDemoPage> createState() => _InputNumberDemoPageState();
}

class _InputNumberDemoPageState extends State<InputNumberDemoPage> {
  num _base = 3;
  num _step = 3.2;
  num _disabled = 5;

  @override
  Widget build(BuildContext context) {
    return GalleryPage(
      title: 'InputNumber 数字输入框',
      source: 'components/input-number',
      children: [
        DemoSection(
          title: '最大值与最小值',
          child: TInputNumber(
            value: _base,
            min: 0,
            max: 15,
            onChanged: (value) => setState(() => _base = value),
          ),
        ),
        DemoSection(
          title: '步长',
          child: TInputNumber(
            value: _step,
            min: -5,
            max: 15,
            step: 1.2,
            onChanged: (value) => setState(() => _step = value),
          ),
        ),
        DemoSection(
          title: '禁用状态',
          child: TInputNumber(
            value: _disabled,
            enabled: false,
            onChanged: (value) => setState(() => _disabled = value),
          ),
        ),
      ],
    );
  }
}

class RadioDemoPage extends StatefulWidget {
  const RadioDemoPage({super.key});

  @override
  State<RadioDemoPage> createState() => _RadioDemoPageState();
}

class _RadioDemoPageState extends State<RadioDemoPage> {
  var _base = '1';
  var _row = 'beijing';
  var _column = 'gz';

  @override
  Widget build(BuildContext context) {
    return GalleryPage(
      title: 'Radio 单选框',
      source: 'components/radio',
      children: [
        DemoSection(
          title: '基础单选框',
          child: TRadioGroup<String>(
            value: _base,
            onChanged: (value) => setState(() => _base = value),
            children: const [
              TRadio(groupValue: null, value: '1', label: Text('选项一')),
              TRadio(groupValue: null, value: '2', label: Text('选项二')),
              TRadio(
                groupValue: null,
                value: '3',
                enabled: false,
                label: Text('选项三'),
              ),
            ],
          ),
        ),
        DemoSection(
          title: '横向组合',
          child: TRadioGroup<String>(
            value: _row,
            onChanged: (value) => setState(() => _row = value),
            children: const [
              TRadio(groupValue: null, value: 'beijing', label: Text('北京')),
              TRadio(groupValue: null, value: 'shanghai', label: Text('上海')),
              TRadio(groupValue: null, value: 'guangzhou', label: Text('广州')),
            ],
          ),
        ),
        DemoSection(
          title: '纵向组合',
          child: TRadioGroup<String>(
            value: _column,
            direction: Axis.vertical,
            onChanged: (value) => setState(() => _column = value),
            children: const [
              TRadio(groupValue: null, value: 'gz', label: Text('广州')),
              TRadio(groupValue: null, value: 'sz', label: Text('深圳')),
              TRadio(groupValue: null, value: 'zh', label: Text('珠海')),
            ],
          ),
        ),
      ],
    );
  }
}

class SelectDemoPage extends StatefulWidget {
  const SelectDemoPage({super.key});

  @override
  State<SelectDemoPage> createState() => _SelectDemoPageState();
}

class _SelectDemoPageState extends State<SelectDemoPage> {
  String? _value;
  var _multiple = <String>[];
  String? _filtered;
  String? _clearable;
  String? _grouped;
  var _created = <String>['架构云', '大数据'];
  String? _createdValue;
  var _remote = <String>['架构云', '大数据', '区块链', '物联网', '人工智能'];
  String? _remoteValue;

  static const _options = ['架构云', '大数据', '区块链', '物联网', '人工智能'];
  static const _groupedOptions = [
    '苹果',
    '香蕉',
    '橙子',
    '番茄',
    '黄瓜',
  ];

  @override
  Widget build(BuildContext context) {
    return GalleryPage(
      title: 'Select 选择器',
      source: 'components/select',
      children: [
        DemoSection(
          title: '基础选择器',
          child: SizedBox(
            width: 280,
            child: TSelect<String>(
              value: _value,
              placeholder: '请选择云解决方案',
              options: _options,
              labelBuilder: (value) => value,
              onChanged: (value) => setState(() => _value = value),
            ),
          ),
        ),
        DemoSection(
          title: '多选',
          child: SizedBox(
            width: 280,
            child: TSelect<String>(
              multiple: true,
              values: _multiple,
              placeholder: '请选择云解决方案',
              options: _options,
              labelBuilder: _label,
              onValuesChanged: (values) => setState(() => _multiple = values),
            ),
          ),
        ),
        DemoSection(
          title: '可过滤',
          child: SizedBox(
            width: 280,
            child: TSelect<String>(
              filterable: true,
              value: _filtered,
              placeholder: '请选择云解决方案',
              options: _options,
              labelBuilder: _label,
              onChanged: (value) => setState(() => _filtered = value),
            ),
          ),
        ),
        DemoSection(
          title: '可清空',
          child: SizedBox(
            width: 280,
            child: TSelect<String>(
              clearable: true,
              value: _clearable,
              placeholder: '请选择云解决方案',
              options: _options,
              labelBuilder: _label,
              onChanged: (value) => setState(() => _clearable = value),
            ),
          ),
        ),
        DemoSection(
          title: '分组与选项禁用',
          child: SizedBox(
            width: 280,
            child: TSelect<String>(
              value: _grouped,
              placeholder: '请选择',
              options: _groupedOptions,
              labelBuilder: _label,
              optionGroup: (value) =>
                  value == '番茄' || value == '黄瓜' ? '蔬菜' : '水果',
              optionDisabled: (value) => value == '香蕉',
              onChanged: (value) => setState(() => _grouped = value),
            ),
          ),
        ),
        DemoSection(
          title: '可创建新条目',
          child: SizedBox(
            width: 280,
            child: TSelect<String>(
              value: _createdValue,
              placeholder: '输入并创建',
              options: _created,
              labelBuilder: _label,
              filterable: true,
              creatable: true,
              clearable: true,
              onCreate: (query) {
                setState(() {
                  _created = [..._created, query];
                  _createdValue = query;
                });
              },
              onChanged: (value) => setState(() => _createdValue = value),
            ),
          ),
        ),
        DemoSection(
          title: '远程搜索',
          child: SizedBox(
            width: 280,
            child: TSelect<String>(
              value: _remoteValue,
              placeholder: '输入关键词搜索',
              options: _remote,
              labelBuilder: _label,
              filterable: true,
              clearable: true,
              onSearch: (query) {
                const all = ['架构云', '大数据', '区块链', '物联网', '人工智能'];
                setState(() {
                  _remote = query.isEmpty
                      ? all
                      : [
                          for (final item in all)
                            if (item.contains(query)) item,
                        ];
                });
              },
              onChanged: (value) => setState(() => _remoteValue = value),
            ),
          ),
        ),
        const DemoSection(
          title: '禁用状态',
          child: SizedBox(
            width: 280,
            child: TSelect<String>(
              enabled: false,
              placeholder: '请选择云解决方案',
              value: '大数据',
              options: _options,
              labelBuilder: _label,
            ),
          ),
        ),
      ],
    );
  }
}

String _label(String value) => value;

class SwitchDemoPage extends StatefulWidget {
  const SwitchDemoPage({super.key});

  @override
  State<SwitchDemoPage> createState() => _SwitchDemoPageState();
}

class _SwitchDemoPageState extends State<SwitchDemoPage> {
  var _on = true;
  var _small = true;
  var _medium = false;
  var _large = true;

  @override
  Widget build(BuildContext context) {
    return GalleryPage(
      title: 'Switch 开关',
      source: 'components/switch',
      children: [
        DemoSection(
          title: '基础开关',
          child: TSwitch(
            value: _on,
            onChanged: (value) => setState(() => _on = value),
          ),
        ),
        DemoSection(
          title: '不同尺寸',
          child: TSpace(
            size: 16,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              TSwitch(
                size: TComponentSize.small,
                value: _small,
                onChanged: (value) => setState(() => _small = value),
              ),
              TSwitch(
                value: _medium,
                onChanged: (value) => setState(() => _medium = value),
              ),
              TSwitch(
                size: TComponentSize.large,
                value: _large,
                onChanged: (value) => setState(() => _large = value),
              ),
            ],
          ),
        ),
        const DemoSection(
          title: '禁用状态',
          child: TSpace(
            size: 16,
            children: [
              TSwitch(value: true, enabled: false),
              TSwitch(value: false, enabled: false),
            ],
          ),
        ),
      ],
    );
  }
}

class TextareaDemoPage extends StatefulWidget {
  const TextareaDemoPage({super.key});

  @override
  State<TextareaDemoPage> createState() => _TextareaDemoPageState();
}

class _TextareaDemoPageState extends State<TextareaDemoPage> {
  var _base = '';
  var _rows = '';

  @override
  Widget build(BuildContext context) {
    return GalleryPage(
      title: 'Textarea 多行文本框',
      source: 'components/textarea',
      children: [
        DemoSection(
          title: '基础多行文本',
          child: SizedBox(
            width: 420,
            child: TTextarea(
              value: _base,
              placeholder: '请输入内容',
              onChanged: (value) => setState(() => _base = value),
            ),
          ),
        ),
        DemoSection(
          title: '行数',
          child: SizedBox(
            width: 420,
            child: TTextarea(
              value: _rows,
              minLines: 2,
              maxLines: 4,
              placeholder: '最少 2 行，最多 4 行',
              onChanged: (value) => setState(() => _rows = value),
            ),
          ),
        ),
        const DemoSection(
          title: '禁用状态',
          child: SizedBox(
            width: 420,
            child: TTextarea(enabled: false, value: '不可编辑的多行内容'),
          ),
        ),
      ],
    );
  }
}
