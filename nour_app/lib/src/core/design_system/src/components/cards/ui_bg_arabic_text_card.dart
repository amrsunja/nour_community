import 'package:flutter/material.dart';
import 'package:nour/src/core/design_system/design_system.dart';

class UIBgArabicTextCard extends StatelessWidget {
  const UIBgArabicTextCard({
    super.key,
    this.arabicBgText,
    this.height,
    required this.child,
    this.padding,
    this.onTap
  });

  final String? arabicBgText;
  final double? height;
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return UICard(
      onTap: onTap,
      height: height ?? 208,
      disableBorder: true,
      width: .infinity,
      borderRadius: 10,
      begin: .centerLeft,
      end: .centerRight,
      shadows: [],
      colors: [
        Color(0xff45513F),
        Color(0xff2B3326),
      ],
      padding: padding,
      child: Stack(
        fit: .expand,
        children: [
          if (arabicBgText != null)
            FittedBox(
              fit: .fitWidth,
              clipBehavior: .hardEdge,
              child: Text(
                arabicBgText!,
                textAlign: .center,
                style: TextStyle(
                  color: UIColorsToken.textYellow.withValues(alpha: 0.05)
                ),
              ),
            ),

          child
        ],
      ),
    );
  }
}


