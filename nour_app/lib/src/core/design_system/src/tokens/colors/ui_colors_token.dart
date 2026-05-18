import 'package:flutter/widgets.dart';

class UIColorsToken {
  final Color bgColor;
  final Color iconColor;

  const UIColorsToken({
      required this.bgColor,
      required this.iconColor,
    });

  factory UIColorsToken.light() => UIColorsToken(
    bgColor: Color(0xffffffff),
    iconColor: Color(0xff000000),
  );

  factory UIColorsToken.dark() => UIColorsToken(
    bgColor: Color(0x00000000),
    iconColor: Color(0x00ffffff),
  );

  static const Color shadow = Color(0xff0A0D12);
  static final Color overlay = Color(0x00000000).withValues(alpha: 0.5);

  static const bgPriYellow = LinearGradient(
    colors: [
      Color(0xffC59F54),
      Color(0xffDCB770)
    ]
  );

  static const bgPriGreen = LinearGradient(
    colors: [
      Color(0xff404F3B),
      Color(0xff272E22)
    ]
  );

  static final Color bgDeemphasize = white.withValues(alpha: .3);
  static const Color bgTertiaryGreen = Color(0xff353F32);
  static const Color bgSurface = Color(0xff1A1A1A);

  static const Color white = Color(0xffffffff);
  static const Color black = Color(0xff000000);
  static final Color textParagraph = white.withValues(alpha: 0.6);
  static const Color textYellow = Color(0xffE8C570);
  static final Color stroke = white.withValues(alpha: 0.3);
  static const Color yellow = Color(0xffC59F54);
  static const Color red = Color(0xffFF5454);
  static const Color green = Color(0xff135911);
}
