import 'package:flutter/widgets.dart';

import '../token/t_token_color.dart';

typedef TFormFieldValidator = String? Function(Object? value);

/// When a [TFormRule] runs.
///
/// [TFormController.validate] and [TFormController.submit] run every rule.
/// A field change runs rules whose [TFormRule.trigger] contains [change].
/// A field blur does the same for [blur].
enum TFormTrigger { change, blur, submit }

enum _TFormBuiltin { email, url, telnumber }

/// One validation rule for a named [TFormItem].
///
/// An empty value (null, `''`, or an empty [Iterable]) passes unless
/// [required] is true. `0` and `false` are not empty. The first failing check
/// in a rule wins: required, then [min], [max], [pattern], then [validator].
/// The first failing rule in the item's list is the one shown.
///
/// [TFormRule.email], [TFormRule.url], and [TFormRule.telnumber] use three
/// small patterns. They are not validator.js.
class TFormRule {
  const TFormRule({
    bool required = false,
    num? min,
    num? max,
    RegExp? pattern,
    TFormFieldValidator? validator,
    String? message,
    Set<TFormTrigger> trigger = const {TFormTrigger.change},
  }) : this._(
         required: required,
         min: min,
         max: max,
         pattern: pattern,
         validator: validator,
         message: message,
         trigger: trigger,
       );

  /// `^[^@\s]+@[^@\s]+\.[^@\s]+$`.
  ///
  /// Empty values pass. The default failure text is `请输入正确的邮箱`.
  const TFormRule.email({
    String? message,
    Set<TFormTrigger> trigger = const {TFormTrigger.change},
  }) : this._(message: message, trigger: trigger, builtin: _TFormBuiltin.email);

  /// `^(https?|ftp)://\S+$`, case-insensitive.
  ///
  /// Empty values pass. The default failure text is `请输入正确的链接`.
  const TFormRule.url({
    String? message,
    Set<TFormTrigger> trigger = const {TFormTrigger.change},
  }) : this._(message: message, trigger: trigger, builtin: _TFormBuiltin.url);

  /// `^1[3-9]\d{9}$`, the same shape as Vue `telnumber`.
  ///
  /// Empty values pass. The default failure text is `请输入正确的手机号码`.
  const TFormRule.telnumber({
    String? message,
    Set<TFormTrigger> trigger = const {TFormTrigger.change},
  }) : this._(
         message: message,
         trigger: trigger,
         builtin: _TFormBuiltin.telnumber,
       );

  const TFormRule._({
    this.required = false,
    this.min,
    this.max,
    this.pattern,
    this.validator,
    this.message,
    this.trigger = const {TFormTrigger.change},
    _TFormBuiltin? builtin,
  }) : _builtin = builtin;

  /// Fail when the value is null, an empty string, or an empty [Iterable].
  ///
  /// The label star on [TFormItem.required] does not set this.
  /// Default failure text is `不能为空`.
  final bool required;

  /// Inclusive minimum.
  ///
  /// A number is compared as a number. A string is compared by its length
  /// (one Chinese character counts as 1). Default failure text is `不能小于最小值`.
  final num? min;

  /// Inclusive maximum. See [min]. Default failure text is `不能大于最大值`.
  final num? max;

  /// Pattern that must match the whole string.
  ///
  /// The match starts at index 0 and must cover the whole string.
  ///
  /// Dart's [RegExp] has no `lastIndex`. Matching from 0 is the equivalent of
  /// clearing it before each test. Default failure text is `格式不正确`.
  /// Ignored by [TFormRule.email], [TFormRule.url], and [TFormRule.telnumber],
  /// which use their own patterns.
  final RegExp? pattern;

  /// Custom check. A non-empty return value is the failure text.
  ///
  /// [message] is not used for this failure. Null or `''` passes.
  final TFormFieldValidator? validator;

  /// Failure text for required, min, max, and pattern checks.
  ///
  /// When this is null or empty, the check's default text is used.
  final String? message;

  /// Which field events run this rule.
  ///
  /// Defaults to change. Submit runs the rule even when [submit] is absent.
  final Set<TFormTrigger> trigger;

  final _TFormBuiltin? _builtin;

  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final RegExp _urlPattern = RegExp(
    r'^(https?|ftp)://\S+$',
    caseSensitive: false,
  );
  static final RegExp _telPattern = RegExp(r'^1[3-9]\d{9}$');

  RegExp? get _resolvedPattern {
    switch (_builtin) {
      case _TFormBuiltin.email:
        return _emailPattern;
      case _TFormBuiltin.url:
        return _urlPattern;
      case _TFormBuiltin.telnumber:
        return _telPattern;
      case null:
        return pattern;
    }
  }

  String get _formatFallback {
    switch (_builtin) {
      case _TFormBuiltin.email:
        return '请输入正确的邮箱';
      case _TFormBuiltin.url:
        return '请输入正确的链接';
      case _TFormBuiltin.telnumber:
        return '请输入正确的手机号码';
      case null:
        return '格式不正确';
    }
  }
}

/// Holds named field values and runs [TFormRule]s.
///
/// [TForm] attaches [TForm.onSubmit]. Fields register from [TFormItem]s that
/// have a [TFormItem.name]. [validate] and [submit] notify listeners so those
/// items can show the first failure.
class TFormController extends ChangeNotifier {
  final Map<String, _FieldSlot> _fields = {};
  final Map<String, Object?> _values = {};
  final Map<String, Object?> _initial = {};
  final Map<String, String> _errors = {};
  VoidCallback? _onSubmit;
  var _resetGeneration = 0;
  var _disposed = false;

  /// Latest value reported for each named field.
  ///
  /// Lists are copies. Missing names are omitted.
  Map<String, Object?> get values {
    return Map<String, Object?>.unmodifiable({
      for (final entry in _values.entries) entry.key: _copy(entry.value),
    });
  }

  /// Runs every rule on every named field and writes the first failure.
  ///
  /// Trigger sets are ignored. Returns true when every field passes.
  bool validate() {
    if (_disposed) return false;
    var valid = true;
    for (final entry in _fields.entries) {
      final failure = _firstFailure(entry.value.rules, _values[entry.key]);
      if (failure == null) {
        _errors.remove(entry.key);
      } else {
        _errors[entry.key] = failure;
        valid = false;
      }
    }
    notifyListeners();
    return valid;
  }

  /// [validate], then [TForm.onSubmit] when every field passes.
  void submit() {
    if (validate()) _onSubmit?.call();
  }

  /// Restores each field to the value it first reported and clears failures.
  ///
  /// Input and Select push that value through their callbacks after the frame,
  /// so a controlled parent can store it again.
  void reset() {
    if (_disposed) return;
    for (final name in _fields.keys) {
      _values[name] = _copy(_initial[name]);
      _errors.remove(name);
    }
    _resetGeneration++;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _attach(VoidCallback? onSubmit) {
    _onSubmit = onSubmit;
  }

  void _register(String name, List<TFormRule> rules) {
    final slot = _fields[name];
    if (slot == null) {
      _fields[name] = _FieldSlot(rules);
      return;
    }
    slot.rules = rules;
  }

  void _unregister(String name) {
    if (_disposed) return;
    _fields.remove(name);
    _values.remove(name);
    _initial.remove(name);
    _errors.remove(name);
  }

  String? _errorOf(String name) => _errors[name];

  Object? _peek(String name) => _values[name];

  void _report(String name, Object? value, TFormTrigger? trigger) {
    if (_disposed) return;
    if (!_initial.containsKey(name)) {
      _initial[name] = _copy(value);
    }
    _values[name] = _copy(value);
    if (trigger == null) return;
    final failure = _firstFailure(
      _fields[name]?.rules ?? const <TFormRule>[],
      _values[name],
      trigger,
    );
    if (failure == null) {
      _errors.remove(name);
    } else {
      _errors[name] = failure;
    }
    notifyListeners();
  }
}

/// Field handle placed around a named [TFormItem] child.
///
/// [TInput] and [TSelect] call [report] on change and blur. A null trigger
/// only stores the value. When [hasError] is true, an input whose own status
/// is normal draws an error border.
///
/// [TFormFieldScope.inactive] hides this scope from descendants. Select uses
/// it so the closed field's display text is not stored as the form value.
class TFormFieldScope extends InheritedWidget {
  const TFormFieldScope({
    super.key,
    required this.name,
    required this.hasError,
    required this.resetGeneration,
    required this.value,
    required void Function(Object? value, TFormTrigger? trigger) report,
    required super.child,
  }) : _report = report,
       _active = true;

  const TFormFieldScope.inactive({super.key, required super.child})
    : name = '',
      hasError = false,
      resetGeneration = 0,
      value = null,
      _report = null,
      _active = false;

  /// [TFormItem.name] for this field.
  final String name;

  /// True when the current rule failure is non-empty.
  final bool hasError;

  /// Increases by one each time [TFormController.reset] runs.
  final int resetGeneration;

  /// Last stored value, or the value restored by reset.
  final Object? value;

  final void Function(Object? value, TFormTrigger? trigger)? _report;
  final bool _active;

  static TFormFieldScope? maybeOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<TFormFieldScope>();
    if (scope == null || !scope._active) return null;
    return scope;
  }

  /// Stores [fieldValue] and, when [trigger] is non-null, runs matching rules.
  void report(Object? fieldValue, [TFormTrigger? trigger]) {
    _report?.call(fieldValue, trigger);
  }

  @override
  bool updateShouldNotify(TFormFieldScope oldWidget) {
    return _active != oldWidget._active ||
        name != oldWidget.name ||
        hasError != oldWidget.hasError ||
        resetGeneration != oldWidget.resetGeneration ||
        !_sameValue(value, oldWidget.value);
  }
}

/// Label, control, and error text for one desktop form row.
///
/// [required] draws a star and does not add a rule. [name] and [rules] opt
/// the row into [TFormController] validation. Rows without a name, and rows
/// outside a [TForm] that has a controller, keep the previous layout.
class TFormItem extends StatelessWidget {
  const TFormItem({
    super.key,
    required this.label,
    required this.child,
    this.required = false,
    this.errorText,
    this.labelWidth = 88,
    this.name,
    this.rules = const [],
  });

  final String label;
  final Widget child;

  /// Draws a red star before [label]. Does not validate.
  final bool required;

  /// Error text used when the row has no rule failure.
  ///
  /// A rule failure replaces this until the failing rules pass.
  final String? errorText;
  final double labelWidth;

  /// Key in [TFormController.values]. Null skips validation.
  final String? name;

  /// Rules for [name], in the order they run. Ignored when [name] is null.
  final List<TFormRule> rules;

  @override
  Widget build(BuildContext context) {
    final controller = _TFormScope.maybeOf(context);
    final fieldName = name;
    if (fieldName == null || controller == null) {
      return _TFormItemLayout(
        label: label,
        requiredMark: required,
        errorText: errorText,
        labelWidth: labelWidth,
        child: child,
      );
    }
    return _TFormField(
      name: fieldName,
      rules: rules,
      controller: controller,
      label: label,
      requiredMark: required,
      externalError: errorText,
      labelWidth: labelWidth,
      child: child,
    );
  }
}

/// Column of [TFormItem]s.
///
/// Pass [controller] to validate named items. [onSubmit] runs from
/// [TFormController.submit] after validation passes. With no controller, the
/// column does not submit on its own.
class TForm extends StatefulWidget {
  const TForm({
    super.key,
    required this.children,
    this.controller,
    this.onSubmit,
  });

  final List<Widget> children;
  final TFormController? controller;

  /// Called by [TFormController.submit] when [TFormController.validate] passes.
  final VoidCallback? onSubmit;

  @override
  State<TForm> createState() => _TFormState();
}

class _TFormState extends State<TForm> {
  @override
  void initState() {
    super.initState();
    widget.controller?._attach(widget.onSubmit);
  }

  @override
  void didUpdateWidget(TForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._attach(null);
    }
    widget.controller?._attach(widget.onSubmit);
  }

  @override
  void dispose() {
    widget.controller?._attach(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final column = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: widget.children,
    );
    final controller = widget.controller;
    if (controller == null) return column;
    return _TFormScope(controller: controller, child: column);
  }
}

class _FieldSlot {
  _FieldSlot(this.rules);

  List<TFormRule> rules;
}

class _TFormScope extends InheritedWidget {
  const _TFormScope({required this.controller, required super.child});

  final TFormController controller;

  static TFormController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_TFormScope>()
        ?.controller;
  }

  @override
  bool updateShouldNotify(_TFormScope oldWidget) {
    return controller != oldWidget.controller;
  }
}

class _TFormField extends StatefulWidget {
  const _TFormField({
    required this.name,
    required this.rules,
    required this.controller,
    required this.label,
    required this.requiredMark,
    required this.externalError,
    required this.labelWidth,
    required this.child,
  });

  final String name;
  final List<TFormRule> rules;
  final TFormController controller;
  final String label;
  final bool requiredMark;
  final String? externalError;
  final double labelWidth;
  final Widget child;

  @override
  State<_TFormField> createState() => _TFormFieldState();
}

class _TFormFieldState extends State<_TFormField> {
  @override
  void initState() {
    super.initState();
    widget.controller._register(widget.name, widget.rules);
  }

  @override
  void didUpdateWidget(_TFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller ||
        oldWidget.name != widget.name) {
      oldWidget.controller._unregister(oldWidget.name);
    }
    widget.controller._register(widget.name, widget.rules);
  }

  @override
  void dispose() {
    widget.controller._unregister(widget.name);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final failure = widget.controller._errorOf(widget.name);
        final shown = failure != null && failure.isNotEmpty
            ? failure
            : widget.externalError;
        return _TFormItemLayout(
          label: widget.label,
          requiredMark: widget.requiredMark,
          errorText: shown,
          labelWidth: widget.labelWidth,
          child: TFormFieldScope(
            name: widget.name,
            hasError: failure != null && failure.isNotEmpty,
            resetGeneration: widget.controller._resetGeneration,
            value: widget.controller._peek(widget.name),
            report: (value, trigger) {
              widget.controller._report(widget.name, value, trigger);
            },
            child: widget.child,
          ),
        );
      },
    );
  }
}

class _TFormItemLayout extends StatelessWidget {
  const _TFormItemLayout({
    required this.label,
    required this.requiredMark,
    required this.errorText,
    required this.labelWidth,
    required this.child,
  });

  final String label;
  final bool requiredMark;
  final String? errorText;
  final double labelWidth;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final labelColor = tTokenColor(context, 'textColorPrimary');
    final error = tTokenColor(context, 'errorColor');
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: labelWidth,
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 14, color: labelColor),
                  children: [
                    if (requiredMark)
                      TextSpan(
                        text: '* ',
                        style: TextStyle(color: error),
                      ),
                    TextSpan(text: label),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                child,
                if (errorText != null && errorText!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      errorText!,
                      style: TextStyle(color: error, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String? _firstFailure(
  List<TFormRule> rules,
  Object? value, [
  TFormTrigger? trigger,
]) {
  for (final rule in rules) {
    if (trigger != null && !rule.trigger.contains(trigger)) continue;
    final failure = _evaluate(rule, value);
    if (failure != null) return failure;
  }
  return null;
}

String? _evaluate(TFormRule rule, Object? value) {
  if (_isEmpty(value)) {
    if (!rule.required) return null;
    return _text(rule.message, '不能为空');
  }
  final min = rule.min;
  if (min != null && _belowMin(value, min)) {
    return _text(rule.message, '不能小于最小值');
  }
  final max = rule.max;
  if (max != null && _aboveMax(value, max)) {
    return _text(rule.message, '不能大于最大值');
  }
  final pattern = rule._resolvedPattern;
  if (pattern != null && !_matchesEntire(pattern, value)) {
    return _text(rule.message, rule._formatFallback);
  }
  final custom = rule.validator?.call(value);
  if (custom != null && custom.isNotEmpty) return custom;
  return null;
}

bool _isEmpty(Object? value) {
  if (value == null) return true;
  if (value is String) return value.isEmpty;
  if (value is Iterable) return value.isEmpty;
  return false;
}

bool _belowMin(Object? value, num min) {
  if (value is num) return value < min;
  if (value is String) return value.length < min;
  return false;
}

bool _aboveMax(Object? value, num max) {
  if (value is num) return value > max;
  if (value is String) return value.length > max;
  return false;
}

bool _matchesEntire(RegExp pattern, Object? value) {
  if (value is! String) return false;
  final match = pattern.matchAsPrefix(value, 0);
  return match != null && match.end == value.length;
}

String _text(String? message, String fallback) {
  if (message == null || message.isEmpty) return fallback;
  return message;
}

Object? _copy(Object? value) {
  if (value is List) return List<Object?>.of(value);
  return value;
}

bool _sameValue(Object? a, Object? b) {
  if (identical(a, b)) return true;
  if (a is List && b is List) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
  return a == b;
}
