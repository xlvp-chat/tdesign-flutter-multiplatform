import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tdesign_flutter_multi_adaptive/tdesign_flutter_multi_adaptive.dart';

void main() {
  const resolver = AdaptiveResolver();

  test('forced mobile/desktop modes win', () {
    const ctx = AdaptiveContext(
      windowSize: Size(1200, 800),
      breakpoint: 'desktop',
      primaryPointer: AdaptivePointer.mouse,
      keyboardAvailable: true,
      density: 'default',
    );
    expect(
      resolver.resolve(mode: TDesignMode.mobile, context: ctx),
      TDesignMode.mobile,
    );
    expect(
      resolver.resolve(mode: TDesignMode.desktop, context: ctx),
      TDesignMode.desktop,
    );
  });

  test('adaptive uses width and pointer capability', () {
    const narrowTouch = AdaptiveContext(
      windowSize: Size(390, 800),
      breakpoint: 'mobile',
      primaryPointer: AdaptivePointer.touch,
      keyboardAvailable: false,
      density: 'default',
    );
    expect(
      resolver.resolve(mode: TDesignMode.adaptive, context: narrowTouch),
      TDesignMode.mobile,
    );

    const wideMouse = AdaptiveContext(
      windowSize: Size(1280, 800),
      breakpoint: 'desktop',
      primaryPointer: AdaptivePointer.mouse,
      keyboardAvailable: true,
      density: 'default',
    );
    expect(
      resolver.resolve(mode: TDesignMode.adaptive, context: wideMouse),
      TDesignMode.desktop,
    );
  });
}
