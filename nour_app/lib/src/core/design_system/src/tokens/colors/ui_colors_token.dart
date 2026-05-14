import 'dart:ui';

class UIColorsToken {
  final Color bgColor;

  const UIColorsToken({
      required this.bgColor
    });

  factory UIColorsToken.light() => UIColorsToken(
    bgColor: Color(0x00000000),
  );

  factory UIColorsToken.dark() => UIColorsToken(
    bgColor: Color(0xffffffff),
  );

  static const Color shadow = Color(0xff0A0D12);
  static final Color overlay = Color(0x00000000).withValues(alpha: 0.5);
}
