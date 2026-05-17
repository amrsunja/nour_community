import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Inter body and small text styles. Use [InterStyle.light] or [InterStyle.dark]
/// for text color on light/dark surfaces.
class InterStyle {
  InterStyle._(Color color)
      : hero = _textStyle(
          color,
          fontSize: 40,
          fontWeight: FontWeight.w600,
        ),
        display = _textStyle(
          color,
          fontSize: 32,
          fontWeight: FontWeight.w600,
        ),
        largeTitle = _textStyle(
          color,
          fontSize: 24,
          fontWeight: FontWeight.w500,
        ),
        title = _textStyle(
          color,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge = _textStyle(
          color,
          fontSize: 20,
          fontWeight: FontWeight.w400,
        ),
        body = _textStyle(
          color,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        bodySmall = _textStyle(
          color,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        caption = _textStyle(
          color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        headline = _textStyle(
          color,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        smallCaption = _textStyle(
          color,
          fontSize: 10,
          fontWeight: FontWeight.w400,
        ),
        titleMedium = _textStyle(
          color,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
        bodyMedium = _textStyle(
          color,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        buttonLabel = _textStyle(
          color,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        );

  factory InterStyle.light() => InterStyle._(Colors.black);

  factory InterStyle.dark() => InterStyle._(Colors.white);

  static TextStyle _textStyle(
    Color color, {
    required double fontSize,
    double? lineHeight,
    FontWeight? fontWeight,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      height: lineHeight == null ? null : lineHeight / fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  final TextStyle hero;
  final TextStyle display;
  final TextStyle largeTitle;
  final TextStyle title;
  final TextStyle bodyLarge;
  final TextStyle body;
  final TextStyle bodySmall;
  final TextStyle caption;
  final TextStyle headline;
  final TextStyle smallCaption;
  final TextStyle titleMedium;
  final TextStyle bodyMedium;
  final TextStyle buttonLabel;
}
