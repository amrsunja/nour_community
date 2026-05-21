import 'package:flutter/material.dart';
import 'package:nour/src/core/design_system/design_system.dart';

class UIBgArabicTextCard extends StatelessWidget {
  const UIBgArabicTextCard({
    super.key,
    this.arabicBgText,
    this.height,
    required this.child
  });

  final String? arabicBgText;
  final double? height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return UICard(
      height: height ?? 208,
      width: .infinity,
      borderRadius: 10,
      begin: .centerLeft,
      end: .centerRight,
      colors: [
        Color(0xff45513F),
        Color(0xff2B3326),
      ],
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


