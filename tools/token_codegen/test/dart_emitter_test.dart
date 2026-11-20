import 'dart:io';

import 'package:test/test.dart';
import 'package:token_codegen/dart_emitter.dart';
import 'package:token_codegen/desktop_token_css.dart';

void main() {
  test('emits semantic color and radius keys', () {
    final dart = emitTDesignTokensDart(
      tokensFromCss(
        lightCss:
            '--td-brand-color-7:#0052D9; --td-brand-color:var(--td-brand-color-7); '
            '--td-radius-default:3px;',
        darkCss:
            '--td-brand-color-7:#4582E6; --td-brand-color:var(--td-brand-color-7); '
            '--td-radius-default:3px;',
      ),
    );

    expect(dart, contains('class TDesignTokens'));
    expect(dart, contains('static const light'));
    expect(dart, contains('static const dark'));
    expect(dart, contains('brandColor'));
    expect(dart, contains('radii:'));
  });

  test('desktop palette keeps PoC keys and adds status ramps', () {
    final theme = tokensFromCss(
      lightCss: desktopLightTokenCss,
      darkCss: desktopDarkTokenCss,
    );

    expect(theme.light.color['brandColor7'], '#0052D9');
    expect(theme.light.color['brandColor'], '#0052D9');
    expect(theme.light.color['bgColorContainer'], '#FFFFFF');
    expect(theme.light.color['textColorPrimary'], '#000000');
    expect(theme.light.radius['radiusDefault'], 3);
    expect(theme.dark.color['brandColor7'], '#4582E6');
    expect(theme.dark.color['bgColorContainer'], '#242424');
    expect(theme.dark.color['textColorPrimary'], '#FFFFFF');
    expect(theme.dark.radius['radiusDefault'], 3);

    expect(theme.light.color['errorColor6'], '#D54941');
    expect(theme.light.color['warningColor5'], '#E37318');
    expect(theme.light.color['successColor5'], '#2BA471');
    expect(theme.dark.color['errorColor6'], '#C64751');
    expect(theme.dark.color['warningColor5'], '#CF6E2D');
    expect(theme.dark.color['successColor5'], '#059465');

    expect(theme.light.ref['errorColor'], 'errorColor6');
    expect(theme.light.ref['errorColorLight'], 'errorColor1');
    expect(theme.light.ref['errorColorLightActive'], 'errorColor2');
    expect(theme.light.ref['errorColorDisabled'], 'errorColor3');
    expect(theme.light.ref['warningColor'], 'warningColor5');
    expect(theme.light.ref['warningColorDisabled'], 'warningColor3');
    expect(theme.light.ref['successColor'], 'successColor5');
    expect(theme.light.ref['successColorDisabled'], 'successColor3');
    expect(
        theme.light.color['errorColorLight'], theme.light.color['errorColor1']);
    expect(
      theme.light.color['errorColorDisabled'],
      theme.light.color['errorColor3'],
    );
    expect(theme.light.color['warningColor4'], '#FA9550');
    expect(theme.light.color['successColor4'], '#56C08D');
    expect(theme.dark.color['errorColor5'], '#A03F46');
    expect(theme.dark.color['warningColor4'], '#A75D2B');
    expect(theme.dark.color['successColor4'], '#0D7A55');
    expect(theme.light.color['textColorPlaceholder'], '#66000000');
    expect(theme.dark.color['textColorPlaceholder'], '#59FFFFFF');

    expect(theme.light.color['bgColorContainerHover'], '#F3F3F3');
    expect(theme.dark.color['bgColorContainerHover'], '#2C2C2C');
    expect(theme.light.ref['bgColorContainerHover'], 'bgColorContainerHover');
    expect(theme.dark.ref['bgColorContainerHover'], 'bgColorContainerHover');
    expect(theme.light.color['textColorAnti'], '#FFFFFF');
    expect(theme.dark.color['textColorAnti'], '#FFFFFF');
    expect(theme.light.ref['textColorAnti'], 'textColorAnti');
    expect(theme.dark.ref['textColorAnti'], 'textColorAnti');

    expect(theme.light.color['brandColor1'], '#F2F3FF');
    expect(theme.light.color['brandColorLight'], '#F2F3FF');
    expect(theme.light.ref['brandColorLight'], 'brandColor1');
    expect(theme.light.color['componentBorder'], '#DDDDDD');
    expect(theme.light.color['borderLevel1Color'], '#E8E8E8');
    expect(theme.light.color['textColorSecondary'], '#99000000');
    expect(theme.light.color['textColorDisabled'], '#42000000');
    expect(theme.light.color['bgColorComponentDisabled'], '#EEEEEE');
    expect(theme.dark.color['brandColorLight'], '#1B2F51');
    expect(theme.dark.color['componentBorder'], '#5E5E5E');
    expect(theme.dark.color['borderLevel1Color'], '#393939');
    expect(theme.dark.color['bgColorComponentDisabled'], '#2C2C2C');
    expect(theme.dark.color['textColorSecondary'], '#8CFFFFFF');
    expect(theme.dark.color['textColorDisabled'], '#38FFFFFF');

    for (final mode in [theme.light, theme.dark]) {
      for (final invented in const [
        'errorColorHover',
        'warningColorHover',
        'successColorHover',
        'errorColorLightHover',
        'warningColorLightHover',
        'successColorLightHover',
        'grayColor13',
        'grayColor1',
      ]) {
        expect(mode.color.containsKey(invented), isFalse, reason: invented);
        expect(mode.ref.containsKey(invented), isFalse, reason: invented);
      }
    }
    expect(theme.light.color.containsKey('grayColor12'), isFalse);
  });

  test('container hover can follow a palette var', () {
    final theme = tokensFromCss(
      lightCss: '--td-gray-color-1:#f3f3f3; '
          '--td-bg-color-container-hover:var(--td-gray-color-1);',
      darkCss: '--td-gray-color-12:#2c2c2c; '
          '--td-bg-color-container-hover:var(--td-gray-color-12);',
    );

    expect(theme.light.color['bgColorContainerHover'], '#F3F3F3');
    expect(theme.light.ref['bgColorContainerHover'], 'grayColor1');
    expect(theme.dark.color['bgColorContainerHover'], '#2C2C2C');
    expect(theme.dark.ref['bgColorContainerHover'], 'grayColor12');
    expect(theme.light.color.containsKey('grayColor13'), isFalse);
    expect(theme.dark.color.containsKey('grayColor13'), isFalse);
  });

  test('checked-in core tokens match the desktop palette emitter', () {
    final dart = emitTDesignTokensDart(
      tokensFromCss(
        lightCss: desktopLightTokenCss,
        darkCss: desktopDarkTokenCss,
      ),
    );
    final file = File(
      '../../packages/tdesign_flutter_core/lib/src/token/tdesign_tokens.g.dart',
    );
    expect(file.readAsStringSync().replaceAll('\r\n', '\n'), dart);
  });
}
