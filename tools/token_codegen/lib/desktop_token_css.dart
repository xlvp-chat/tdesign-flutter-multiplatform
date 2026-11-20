/// CSS fed to css2token for Desktop core tokens.
///
/// Brand, container background, primary text, and the default radius keep the
/// Phase 0 PoC values already shipped in `tdesign_tokens.g.dart`.
/// Error, warning, and success ramps are the light and dark values from
/// tdesign-common `theme/_light.less` and `theme/_dark.less`.
/// `--td-*-color-hover` is included so the source matches those files.
/// css2token does not map that name; the hover step stays on the numbered key
/// (`errorColor5`, `warningColor4`, `successColor4`).
///
/// `--td-bg-color-container-hover` is also unmapped. The resolved tdesign-common
/// colors are written here (light gray-color-1 `#f3f3f3`, dark gray-color-12
/// `#2c2c2c`) and recorded as `bgColorContainerHover` by the emitter.
/// `--td-text-color-anti` is `#fff` in both modes; css2token names it
/// `textColorAnti`. Dark menu background stays `bgColorContainer` (`#242424`),
/// so this file does not declare `grayColor13`.
///
/// Phase 4 batch 2 adds border / secondary text / brand-light / disabled fill
/// aliases used by Desktop component paint paths.
library;

const _lightWarning = <String>[
  '#fff1e9',
  '#ffd9c2',
  '#ffb98c',
  '#fa9550',
  '#e37318',
  '#be5a00',
  '#954500',
  '#713300',
  '#532300',
  '#3b1700',
];

const _lightError = <String>[
  '#fff0ed',
  '#ffd8d2',
  '#ffb9b0',
  '#ff9285',
  '#f6685d',
  '#d54941',
  '#ad352f',
  '#881f1c',
  '#68070a',
  '#490002',
];

const _lightSuccess = <String>[
  '#e3f9e9',
  '#c6f3d7',
  '#92dab2',
  '#56c08d',
  '#2ba471',
  '#008858',
  '#006c45',
  '#005334',
  '#003b23',
  '#002515',
];

const _darkWarning = <String>[
  '#4f2a1d',
  '#582f21',
  '#733c23',
  '#a75d2b',
  '#cf6e2d',
  '#dc7633',
  '#e8935c',
  '#ecbf91',
  '#eed7bf',
  '#f3e9dc',
];

const _darkError = <String>[
  '#472324',
  '#5e2a2d',
  '#703439',
  '#83383e',
  '#a03f46',
  '#c64751',
  '#de6670',
  '#ec888e',
  '#edb1b6',
  '#eeced0',
];

const _darkSuccess = <String>[
  '#193a2a',
  '#1a4230',
  '#17533d',
  '#0d7a55',
  '#059465',
  '#43af8a',
  '#46bf96',
  '#80d2b6',
  '#b4e1d3',
  '#deede8',
];

/// Light-mode declarations for `dart run bin/generate.dart --demo`.
String get desktopLightTokenCss => _desktopCss(
      brandColor7: '#0052D9',
      brandColor1: '#f2f3ff',
      bgColorContainer: '#ffffff',
      bgColorContainerHover: '#f3f3f3',
      textColorPrimary: '#000000',
      textColorAnti: '#fff',
      grayColor2: '#eee',
      grayColor3: '#e8e8e8',
      grayColor4: '#ddd',
      borderLevel1: 'var(--td-gray-color-3)',
      componentBorder: 'var(--td-gray-color-4)',
      componentDisabled: 'var(--td-gray-color-2)',
      secondaryFont: '--td-font-gray-2',
      secondaryValue: 'rgba(0, 0, 0, 60%)',
      disabledFont: '--td-font-gray-4',
      disabledValue: 'rgba(0, 0, 0, 26%)',
      warning: _lightWarning,
      error: _lightError,
      success: _lightSuccess,
      placeholderFont: '--td-font-gray-3',
      placeholderValue: 'rgba(0, 0, 0, 40%)',
      grayColor14: '#181818',
      maskActive: 'rgba(0, 0, 0, 60%)',
      shadow1:
          '0 1px 10px rgba(0, 0, 0, 5%), 0 4px 5px rgba(0, 0, 0, 8%), 0 2px 4px -1px rgba(0, 0, 0, 12%)',
      shadow2:
          '0 3px 14px 2px rgba(0, 0, 0, 5%), 0 8px 10px 1px rgba(0, 0, 0, 6%), 0 5px 5px -3px rgba(0, 0, 0, 10%)',
    );

/// Dark-mode declarations for `dart run bin/generate.dart --demo`.
String get desktopDarkTokenCss => _desktopCss(
      brandColor7: '#4582E6',
      brandColor1: '#1b2f51',
      bgColorContainer: '#242424',
      bgColorContainerHover: '#2c2c2c',
      textColorPrimary: '#ffffff',
      textColorAnti: '#fff',
      grayColor2: '#eee',
      grayColor3: '#e8e8e8',
      grayColor4: '#ddd',
      grayColor9: '#5e5e5e',
      grayColor11: '#393939',
      grayColor12: '#2c2c2c',
      borderLevel1: 'var(--td-gray-color-11)',
      componentBorder: 'var(--td-gray-color-9)',
      componentDisabled: 'var(--td-gray-color-12)',
      secondaryFont: '--td-font-white-2',
      secondaryValue: 'rgba(255, 255, 255, 55%)',
      disabledFont: '--td-font-white-4',
      disabledValue: 'rgba(255, 255, 255, 22%)',
      warning: _darkWarning,
      error: _darkError,
      success: _darkSuccess,
      placeholderFont: '--td-font-white-3',
      placeholderValue: 'rgba(255, 255, 255, 35%)',
      grayColor14: '#181818',
      maskActive: 'rgba(0, 0, 0, 40%)',
      shadow1:
          '0 4px 6px rgba(0, 0, 0, 6%), 0 1px 10px rgba(0, 0, 0, 8%), 0 2px 4px rgba(0, 0, 0, 12%)',
      shadow2:
          '0 8px 10px rgba(0, 0, 0, 12%), 0 3px 14px rgba(0, 0, 0, 10%), 0 5px 5px rgba(0, 0, 0, 16%)',
    );

String _desktopCss({
  required String brandColor7,
  required String brandColor1,
  required String bgColorContainer,
  required String bgColorContainerHover,
  required String textColorPrimary,
  required String textColorAnti,
  required String grayColor2,
  required String grayColor3,
  required String grayColor4,
  String? grayColor9,
  String? grayColor11,
  String? grayColor12,
  required String borderLevel1,
  required String componentBorder,
  required String componentDisabled,
  required String secondaryFont,
  required String secondaryValue,
  required String disabledFont,
  required String disabledValue,
  required List<String> warning,
  required List<String> error,
  required List<String> success,
  required String placeholderFont,
  required String placeholderValue,
  required String grayColor14,
  required String maskActive,
  required String shadow1,
  required String shadow2,
}) {
  final buffer = StringBuffer()
    ..writeln('--td-brand-color-1:$brandColor1;')
    ..writeln('--td-brand-color-7:$brandColor7;')
    ..writeln('--td-brand-color:var(--td-brand-color-7);')
    ..writeln('--td-brand-color-light:var(--td-brand-color-1);')
    ..writeln('--td-gray-color-2:$grayColor2;')
    ..writeln('--td-gray-color-3:$grayColor3;')
    ..writeln('--td-gray-color-4:$grayColor4;');
  if (grayColor9 != null) buffer.writeln('--td-gray-color-9:$grayColor9;');
  if (grayColor11 != null) buffer.writeln('--td-gray-color-11:$grayColor11;');
  if (grayColor12 != null) buffer.writeln('--td-gray-color-12:$grayColor12;');
  buffer
    ..writeln('--td-bg-color-container:$bgColorContainer;')
    ..writeln('--td-bg-color-container-hover:$bgColorContainerHover;')
    ..writeln('--td-bg-color-component-disabled:$componentDisabled;')
    ..writeln('--td-border-level-1-color:$borderLevel1;')
    ..writeln('--td-component-border:$componentBorder;')
    ..writeln('--td-text-color-primary:$textColorPrimary;')
    ..writeln('--td-text-color-anti:$textColorAnti;')
    ..writeln('--td-radius-default:3px;')
    ..write(_ramp('warning', warning))
    ..write(_aliases('warning', base: 5, hover: 4, active: 6))
    ..write(_ramp('error', error))
    ..write(_aliases('error', base: 6, hover: 5, active: 7))
    ..write(_ramp('success', success))
    ..write(_aliases('success', base: 5, hover: 4, active: 6))
    ..writeln('$secondaryFont:$secondaryValue;')
    ..writeln('--td-text-color-secondary:var($secondaryFont);')
    ..writeln('$disabledFont:$disabledValue;')
    ..writeln('--td-text-color-disabled:var($disabledFont);')
    ..writeln('$placeholderFont:$placeholderValue;')
    ..writeln('--td-text-color-placeholder:var($placeholderFont);')
    ..writeln('--td-gray-color-14:$grayColor14;')
    ..writeln('--td-mask-active:$maskActive;')
    ..writeln('--td-shadow-1:$shadow1;')
    ..writeln('--td-shadow-2:$shadow2;');
  return buffer.toString();
}

String _ramp(String family, List<String> steps) {
  final buffer = StringBuffer();
  for (var i = 0; i < steps.length; i++) {
    buffer.writeln('--td-$family-color-${i + 1}:${steps[i]};');
  }
  return buffer.toString();
}

/// Alias targets match `_light.less` / `_dark.less`.
///
/// `hover` is emitted in the CSS and intentionally left unmapped by css2token.
String _aliases(
  String family, {
  required int base,
  required int hover,
  required int active,
}) {
  return '--td-$family-color:var(--td-$family-color-$base);\n'
      '--td-$family-color-hover:var(--td-$family-color-$hover);\n'
      '--td-$family-color-focus:var(--td-$family-color-2);\n'
      '--td-$family-color-active:var(--td-$family-color-$active);\n'
      '--td-$family-color-disabled:var(--td-$family-color-3);\n'
      '--td-$family-color-light:var(--td-$family-color-1);\n'
      '--td-$family-color-light-hover:var(--td-$family-color-2);\n';
}
