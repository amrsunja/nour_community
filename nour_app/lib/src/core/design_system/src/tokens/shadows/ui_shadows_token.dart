import 'package:flutter/material.dart';

import '../../../design_system.dart';

class UIShadowToken {
  static BoxShadow shadow({
    double x = 0,
    double y = 0,
    double blur = 0,
    double spread = 0,
    double colorOpacity = 1,
  }) {
		return BoxShadow(
			color: UIColorsToken.yellow.withValues(alpha: 0.25),
			blurRadius: blur,
      spreadRadius: spread,
			offset: Offset(x, y) 
		);
  }

  static final illustration = [
    BoxShadow(blurRadius: 60, spreadRadius: 1, color: UIColorsToken.yellow.withValues(alpha: 0.2))
  ];

  static final texts = [
    BoxShadow(blurRadius: 30, spreadRadius: 1, color: UIColorsToken.yellow.withValues(alpha: 0.4))
  ];

  static final kXs = [
    shadow(y: 0, blur: 2, colorOpacity: 0.05)
  ];

  static final kSm = [
    shadow(y: 1, blur: 2, spread: -1, colorOpacity: 0.1),
    shadow(y: 1, blur: 3, colorOpacity: 0.1),
  ];

  static final kMd = [
    shadow(y: 2, blur: 4, spread: -2, colorOpacity: 0.06),
    shadow(y: 4, blur: 6, spread: -1, colorOpacity: 0.1),
  ];

  static final kLg = [
    shadow(y: 2, blur: 2, spread: -1, colorOpacity: 0.04),
    shadow(y: 4, blur: 6, spread: -2, colorOpacity: 0.03),
  ];

  static final kXl = [
    shadow(y: 3, blur: 3, spread: -1.5, colorOpacity: 0.04),
    shadow(y: 8, blur: 8, spread: -4, colorOpacity: 0.03),
  ];

  static final k2xl = [
    shadow(y: 4, blur: 4, spread: -2, colorOpacity: 0.04),
    shadow(y: 24, blur: 48, spread: -12, colorOpacity: 0.18),
  ];

  static final k3xl = [
    shadow(y: 5, blur: 5, spread: -2.5, colorOpacity: 0.04),
    shadow(y: 32, blur: 64, spread: -12, colorOpacity: 0.14),
  ];
}
